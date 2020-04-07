node("maven") {

	currentBuild.description = "Build a library from the source, then deploy a snapshot."

	properties([
	  parameters([
	     string(name: 'GITHUB'), string(name: 'REPO'),
	  ])
	])

	stage("checkout") {
		git branch: "master", url: "https://github.com/${params.GITHUB}/${params.REPO}"
	}

	stage("deploy snapshots") {
		withMaven(mavenSettingsConfig: 'microservices-scrum') {
 			sh "mvn clean deploy"
		} 
	}	

}

