# Deploying the Scrum Application to Openshift
Installing and configuring the scrum demo application to openshift manually is a lengthy process. There are 11 applications in total (8 microservices + db + jaeger + message broker). Fortunately this process has been automated using Ansible.

## Prerequisites
Please review the prerequisites below before continuing with the deployment steps:

### Ansible
Ansible is installed as a linux application, but it is possible to install it on Windows 10 and Mac OS X machines.

#### Windows Users
Windows users will need to install ansible using Windows Subsytem for Linux (WSL). For instructions on how to install anisble on a Window 10 machine, please refer to this excellent article.

https://www.jeffgeerling.com/blog/2017/using-ansible-through-windows-10s-subsystem-linux

#### MAC OS X Users
Mac users can easily install ansible provided homebrew isinstalled. For a comprehensive description, please consult this article. 

https://hvops.com/articles/ansible-mac-osx/

#### Additional Python Library
The ansible playbook requires a python module that is not always installed with the standard ansible distributions.

```
sudo apt-get install python-jmespath
```

### Openshift
The ansible playbook assumes that you have installed Openshift on your local development machine. If this is not the case, you will need to amend the ansible `vars.yml` file and modify the `openshift: 192.168.99.100:8443` directive.

### Openshift CLI (oc)
The playbook also assumes that the Openshift CLI `oc` is installed on the same machine that you have installed Ansible on. If this is not the case, you will need to amend the Ansible `microservices-scrum.yml` file and modify the `hosts: localhost` directive.

## Steps

### Step #1
Clone the master repository to a directory of your choice.

```
git clone https://github.com/Estafet-LTD/estafet-microservices-scrum.git
```

### Step #2
Run the playbook. The playbook takes about 20 mins complete.

> Note:- If you are using minishift, it might be advisible to tweak the resources available.

```
$ cd estafet-microservices-scrum/setup-openshift-deployment
$ ansible-playbook microservices-scrum.yml

```

## Reseting application data
You can reset the application data by executing the following playbook. This will redeploy all of database dependent microservices so it takes about a 30 seconds to complete.

```
ansible-playbook reset-data.yml

```



