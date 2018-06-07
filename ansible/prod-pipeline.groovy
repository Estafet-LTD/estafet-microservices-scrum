node {
	sh "oc get dc --selector product=microservices-scrum -n prod > dc.output"
	def dc = readFile('dc.output')
	println dc
	def count = 0
	dc.split('\n').each {
    if (count > 0) {
        def matcher = it =~ /(\w+\-\w+)(.*)/
        def microservice = matcher[0][1]
        openshiftDeploy namespace: "prod", depCfg: microservice
        openshiftVerifyDeployment namespace: "prod", depCfg: microservice, replicaCount:"1", verifyReplicaCount: "true", waitTime: "600000"
    }
    count++
	}
}
