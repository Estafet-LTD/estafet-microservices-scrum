# Openshift Microservices Scrum Demo Application
The scrum demo application is composed of microservices and provides a example of how microservices implement common application aspects, such as data management, stateful domain objects and reporting in a distributed architecture. It is a useful starting point for a Java engineer who is interesting in understanding how microservices are built.

The application is designed to be deployed within an Openshift cluster and provides a convenient platform for demonstrating aspects such as logging, monitoring, release management and testing for microservices.

## Contents

* [Project Structure](https://github.com/Estafet-LTD/estafet-microservices-scrum#project-structure)
* [Getting Started](https://github.com/Estafet-LTD/estafet-microservices-scrum#getting-started)
* [Environments](https://github.com/Estafet-LTD/estafet-microservices-scrum#environments)
* [Architecture](https://github.com/Estafet-LTD/estafet-microservices-scrum#architecture)
* [Distributed Monitoring](https://github.com/Estafet-LTD/estafet-microservices-scrum#distributed-monitoring)

## Project Structure
One thing to note is that each microservice has its own git repository. Separate repositories means that each service be released independently. 

| Repository        | Description |
| ----------------- |-------------|
| [estafet-microservices-scrum-api-project](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-project) | Microservices for managing scrum projects. |
| [estafet-microservices-scrum-api-project-burndown](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-project-burndown) | Microservices for aggregating and generating project burndown reports. |
| [estafet-microservices-scrum-api-sprint](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-sprint) | Microservices for managing sprints. |
| [estafet-microservices-scrum-api-sprint-board](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-sprint-board) | Microservices for aggregating and rendering a sprint board. |
| [estafet-microservices-scrum-api-sprint-burndown](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-sprint-burndown) | Microservices for aggregating and generating sprint burndown reports. |
| [estafet-microservices-scrum-api-story](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-story) | Microservices for managing stories. |
| [estafet-microservices-scrum-api-task](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-task) | Microservices for managing tasks. |
| [estafet-microservices-scrum-api-discovery](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-discovery) | Service Discovery for microservices. |
| [estafet-microservices-scrum-api-gateway](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-gateway) | Microservices API Gateway. |
| [estafet-microservices-scrum-basic-ui](https://github.com/Estafet-LTD/estafet-microservices-scrum-basic-ui) | Basic User Interface that uses the scrum microservices. |
| [estafet-microservices-scrum-lib](https://github.com/Estafet-LTD/estafet-microservices-scrum-lib) | Shared Libraries |
| [estafet-microservices-scrum-qa](https://github.com/Estafet-LTD/estafet-microservices-scrum-qa) | Cross cutting Quality Assurance tests. |

## Getting started
There are a couple of installation options for the demo application:

* [Local Environment Setup](https://github.com/Estafet-LTD/estafet-microservices-scrum#local-environment-setup)
* [Local Test Environment Setup](https://github.com/Estafet-LTD/estafet-microservices-scrum#test-environment-setup)
* [DevOps Environment Setup](https://github.com/Estafet-LTD/estafet-microservices-scrum#devops-environment-setup)

### Prerequisites
Please review the prerequisites below before continuing with the deployment steps:

#### Ansible
Ansible is installed as a linux application, but it is possible to install it on Windows 10 and Mac OS X machines.

##### Windows Users
Windows users will need to install ansible using Windows Subsytem for Linux (WSL). For instructions on how to install anisble on a Window 10 machine, please refer to this excellent article.

https://www.jeffgeerling.com/blog/2017/using-ansible-through-windows-10s-subsystem-linux

##### MAC OS X Users
Mac users can easily install ansible provided homebrew isinstalled. For a comprehensive description, please consult this article. 

https://hvops.com/articles/ansible-mac-osx/

##### Additional Python Library
The ansible playbook requires a python module that is not always installed with the standard ansible distributions.

```
sudo apt-get install python-jmespath
```

#### Openshift
The ansible playbook assumes that you have installed Openshift on your local development machine. If this is not the case, you will need to amend the ansible `create-local-environment-vars.yml` or `create-devops-environments-vars.yml` file (depending on which environment you are installing) and modify the `openshift: 192.168.99.100:8443` directive.

#### Openshift CLI (oc)
The playbook also assumes that the Openshift CLI `oc` is installed on the same machine that you have installed Ansible on. If this is not the case, you will need to amend the Ansible `microservices-scrum.yml` file and modify the `hosts: localhost` directive.

##### Windows Users
Windows users will need to install the Openshift CLI onto WSL for linux so that the ansible scripts can run. They will also need to copy the kuberenetes credentials from the windows to WSL. This will alllow the ansible script perform certain operations as the system administrator.

```
cp /mnt/c/Users/<Windows User>/.kube/config ~/.kube
```

### Local Environment Setup
Installing and configuring the scrum demo application to openshift manually is a lengthy process. There are 13 applications in total (8 microservices + db + jaeger + message broker). Fortunately this process has been automated using Ansible.

#### Steps

##### Step #1
Clone the master repository to a directory of your choice.

```
git clone https://github.com/Estafet-LTD/estafet-microservices-scrum.git
```

##### Step #2
Run the playbook. The playbook takes about 15 mins complete.

> Note:- If you are using minishift, it might be advisible to tweak the resources available (see below).

```
$ cd estafet-microservices-scrum/ansible
$ ansible-playbook create-local-environment-playbook.yml
```

###### Minishift specifics (Linux Only)
To remove your minshift installation in preparation to rebuild:

```
$ minishift delete && rm -rf ~/.minishift
```

To build minishift and get the scrum demo up and running:

```
$ minishift start --memory 6GB && ansible-playbook create-local-environment-playbook.yml --extra-vars=@overrides.yml
```

> Note:- The default 4GB of ram is not sufficient to get all up and running, also the '--extra-vars=@overrides.yml' is required for versions of Openshift > 3.0 (this relates to the command for setting env vars only)

The IP of the minishift instance is detected in the Ansible playbook 'create-local-environment-playbook.yml' if the 'openshift' variable is not provided. To override this, supply the 'openshift' variable in file `create-local-environment-vars.yml` by uncommenting the 'openshift' variable definition line and supplying the correct ip address.

#### Reseting application data
You can reset the application data by executing the following playbook. This will redeploy all of database dependent microservices so it takes about a 30 seconds to complete.

```
ansible-playbook reset-data-playbook.yml
```

### Test Environment Setup
Click [here](https://github.com/Estafet-LTD/estafet-microservices-scrum-qa#test-environment-setup) to find the test environment setup details.

### DevOps Environment Setup
The local environment setup allows a developer start using the microservices application, but in order to set up a project, we'll need to create a development, test, continuous integration and project environment. These environments will need CICI pipelines, artifact repositories, code analysis and all of the automation associated with DevOps. Fortunately, this can be setup with running a single script.

#### Steps

##### Step #1
Clone the master repository to a directory of your choice.

```
git clone https://github.com/Estafet-LTD/estafet-microservices-scrum.git
```

##### Step #2
Run the playbook. The playbook takes about 30 mins complete.

> Note:- If you are using minishift, it might be advisible to tweak the resources available.

```
$ cd estafet-microservices-scrum/ansible
$ ansible-playbook create-devops-environments-playbook.yml
```

##### Step #3
Jenkins setup 
tbc...

##### Setting Up Maven Locally to Use Nexus
tbc...

## Environments
tbc...

## Architecture
The application consists of 9 microservices + the user interface. These are deployed to openshift as pods. The postgres pod instance contains 6 databases, each "owned" by a microservice. The A-MQ broker processes messages sent to topics and distributes these to microservices that have subscribedtothose topics.

![alt tag](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/PodComponents.png)

### Domain Model
Here's the overall business domain model.

![alt tag](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/UnboundedDomainModel.png)

## Distributed Monitoring
Here's a short summary of the Opentracing and Jaeger with microservices.

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/EdFYvUBaKbY/0.jpg)](https://www.youtube.com/watch?v=EdFYvUBaKbY)

This is a more detailed walkthrough of the scrum demo application and it's integration with Jaeger.

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/U04MzSGzF3s/0.jpg)](https://www.youtube.com/watch?v=U04MzSGzF3s)







