set -x

# Elevate priviledges, retaining the environment.
sudo -E su

# Install dev tools.
yum install -y "@Development Tools" python2-pip openssl-devel python-devel gcc libffi-devel

yum install -y postgresql-devel
pip install -I ansible==2.6.5
pip install psycopg2

git clone https://github.com/Estafet-LTD/estafet-microservices-scrum

# Run the playbook.
ANSIBLE_HOST_KEY_CHECKING=False /usr/local/bin/ansible-playbook -i ./rds-inventory.cfg ./estafet-microservices-scrum/ansible/init-postgres-databases-playbook.yml