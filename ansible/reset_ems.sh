#!/bin/bash

DEBUG=false

function delete_project() {

    local name"=$1"

    echo "Deleting project ${name} (will wait up to 60s) ..."
    local result=

    result="$(oc delete project --grace-period 60 "${name}" 2>&1)"
    local -i status=$?

    ${DEBUG} && echo "${result}"
    if [ ${status} -eq 0 ]; then
        echo "Marked ${name} project for deletion."
    else
        echo "ERROR: Failed to mark ${name} project for deletion."
    fi
    return ${status}
}

function project_exists() {
    local name"=$1"

    local result=

    result="$(oc get project "${name}" 2>&1)"
    local -i status=$?

    ${DEBUG} && echo "${result}"

    return ${status}
}

function wait_for_delete() {

    local name="$1"

    local -i interval=10
    local -i limit=300
    while [ ${limit} -gt 0 ]
    do
        sleep ${interval}
        project_exists "${name}" || {
        	echo "INFO: The ${name} project has been deleted."
        	return 0
    	}
    	((limit-=interval))
    done
    echo "ERROR: project ${name} exists after 300s."
    return 1
}

function login() {
    oc login -u admin -p 123 --insecure-skip-tls-verify=true https://ip-10-0-1-105.eu-west-2.compute.internal:8443 || {
	    echo "ERROR: Failed to login as admin."
	    return 1
	}
}

# Get the absolute path to the directory that contains this script file.
DIR=
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" || {
    printError "Failed to get directory for \"${BASH_SOURCE[0]}\"."
    exit 1
}

declare projects="prod test dev cicd"

login || exit 1

echo "INFO: Resetting Estafet Microservice Scrum applications ..."
((errors=0))
for project in ${projects}; do
	
    if project_exists "${project}"; then
        if delete_project "${project}"; then
            wait_for_delete "${project}" || {
            	echo "WARNING: Failed to delete the ${project} project."
            	(( ++errors))
            }
        fi
    else
        echo "INFO: ${project} does not exist."
    fi
done

oc logout

if [[ ${errors} -eq 0 ]]; then
    echo "INFO: Reset the Estafet Microservice Scrum applications OK."
else
    echo "INFO: Failed to reset all the Estafet Microservice Scrum applications."
   	exit 1
fi

echo "INFO: Dropping Estafet Microservice Scrum application databases ..."
ansible-playbook -vv drop-postgres-databases-playbook.yml || {
	echo "ERROR: Failed to drop the application databases.
	exit 1
}

echo "INFO: Creating Estafet Microservice Scrum application databases ..."
ansible-playbook -vv init-postgres-databases-playbook.yml || {
	echo "ERROR: Failed to initalise the application databases."
	exit 1
}

echo "INFO: Reset the Estafet Microservices Scrum applications and databases OK."