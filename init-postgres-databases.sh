set -x

# Elevate priviledges, retaining the environment.
sudo -E su

pip install -I ansible==2.6.5
git clone https://github.com/Estafet-LTD/estafet-microservices-scrum

sudo yum install gcc python27 python27-devel postgresql-devel
sudo curl https://bootstrap.pypa.io/ez_setup.py -o - | sudo python27
sudo /usr/bin/easy_install-2.7 pip
sudo pip2.7 install psycopg2

# Run the playbook.
ANSIBLE_HOST_KEY_CHECKING=False /usr/local/bin/ansible-playbook -i ./rds-inventory.cfg ./estafet-microservices-scrum/ansible/init-postgres-databases-playbook.yml