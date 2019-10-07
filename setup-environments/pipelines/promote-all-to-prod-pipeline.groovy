@NonCPS
def getMicroServices(json) {
	def items = new groovy.json.JsonSlurper().parseText(json).items
	def microservices = []
	for (int i = 0; i < items.size(); i++) {
		microservices << items[i]['metadata']['name']
	}
	return microservices
}

node {
	
	properties([
	  parameters([
	     string(name: 'GITHUB')
	  ])
	])
	
	stage ('deploy each microservice') {
		sh "oc get is -n prod -o json > images.output"
		def images = readFile('images.output')
		def microservices = getMicroServices(images)
		microservices.each { microservice ->
			openshiftBuild namespace: "cicd", buildConfig: "promote-to-prod-${microservice}", waitTime: "300000"
			openshiftVerifyBuild namespace: "cicd", buildConfig: "promote-to-prod-${microservice}", waitTime: "300000" 
	  }	
	}
}
