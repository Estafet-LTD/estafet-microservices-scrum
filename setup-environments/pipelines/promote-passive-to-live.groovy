@NonCPS
def getTargetEnvironment(json) {
	def matcher = new groovy.json.JsonSlurper().parseText(json).spec.to.name =~ /(green|blue)(basic\-ui)/
	String namespace = matcher[0][1]
	return namespace.equals("green") ? "blue" : "green" 
}

@NonCPS
def getTestStatus(json) {
	def items = new groovy.json.JsonSlurper().parseText(json).items
	for (int i = 0; i < items.size(); i++) {
		def testStatus = items[i]['metadata']['labels']['testStatus']
		if (testStatus.equals("untested") || testStatus.equals("failed")) {
			return "false"
		}
	}
	return "true"
}

node {
	
	def env
	def testStatus
	
	stage("determine the environment to deploy to") {
		sh "oc get route basic-ui -o json -n prod > route.json"
		def route = readFile('route.json')
		env = getTargetEnvironment(route)
		println "the target environment is $env"
	}	
	
	stage ("determine the status of the target environment") {
		sh "oc get dc --selector product=microservices-scrum --selector environment=$env -n prod -o json > test.json"
		def test = readFile('test.json')
		testStatus = getTestStatus(test)
		println "the target environment test status is $testStatus"
	}	
	
	stage("make the target deployment active") {
		if (testStatus.equals("true")) {
			sh "oc patch route/basic-ui -p '{\"spec\":{\"to\":{\"name\":\"${env}basic-ui\"}}}' -n prod > route.out"
			def route = readFile('route.out')
			if (route.indexOf("basic-ui patched") < 0) {
				error("error when patching route $route")
			}
		} else {
			error("Cannot promote $env microservices live as they have not been passed tested")
		}
	}
	
}	