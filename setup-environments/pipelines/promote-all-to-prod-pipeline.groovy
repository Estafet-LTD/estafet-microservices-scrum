@NonCPS
def getMicroServices(json) {
	def items = new groovy.json.JsonSlurper().parseText(json).items
	def microservices = []
	for (int i = 0; i < items.size(); i++) {
		microservices << items[i]['metadata']['name']
	}
	return microservices
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
	
	def testStatus
	
	stage ("determine the status of the test environment") {
		sh "oc get dc --selector product=microservices-scrum -n test -o json > test.json"
		def test = readFile('test.json')
		testStatus = getTestStatus(test)
		println "the target deployment is $testStatus"
	}
	
	stage ('deploy each microservice to prod') {
		if (testStatus.equals("true")) {
			sh "oc get is -n test --selector product=microservices-scrum -o json > images.output"
			def images = readFile('images.output')
			def microservices = getMicroServices(images)
			microservices.each { microservice ->
				openshiftBuild namespace: "cicd", buildConfig: "promote-to-prod-${microservice}", waitTime: "300000"
				openshiftVerifyBuild namespace: "cicd", buildConfig: "promote-to-prod-${microservice}", waitTime: "300000" 
		  }		
		}  else {
			error("Cannot deploy microservices to production as the test environment has not been passed testing")
		}
		
	}
}
