#!/usr/bin/env bash

# This script creates the OKD amdin user and updates the docker configuration to allow OKD's local insecure registry.
#
# This script must run only on master nodes. Use postinstall-node.sh on compute nodes.
#
# Note: This script runs after the Ansible install; use it to make configuration
# changes which would otherwise be overwritten by Ansible.
#
# Also:
#     * Use json-file for logging, so our Splunk forwarder can eat the container logs.
#     * Limit the number of log files to 3.
#
# The docker config file looks like this:
#
#     /etc/sysconfig/docker
#
#      Modify these options if you want to change the way the docker daemon runs
#      OPTIONS=' --selinux-enabled       --signature-verification=False'
#      if [ -z "${DOCKER_CERT_PATH}" ]; then
#           DOCKER_CERT_PATH=/etc/docker
#      fi

# Create an htpasswd file, we'll use htpasswd auth for OKD.
# Create the credentials for the OKD admin user.
function createAdminUser() {
    echo "INFO: Creating the OKD admin user ..."
    htpasswd -cb /etc/origin/master/htpasswd admin 123 || {
        echo "ERROR: Failed to create the OKD Admin user."
        return 1
    }

    echo "INFO: Password for 'admin' set to '123'."
}

function give_cluster_admin_role_to_admin() {
    echo "INFO: Granting the cluster-admin role to the admins user ..."
    sudo oc adm policy add-cluster-role-to-user cluster-admin admin --rolebinding-name=cluster-admin || {
    echo "ERROR: failed to grant cluster-admin role to the admin user."
    return 1
  }

    echo "INFO: The 'admin' user has the cluster-admin role."
}

