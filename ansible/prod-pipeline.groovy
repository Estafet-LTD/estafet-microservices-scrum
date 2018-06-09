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

@NonCPS
def getImage(json) {
	def imageId = new groovy.json.JsonSlurper().parseText(json).status.containerStatuses[0].imageID
	def matcher = imageId =~ /(.*\@sha256\:)(\w+)/
	return matcher[0][2]
}

@NonCPS
def getLatest(json) {
	def tags = new groovy.json.JsonSlurper().parseText(json).status.tags
	tags.each {
		if (it.tag.equals("latest")) {
			return it.items[0].image
		}
	}
	return null
}

def isLatestImageDeployed(microservice) {
	def pod = getPod microservice
	def podImage = getPodImage pod
	def latestImage = getLatestImage microservice
	return podImage.equals(latestImage)
}

def getPod(microservice) {
	sh "oc get pods --selector app=${microservice} > pod.output"
	def pod = readFile('pod.output')
	def lines = pod.split('\n')
	if (lines.size() > 1) {
		def matcher = lines[0] =~ /(\w+\-\w+)(.*)/
		return matcher[0][1]
	} else {
		return null
	}
}

def getPodImage(pod) {
	sh "oc get pod ${pod} -o json > image.output"
	def image = readFile('image.output')
	return getImage image
}

def getLatestImage(microservice) {
	sh "oc get is project-api -o json > latest.json"
	def latest = readFile('latest.json')
	return getLatest latest
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
					if (isLatestImageDeployed(microservice)) {
						println "deploying ${microservice}..."
		        openshiftDeploy namespace: "prod", depCfg: microservice
		        openshiftVerifyDeployment namespace: "prod", depCfg: microservice, replicaCount:"1", verifyReplicaCount: "true", waitTime: "600000"	
		        println "${microservice} deployed"
					} else {
						println "${microservice} latest image is already deployed"
					}
	  }	
	}
}
