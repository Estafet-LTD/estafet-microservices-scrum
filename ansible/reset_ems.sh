#!/bin/bash

function delete_project() {

    local name"=$1"
    project_exists "${name}" || return 0

    echo "Deleting project ${project} (will wait up to 60s) ..."
    local result=

    result="$(oc delete project --grace-period 60 "${name}" 2>&1)"
    local -i status=$?

    echo "${result}"
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

    return ${status}
}

function wait_for_delete() {

    local name="$1"

    local -i interval=10
    local -i limit=300
    while [ ${limit} -gt 0 ]
    do
        sleep ${interval}
        project_exists "${name}" || return 0
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

# Get the script name.
NAME=
NAME="$(basename "${BASH_SOURCE[0]}")" || {
    printError "Failed to get filename for \"${BASH_SOURCE[0]}\"."
    exit 1
}

declare projects="prod test dev cicd"

login || exit 1

echo "INFO: Resetting Estafet Microservice Scrum ..."

for project in ${projects}; do
    delete_project "${project}"

    wait_for_delete "${project}"
done

oc logout

echo "INFO: Reset Estafet Microservice Scrum OK."

${DIR}/drop_application_databases.sh