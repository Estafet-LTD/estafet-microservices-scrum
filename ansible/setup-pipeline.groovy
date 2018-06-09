@NonCPS
def slurper(json) {
	return new groovy.json.JsonSlurper().parseText(json).metadata.name
}

node('maven') {
	String json = "{\r\n" + 
			"    \"apiVersion\": \"v1\",\r\n" + 
			"    \"kind\": \"Pod\",\r\n" + 
			"    \"metadata\": {\r\n" + 
			"        \"annotations\": {\r\n" + 
			"            \"openshift.io/deployment-config.latest-version\": \"2\",\r\n" + 
			"            \"openshift.io/deployment-config.name\": \"project-api\",\r\n" + 
			"            \"openshift.io/deployment.name\": \"project-api-2\",\r\n" + 
			"            \"openshift.io/scc\": \"restricted\"\r\n" + 
			"        },\r\n" + 
			"        \"creationTimestamp\": \"2018-06-09T12:05:35Z\",\r\n" + 
			"        \"generateName\": \"project-api-2-\",\r\n" + 
			"        \"labels\": {\r\n" + 
			"            \"app\": \"project-api\",\r\n" + 
			"            \"deployment\": \"project-api-2\",\r\n" + 
			"            \"deploymentconfig\": \"project-api\"\r\n" + 
			"        },\r\n" + 
			"        \"name\": \"project-api-2-fmk6f\",\r\n" + 
			"        \"namespace\": \"prod\",\r\n" + 
			"        \"ownerReferences\": [\r\n" + 
			"            {\r\n" + 
			"                \"apiVersion\": \"v1\",\r\n" + 
			"                \"blockOwnerDeletion\": true,\r\n" + 
			"                \"controller\": true,\r\n" + 
			"                \"kind\": \"ReplicationController\",\r\n" + 
			"                \"name\": \"project-api-2\",\r\n" + 
			"                \"uid\": \"6953d2c2-6bdd-11e8-a6fa-00155dba013d\"\r\n" + 
			"            }\r\n" + 
			"        ],\r\n" + 
			"        \"resourceVersion\": \"25149\",\r\n" + 
			"        \"selfLink\": \"/api/v1/namespaces/prod/pods/project-api-2-fmk6f\",\r\n" + 
			"        \"uid\": \"6a7dbcfc-6bdd-11e8-a6fa-00155dba013d\"\r\n" + 
			"    }\r\n" + 
			"}\r\n" + 
			"";
			println json
			def out = slurper(json)
			println out
}
