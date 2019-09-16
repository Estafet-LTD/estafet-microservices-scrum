#!/bin/bash

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

pushd "${DIR}" >/dev/null 2>&1 || {
	echo "ERROR: failed to pushd $DIR}."
	exit 1
}

trap 'popd >/dev/null 2>&1' 0
trap "exit 2" 1 2 3 13 15

echo "INFO: Deleting all environements an their contents ..."
ansible-playbook -vv delete-devops-environments-playbook.yml || {
	echo "ERROR: Failed to delete all environments."
	exit 1
}
echo -e "\nINFO: OpenShift services =================================================================================\n"
oc get services --all-namespaces

echo -e "\nINFO: OpenShift pods =====================================================================================\n"
oc get pods --all-namespaces

echo -e "\nINFO: Dropping Estafet Microservice Scrum application databases ..."
ansible-playbook -vv drop-postgres-databases-playbook.yml || {
	echo "ERROR: Failed to drop the application databases."
	exit 1
}

echo -e "\nINFO: Creating Estafet Microservice Scrum application databases ..."
ansible-playbook -vv create-postgres-databases-playbook.yml || {
	echo "ERROR: Failed to initalise the application databases."
	exit 1
}

echo -e "\nINFO: Reset the Estafet Microservices Scrum applications and databases OK."
