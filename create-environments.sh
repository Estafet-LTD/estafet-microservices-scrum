#!/usr/bin/env bash

sudo su

apt-get install python-jmespath

git clone https://github.com/Estafet-LTD/estafet-microservices-scrum.git

# Run the playbook.
ANSIBLE_HOST_KEY_CHECKING=False /usr/local/bin/ansible-playbook -i ./environments-inventory.cfg ./estafet-microservices-scrum/ansible/create-devops-environments-playbook.yml