@NonCPS
def getDeploymentConfigs(json) {
	def items = new groovy.json.JsonSlurper().parseText(json).items
	def dcs = []
	for (int i = 0; i < items.size(); i++) {
		dcs << items[i]['metadata']['name']
	}
	return dcs
}

@NonCPS
def getPassive(json) {
	def matcher = new groovy.json.JsonSlurper().parseText(json).spec.to.name =~ /(green|blue)(basic\-ui)/
	String namespace = matcher[0][1]
	return namespace.equals("green") ? "blue" : "green" 
}

node('maven') {

	def project = "prod"

	properties([
	  parameters([
	     string(name: 'GITHUB'),
	  ])
	])

	stage("determine the environment to deploy to") {
		sh "oc get route basic-ui -o json -n ${project} > route.json"
		def route = readFile('route.json')
		env = getPassive(route)
		println "the target environment is $env"
	}

	stage("checkout") {
		git branch: "master", url: "https://github.com/${params.GITHUB}/estafet-microservices-scrum-qa-prod"
	}

	stage("initialise test flags") {
		sh "oc get dc --selector environment=${env} -n ${project} -o json > microservices.json"	
		def microservices = readFile('microservices.json')
		def dcs = getDeploymentConfigs(microservices)
		println dcs
		dcs.each { dc ->
				sh "oc patch dc/${dc} -p '{\"metadata\":{\"labels\":{\"testStatus\":\"untested\"}}}' -n ${project}"
		}
	}

	stage("execute smoke tests") {
		withEnv( [ "BASIC_UI_URI=http://${env}basic-ui.${project}.svc:8080" ]) {
			withMaven(mavenSettingsConfig: 'microservices-scrum') {
				sh "mvn clean test"	
		  } 
		}
	}
	
	stage("flag this environment") {
		if (currentBuild.currentResult == 'SUCCESS') {
			println "The tests passed successfully"
			sh "oc get dc --selector environment=${env} -n ${project} -o json > microservices.json"	
			def microservices = readFile('microservices.json')
			def dcs = getDeploymentConfigs(microservices)
			println dcs
			dcs.each { dc ->
					sh "oc patch dc/${dc} -p '{\"metadata\":{\"labels\":{\"testStatus\":\"passed\"}}}' -n ${project}"
			}		
		}
	}
	
}

