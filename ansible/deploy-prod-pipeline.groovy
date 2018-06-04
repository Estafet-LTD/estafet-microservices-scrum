@NonCPS
def getDeploymentConfigs(json) {
	def deploymentConfigs = []
	def items = new groovy.json.JsonSlurper().parseText(json).items.find{it.metadata.labels.product == "microservices-scrum"}
	items.each {
		deploymentConfigs << it.metadata.name
	}
	return deploymentConfigs 
}


node {
	sh "oc get dc -o json > dc.json"
	def dc = readFile('dc.json')
	def deploymentConfigs = getDeploymentConfigs(dc)
	println deploymentConfigs
	deploymentConfigs.each { 
				openshiftDeploy namespace: "prod", depCfg: it
	}
}

