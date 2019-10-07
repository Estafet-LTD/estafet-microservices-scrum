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
	stage ('release each microservice') {
		sh "oc get bc -n cicd --selector app=pipeline --selector type=release -o json > images.output"
		def images = readFile('images.output')
		def microservices = getMicroServices(images)
		microservices.each { microservice ->
			openshiftBuild namespace: "cicd", buildConfig: "release-${microservice}", waitTime: "300000"
			openshiftVerifyBuild namespace: "cicd", buildConfig: "release-${microservice}", waitTime: "300000" 
	  }	
	}
}
