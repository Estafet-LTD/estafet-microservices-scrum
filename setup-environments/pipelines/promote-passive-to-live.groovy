@NonCPS
def getTargetEnvironment(json) {
	def matcher = new groovy.json.JsonSlurper().parseText(json).items[0].spec.to.name =~ /(green|blue)(\-basic\-ui)/
	String namespace = matcher[0][1]
	return namespace.equals("green") ? "blue" : "green" 
}

node {
	
	def env

	stage("determine the environment to deploy to") {
		sh "oc get route -o json -n live > route.json"
		def route = readFile('route.json')
		env = getTargetEnvironment(route)
		println "the target namespace to make active is prod-${env}"
	}	
	
	stage("make the target namespace active") {
		sh "oc patch route/basic-ui -p '{\"spec\":{\"to\":{\"name\":\" ${env}-basic-ui\"}}}' -n live > route.out"
		def route = readFile('route.out')
		if (!route.equals("route \"basic-ui\" patched")) {
			throw new RuntimeException("error when patching route $route")
		}
	}
	
}	