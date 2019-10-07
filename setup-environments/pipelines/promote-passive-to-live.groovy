@NonCPS
def getTargetEnvironment(json) {
	def matcher = new groovy.json.JsonSlurper().parseText(json).spec.to.name =~ /(green|blue)(basic\-ui)/
	String namespace = matcher[0][1]
	return namespace.equals("green") ? "blue" : "green" 
}

node {
	
	def env

	stage("determine the environment to deploy to") {
		sh "oc get route basic-ui -o json -n prod > route.json"
		def route = readFile('route.json')
		env = getTargetEnvironment(route)
		println "the target deployment is $env"
	}	
	
	stage("make the target deployment active") {
		sh "oc patch route/basic-ui -p '{\"spec\":{\"to\":{\"name\":\"${env}basic-ui\"}}}' -n live > route.out"
		def route = readFile('route.out')
		if (route.indexOf("basic-ui patched") < 0) {
			throw new RuntimeException("error when patching route $route")
		}
	}
	
}	