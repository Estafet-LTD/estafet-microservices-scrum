#!/bin/bash

tmpdir="/tmp/test-$$"
oc_client_file="openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz"
oc_file="${tmpdir}/oc"
kubectl_file="${tmpdir}/kubectl"

function cleanup() {
  [[ -e "${tmpdir}" ]] && rm -rf "${tmpdir}"
  [[ -e "${oc_client_file}" ]] && rm -f "${oc_client_file}"
}

trap 'cleanup >/dev/null 2>&1' 0
trap "exit 2" SIGHUP SIGINT SIGQUIT SIGPIPE SIGTERM

function install_dev_tools() {
  echo "INFO: Installing developmment tools ..."
  # Install dev tools.
  yum install -y "@Development Tools" python2-pip openssl-devel python-devel gcc libffi-devel || {
    echo "ERROR: failed to install development tools."
    return 1
  }
}

function install_postgresql() {
  echo "INFO: Installing PostgreSQL ..."
  yum install -y postgresql-devel || {
    echo "ERROR: failed to install postgresql-devel."
    return 1
  }
}

function install_ansible() {
  echo "INFO: Installing Ansible 2.6.5 ..."
  pip install -I ansible==2.6.5 || {
    echo "ERROR: failed to install Ansible."
    return 1
  }
}

function insall_psycopg2() {
  echo "INFO: Installing psycopg2 ..."
  pip install psycopg2 || {
    echo "ERROR: failed to install psycopg2."
    return 1
  }
}

function install_oc_client_tools() {
  local oc_version="v3.11.0"

  echo "INFO: Installing OpenShift Client Tools ${oc_version} ..."
  if [[ -e "${oc_client_file}" ]]; then
    rm -f "${oc_client_file}"
  fi

  local oc_github_url="https://github.com/openshift/origin/releases/download"
  local oc_url="${oc_github_url}/${oc_version}/${oc_client_file}"
  local curl_result=
  curl_result="$(curl -k -Ss -w "%{http_code}" -LJO "${oc_url}")"

  ((status=$?))
  if [[ ${status} -ne 0 ]];then

    echo "ERROR: Failed to download ${oc_client_file} from ${oc_url}. curl status code is ${status}."
    return 1
  fi

  if [[ "${curl_result}" != "200" ]]; then

    echo "ERROR: Failed to download ${oc_client_file} from ${oc_url}. HTTP status code is ${curl_result}."
    return 1
  fi

  mkdir -p "${tmpdir}"

  tar zxf "${oc_client_file}" --strip-components=1 -C "${tmpdir}" || {
    echo "ERROR: failed to extract ${oc_client_file}."
    return 1
  }

  chmod 777 "${oc_file}"
  chmod 777 "${kubectl_file}"

  mv "${oc_file}" /usr/local/bin
  mv "${kubectl_file}" /usr/local/bin
}

function clone_github_repo() {
  local repo="estafet-microservices-scrum"
  local github_url="https://github.com/stericbro/${repo}"

  [[ -e "${repo}" ]] && rm -rf "${repo}"

  echo "INFO: Cloning Estafet Microservices Scrum Demo from  ${github_url} ..."
  git clone "${github_url}" || {
    echo "ERROR: Failed to clone  ${repo} from ${github_url}"
    return 1
  }

  chown -R ec2-user:ec2-user "${repo}"
}

function install_database() {
  echo "INFO: Installing Estafet Microservices Scrum Demo PostgreSQL database ..."

  # Run the playbook.
  ANSIBLE_HOST_KEY_CHECKING=False /usr/local/bin/ansible-playbook -i ./rds-inventory.cfg ./estafet-microservices-scrum/ansible/init-postgres-databases-playbook.yml || {
    echo "ERROR: Failed install the Estafet Microservices Scrum demo database."
    return 1
  }
}

function clone_openshift_ansible() {
  local repo="openshift-ansible"
  local github_url="https://github.com/openshift/${repo}"
  local version="3.11"
  echo "INFO: Cloning version ${version} of ${repo} from ${github_url} ..."

  [[ -e "${repo}" ]] && rm -rf "${repo}"

  # Get the OpenShift installer.
  git clone -b release-${version} "${github_url}" || {
    echo "ERROR: failed to clone  version ${version} of ${repo} from ${github_url}"
    return 1
  }

  chown -R ec2-user:ec2-user "${repo}"
}

function install_ansible() {
  echo "INFO: Installing OpenShift ..."
  echo "INFO: Checking OpenShift prerequisites ..."
  ANSIBLE_HOST_KEY_CHECKING=False /usr/local/bin/ansible-playbook -i ./inventory.cfg ./openshift-ansible/playbooks/prerequisites.yml || {
    echo "ERROR: Ansible prerequisites failed."
    return 1
  }
  echo "INFO: Deploying OpenShift cluster ..."
  ANSIBLE_HOST_KEY_CHECKING=False /usr/local/bin/ansible-playbook -i ./inventory.cfg ./openshift-ansible/playbooks/deploy_cluster.yml || {
    echo "ERROR: Failed to deploy OpenShift cluster."
    return 1
  }

  echo "INFO: Intalled OpenShift OK."
}

# Elevate privileges, retaining the environment.
sudo -E su

install_dev_tool || exit 1
install_postgresql || exit 1
install_ansible || exit 1
insall_psycopg2 || exit 1
install_oc_client_tools || exit 1
clone_github_repo || exit 1
install_database || exit 1
clone_openshift_ansible || exit 1
install_ansible || exit 1

# If needed, uninstall with the below:
# ansible-playbook playbooks/adhoc/uninstall.yml