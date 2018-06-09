@NonCPS
def getDeploymentConfigs(dc, imageStreams) {
	def count = 0
	def configs = []
	dc.split('\n').each { line ->
    if (count > 0) {
        def matcher = line =~ /(\w+\-\w+)(.*)/
      	if (imageStreams.contains(matcher[0][1])) {
      		configs << matcher[0][1]		
      	}
    }
    count++
	}
	return configs
}

@NonCPS
def getImageStreams(is) {
	def count = 0
	def imageStreams = []
	is.split('\n').each { line ->
    if (count > 0) {
        def matcher = line =~ /(\w+\-\w+)(.*)/
        imageStreams << matcher[0][1]
    }
    count++
	}
	return imageStreams
}

node {
	
	stage ('deploy each microservice') {
		sh "oc get is -n prod > is.output"
		def is = readFile('is.output')
		def imageStreams = getImageStreams is
		sh "oc get dc --selector product=microservices-scrum -n prod > dc.output"
		def dc = readFile('dc.output')
		def configs = getDeploymentConfigs(dc, imageStreams)
		configs.each { microservice ->
					println microservice
	        openshiftDeploy namespace: "prod", depCfg: microservice
	        openshiftVerifyDeployment namespace: "prod", depCfg: microservice, replicaCount:"1", verifyReplicaCount: "true", waitTime: "600000"
	  }	
	}
	
	
}
