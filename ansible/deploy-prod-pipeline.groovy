node {
	sh "oc get dc --selector product=microservices-scrum -n prod > dc.output"
	def dc = readFile('dc.output')
	println dc
	dc.split('\n') { line, count ->
    if (count > 0) {
        def matcher = line =~ /(\w+\-\w+)(.*)/
        def microservice = matcher[0][1]
        println "deploying ${microservice} ..."
        openshiftDeploy namespace: "prod", depCfg: microservice
        openshiftVerifyDeployment namespace: "prod", depCfg: microservice, replicaCount:"1", verifyReplicaCount: "true", waitTime: "600000"
        println "deployed ${microservice}"
    }
	}
}