# Find the OPTIONS=' ... ' line and echo the value.
function getCurrentDockerOptions() {

    declare options=

    while IFS= read -r line
    do
        # This removes $options_key from the start of $line if $line starts with $options_key.
        # Otherwise, $line is unchanged.
        options="${line#${options_key}=}"
        if [[ "${line}" != "${options}" ]]; then

            # Remove any leading or trailing single quotes.
            options=${options#\'}
            options=${options%\'}
            echo "${options}"
            return 0
        fi
    done < "${docker_config_file}"
    return 1
}

# Check if the named array does not contain the given string.
#
# $1: The name of the array to search.
# $2: The string to search for.
#
# Returns: 0 if the search string is not in the named array. Otherwise, 1.
function array_does_not_contain() {
    local array="$1[@]"
    local search_string="$2"

    local element=
    for element in "${!array}"; do
        if [[ "${element}" == "${search_string}" ]]; then
            return 1
        fi
    done
    return 0
}

# Create the new docker options.
#
# The updated options must be enclosed in single quotes.
#
# $1: The name of the array of existing options.
# $2: The name of the array of updated options.
#
function update_docker_options() {
    local -a updated_options=()
    local current_options="$1[@]"
    local additional_options="$2[@]"

    updated_options+=("${options_key}='")
    updated_options+=(${!current_options})

    local element=
    for element in "${!additional_options}"; do
        array_does_not_contain "$1" "${element}" && {
            updated_options+=("${element}")
        }
    done

    local value="${updated_options[*]}"

    # Lose the space after the 1st single quote.
    value="${value/=\' /=\'}"

    # lose trailing whitespace.
    value="${value%% }'"

    echo "${value}"
}

# Update the docker configuration.
#
# $updated_docker_options contains the updated docker optons.
# $docker_config_file is the path to the docker configuration file
function update_docker_configuration() {
    echo "INFO: Updating the Docker configuration in ${docker_config_file} ..."
    # sed command to replace line containing "OPTIONS="
    local sed_command="/${options_key}=.*/c\\\\${updated_docker_options}"
    sed -i "${sed_command}" "${docker_config_file}" || {
        echo "ERROR: Failed to update the Docker configuration in ${docker_config_file}."
        return 1
    }
    echo "INFO: Updated the Docker configuration in ${docker_config_file} OK."
}

# Stop the named service using the service command.
#
# $1: the name of the service
function stop_service() {
    local the_service="$1"

    echo "INFO: Stopping the ${the_service} service ..."

    chkconfig "${the_service}" || {
        echo "INFO: The ${the_service} service does not exist."
        return 0
    }

    service status "${the_service}" | grep -qc "running" || {
        echo "INFO: The ${the_service} service is not running."
        return 0
    }

    service stop "${the_service}" || {
        echo "ERROR: The ${the_service} service did not stop."
        return 1
    }
    echo "INFO: Stopped the ${the_service} service OK."
}

# Start the named service using the service command.
#
# $1: the name of the service
function start_service() {
    local the_service="$1"

    echo "INFO: Starting the ${the_service} service ..."

    chkconfig "${the_service}" || {
        echo "INFO: The ${the_service} service does not exist."
        return 0
    }

    service status "${the_service}" | grep -qc "running" && {
        echo "INFO: The ${the_service} service is already running."
        return 0
    }

    service start "${the_service}" || {
        echo "ERROR: The ${the_service} service did not start."
        return 1
    }
    echo "INFO: Started the ${the_service} service OK."
}

# Stop the named service using the systemctl command.
#
# $1: the name of the service
function stop_service_systemctl() {
    local the_service="${1}.service"

    echo "INFO: Stopping the $1 service ..."

    systemctl list-unit-files | grep -qc "${the_service}" || {
        echo "INFO: The $1 service does not exist."
        return 0
    }

    declare status=
    status="$(systemctl is-active "${the_service}")"

    echo "INFO: The status of the $1 service is \"${status}\"."

    if [[ "${status}" != "active" ]]; then
        echo "INFO: The $1 service is not running."
        return 0
    fi

    systemctl stop "${the_service}" || {
        echo "ERROR: The $1 service did not stop."
        return 1
    }
    echo "INFO: Stopped the $1 service OK."
}

# Start the named service using the systemctl command.
#
# $1: the name of the service
function start_service_systemctl() {
    local the_service="${1}.service"

    echo "INFO: Starting the $1 service ..."

    systemctl list-unit-files | grep -qc "${the_service}" || {
        echo "The $1 service does not exist."
        return 0
    }

    declare status=
    status="$(systemctl is-active "${the_service}")"

    echo "INFO: The status of the $1 service is \"${status}\"."

    if [[ "${status}" == "active" ]]; then
        echo "INFO: The $1 service is already running."
        return 0
    fi

    systemctl start "${the_service}" || {
        echo "ERROR: The $1 service did not start."
        return 1
    }
    echo "INFO: Started the $1 service OK."
}

function stop_services() {
    echo "INFO: Stopping services ..."
    ((errors=0))

    stop_service "api" || ((++errors))
    stop_service "controllers" || ((++errors))
    stop_service "docker" || ((++errors))

    [[ ${errors} -ne 0 ]] && {
        echo "ERROR: Some services failed to stop."
        return 1
    }
    echo "INFO: Stopped services OK."
}

function stop_services_systemctl() {
    echo "INFO: Stopping services ..."
    ((errors=0))

    stop_service_systemctl "api" || ((++errors))
    stop_service_systemctl "controllers" || ((++errors))
    stop_service_systemctl "docker" || ((++errors))

    [[ ${errors} -ne 0 ]] && {
        echo "ERROR: Some services failed to stop."
        return 1
    }
    echo "INFO: Stopped services OK."
}

function start_services() {
    echo "INFO: Starting services ..."
    ((errors=0))

    start_service "docker" || ((++errors))
    start_service "api" || ((++errors))
    start_service "controllers" || ((++errors))

    [[ ${errors} -ne 0 ]] && {
        echo "ERROR: Some services failed to start."
        return 1
    }
    echo "INFO: Started services OK."
}

function start_services_systemctl() {
    echo "INFO: Starting services ..."
    ((errors=0))

    start_service_systemctl "docker" || ((++errors))
    start_service_systemctl "api" || ((++errors))
    start_service_systemctl "controllers" || ((++errors))

    [[ ${errors} -ne 0 ]] && {
        echo "ERROR: Some services failed to start."
        return 1
    }
    echo "INFO: Started services OK."
}

docker_config_file="/etc/sysconfig/docker"
options_key="OPTIONS"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
NAME="$(basename "${BASH_SOURCE[0]}")"
HOSTNAME="$(hostname -f)"

echo "INFO: Running ${DIR}/${NAME} on ${HOSTNAME} ..."

# Elevate privileges and retain the ec2-user's environment.
#
# This only works when the script is run via ssh:
#
# e.g.:
#
#    - cat ./scripts/postinstall-master.sh | ssh -A ec2-user@ems-bastion.openshift.local ssh master.openshift.local
#
sudo -E su

echo "INFO: Updating packages ..."

yum -y update

createAdminUser || exit 1

give_cluster_admin_role_to_admin || exit 1

echo "INFO: Getting the current docker options ..."
current_docker_options=
current_docker_options="$(getCurrentDockerOptions)" || {
    echo "ERROR: Failed to get the current docker options."
    exit 1
}

# Put the current options into an array.
declare -a current_array=()
IFS=' ' read -r -a current_array <<< "${current_docker_options}"

# These are the additional options.
declare -a additional_array=()
additional_array+=("--selinux-enabled")
additional_array+=("--insecure-registry 172.30.0.0/16")
additional_array+=("--log-driver=json-file")
additional_array+=("--log-opt max-size=1M")
additional_array+=("--log-opt max-file=3")

# Merge the additional docker options with the current options.
echo "INFO: Updating docker options ..."
updated_docker_options=
updated_docker_options="$(update_docker_options "current_array" "additional_array")" || {
    echo "ERROR: Failed to update docker options."
    exit 1
}

# Update the docker configuration file.
update_docker_configuration || exit 1

echo "INFO: Restarting services ..."
systemctl >/dev/null 2>&1; declare -i status=$?

if [[ ${status} -eq 127 ]]; then
    # systemctl is not available.
    stop_services || exit 1
    start_services || exit 1
else
    # systemctl is available.
    stop_services_systemctl || exit 1
    start_services_systemctl || exit 1
fi
echo "INFO: Restarted services OK."