@NonCPS
def getDeploymentConfigs(dc) {
	def count = 0
	def configs = []
	dc.split('\n').each { line ->
    if (count > 0) {
        def matcher = line =~ /(\w+\-\w+)(.*)/
        configs << matcher[0][1]
    }
    count++
	}
	return configs
}

node {
	
	def configs
	
	stage ('retrieve deployment configs') {
		sh "oc get dc --selector product=microservices-scrum -n prod > dc.output"
		def dc = readFile('dc.output')
		configs = getDeploymentConfigs dc
	}
	
	stage ('deploy each microservice') {
		configs.each { microservice ->
					println microservice
	        openshiftDeploy namespace: "prod", depCfg: microservice
	        openshiftVerifyDeployment namespace: "prod", depCfg: microservice, replicaCount:"1", verifyReplicaCount: "true", waitTime: "600000"
	  }	
	}
	
	
}
