@NonCPS
def getProjects(json) {
	def items = new groovy.json.JsonSlurper().parseText(json).items
	def projects = []
	for (int i = 0; i < items.size(); i++) {
		projects << items[i]['metadata']['name']
	}
	return projects.sort()
}

@NonCPS
def getMicroServices(json) {
	def items = new groovy.json.JsonSlurper().parseText(json).items
	def microservices = []
	for (int i = 0; i < items.size(); i++) {
		microservices << items[i]['metadata']['name']
	}
	return microservices
}

@NonCPS
def getDataBaseExternalName(json) {
	return new groovy.json.JsonSlurper().parseText(json).spec.externalName
}

def getNextProjectName() {
	sh "oc get projects --selector type=dev -o json > projects.json"
	def json = readFile('projects.json')	
	def projects = getProjects(json)
	if (projects.isEmpty()) {
		return "dq00"
	} else {
		def matcher = projects.last() =~ /(dq)(\d+\d+)/
		def env = "${matcher[0][2].toInteger()+1}"
		return "${matcher[0][1]}${env.padLeft(2, '0')}"	
	}
}

def getDatabaseEndPoint() {
	sh "oc get service postgresql -o json -n test > db.json"
	def db = readFile('db.json')	
	return getDataBaseExternalName(db)
}


node {
	
	def project
	
	properties([
	  parameters([
	     string(name: 'GITHUB'), string(name: 'PROJECT_TITLE'), string(name: 'MASTER_HOST'), string(name: 'ADMIN_USER'), string(name: 'ADMIN_PASSWORD'),
	  ])
	])
	
	stage("checkout estafet-microservices-scrum") {
		checkout([$class: 'GitSCM', 
							branches: [[name: '*/master']], 
        			doGenerateSubmoduleConfigurations: false, 
        			extensions: [[$class: 'RelativeTargetDirectory', 
            	relativeTargetDir: 'estafet-microservices-scrum']], 
        			submoduleCfg: [], 
        			userRemoteConfigs: [[url: "https://github.com/${params.GITHUB}/estafet-microservices-scrum.git"]]])
	}	
	
	stage("checkout openshift-ansible") {
		checkout([$class: 'GitSCM', 
							branches: [[name: "refs/tags/v3.11"]], 
        			doGenerateSubmoduleConfigurations: false, 
        			extensions: [[$class: 'RelativeTargetDirectory', 
            	relativeTargetDir: 'openshift-ansible']], 
        			submoduleCfg: [], 
        			userRemoteConfigs: [[url: "https://github.com/openshift/openshift-ansible"]]])
	}		
	
	stage ("connect as admin") {
		sh "oc login --insecure-skip-tls-verify=true -u ${params.ADMIN_USER} -p ${params.ADMIN_PASSWORD} ${params.MASTER_HOST}"
	}
	
	stage ("create the namespace") {
		project = getNextProjectName()
		sh "oc new-project $project --display-name='${params.PROJECT_TITLE}'"
		sh "oc label namespace $project type=dev"
	}
	
	stage ("create image streams and templates") {
		sh "oc create -f openshift-ansible/roles/openshift_examples/files/examples/latest/xpaas-streams/amq63-image-stream.json -n $project"
		sh "oc create -f {{ workdir }}/openshift-ansible/roles/openshift_examples/files/examples/latest/xpaas-templates -n $project"
	}
	
	stage ("create the message broker") {
		sh "oc process amq63-basic -p IMAGE_STREAM_NAMESPACE=$project -p MQ_USERNAME=amq -p MQ_PASSWORD=amq | oc create -f -"
		sh "oc set probe dc/broker-amq --readiness --remove"
		openshiftVerifyDeployment namespace: project, depCfg: "broker-amq", replicaCount:"1", verifyReplicaCount: "true", waitTime: "300000" 
	}
	
	stage ("create the jaeger server") {
		sh "oc process -f https://raw.githubusercontent.com/jaegertracing/jaeger-openshift/master/all-in-one/jaeger-all-in-one-template.yml -n $project | oc create -f -"
	}
	
	stage ("create the database endpoint") {
		def database = getDatabaseEndPoint()
		sh "oc process -n $project -f estafet-microservices-scrum/setup-environments/templates/database-service.yml -p DB_HOST=$database | oc apply -f -"
	}
	
	stage ('create each microservice') {
		sh "oc get is -n test --selector product=microservices-scrum -o json > images.output"
		def images = readFile('images.output')
		def microservices = getMicroServices(images)
		microservices.each { microservice ->
			openshiftBuild namespace: "cicd", buildConfig: "microservice-${microservice}", env : [ [ name : "PROJECT", value : project ] ], waitTime: "300000"
			openshiftVerifyBuild namespace: "cicd", buildConfig: "microservice-${microservice}", waitTime: "300000" 
		}		
	}
}
