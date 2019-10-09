@NonCPS
def getDeploymentConfigs(json) {
	def items = new groovy.json.JsonSlurper().parseText(json).items
	def dcs = []
	for (int i = 0; i < items.size(); i++) {
		dcs << items[i]['metadata']['name']
	}
	return dcs
}

node('maven') {

	def project = "test"

	properties([
	  parameters([
	     string(name: 'GITHUB'),
	  ])
	])

	stage("checkout") {
		git branch: "master", url: "https://github.com/${params.GITHUB}/estafet-microservices-scrum-qa"
	}

	stage("initialise test flags") {
		sh "oc get dc --selector product=microservices-scrum -n ${project} -o json > microservices.json"	
		def microservices = readFile('microservices.json')
		def dcs = getDeploymentConfigs(microservices)
		println dcs
		dcs.each { dc ->
				sh "oc patch dc/${dc} -p '{\"metadata\":{\"labels\":{\"testStatus\":\"untested\"}}}'"
		}
	}

	stage("unit tests") {
		withEnv( [ 	"BASIC_UI_URI=http://basic-ui.${project}.svc:8080",
								"TASK_API_JDBC_URL=jdbc:postgresql://postgresql.${project}.svc:5432/${project}-task-api", 
								"TASK_API_DB_USER=postgres", 
								"TASK_API_DB_PASSWORD=welcome1",
								"TASK_API_SERVICE_URI=http://task-api.${project}.svc:8080",
								"STORY_API_JDBC_URL=jdbc:postgresql://postgresql.${project}.svc:5432/${project}-story-api", 
								"STORY_API_DB_USER=postgres", 
								"STORY_API_DB_PASSWORD=welcome1",
								"STORY_API_SERVICE_URI=http://story-api.${project}.svc:8080",
								"SPRINT_BURNDOWN_JDBC_URL=jdbc:postgresql://postgresql.${project}.svc:5432/${project}-sprint-burndown", 
								"SPRINT_BURNDOWN_DB_USER=postgres", 
								"SPRINT_BURNDOWN_DB_PASSWORD=welcome1",
								"SPRINT_BURNDOWN_SERVICE_URI=http://sprint-burndown.${project}.svc:8080",
								"SPRINT_API_JDBC_URL=jdbc:postgresql://postgresql.${project}.svc:5432/${project}-sprint-api", 
								"SPRINT_API_DB_USER=postgres", 
								"SPRINT_API_DB_PASSWORD=welcome1",
								"SPRINT_API_SERVICE_URI=http://sprint-api.${project}.svc:8080",
								"PROJECT_BURNDOWN_REPOSITORY_JDBC_URL=jdbc:postgresql://postgresql.${project}.svc:5432/${project}-project-burndown", 
								"PROJECT_BURNDOWN_REPOSITORY_DB_USER=postgres", 
								"PROJECT_BURNDOWN_REPOSITORY_DB_PASSWORD=welcome1",
								"PROJECT_BURNDOWN_SERVICE_URI=http://project-burndown.${project}.svc:8080",
								"PROJECT_API_JDBC_URL=jdbc:postgresql://postgresql.${project}.svc:5432/${project}-project-api", 
								"PROJECT_API_DB_USER=postgres", 
								"PROJECT_API_DB_PASSWORD=welcome1",
								"PROJECT_API_SERVICE_URI=http://project-api.${project}.svc:8080" ]) {
			withMaven(mavenSettingsConfig: 'microservices-scrum') {
				try {
					sh "mvn clean test"	
				} finally {
					cucumber buildStatus: 'UNSTABLE', fileIncludePattern: '**/*cucumber-report.json',  trendsLimit: 10
				}
		  } 
		}
	}
	
	stage("flag this environment") {
		if (currentBuild.currentResult == 'SUCCESS') {
			println "The tests passed successfully"
			sh "oc get dc --selector product=microservices-scrum -n ${project} -o json > microservices.json"	
			def microservices = readFile('microservices.json')
			def dcs = getDeploymentConfigs(microservices)
			dcs.each { -> dc
					sh "oc patch dc/${dc} -p '{\"metadata\":{\"labels\":{\"testStatus\":\"passed\"}}}'"
			}		
		}
	}
	
}

