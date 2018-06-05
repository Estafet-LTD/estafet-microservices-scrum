@NonCPS
def getDeploymentConfigs(json) {
	return new groovy.json.JsonSlurper().parseText(json).items.'**'.metadata.findAll{node-> node.name() == 'name'}*.text()
}

node {
	sh "oc get dc -o json --selector product=microservices-scrum > dc.json"
	def dc = readFile('dc.json')
	def deploymentConfigs = getDeploymentConfigs(dc)
	println deploymentConfigs
	deploymentConfigs.each { 
				openshiftDeploy namespace: "prod", depCfg: it
	}
}

