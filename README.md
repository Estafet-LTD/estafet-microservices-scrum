# Estafet Microservices Scrum Demo Application
The scrum demo application is composed of microservices and provides a example of how microservices implement common application aspects, such as data management, stateful domain objects and reporting in a distributed architecture. It is a useful starting point for a Java engineer who is interesting in understanding how microservices are built.

The application is designed to be deployed within an Openshift cluster and provides a convenient platform for demonstrating aspects such as logging, monitoring, release management and testing for microservices.

## Contents

* [Project Structure](https://github.com/Estafet-LTD/estafet-microservices-scrum#project-structure)
* [Getting Started](https://github.com/Estafet-LTD/estafet-microservices-scrum#getting-started)
* [Architecture](https://github.com/Estafet-LTD/estafet-microservices-scrum#architecture)
* [Distributed Tracing with Jaegar](https://github.com/Estafet-LTD/estafet-microservices-scrum#distributed-tracing-with-jaegar)

## Project Structure
One thing to note is that each microservice has its own git repository. Separate repositories means that each service be released independently. 

| Repository        | Description |
| ----------------- |-------------|
| [estafet-microservices-scrum-qa](https://github.com/Estafet-LTD/estafet-microservices-scrum-qa) | Cross cutting Quality Assurance tests. |
| [estafet-microservices-scrum-api-discovery](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-discovery) | Service Discovery for microservices. |
| [estafet-microservices-scrum-api-gateway](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-gateway) | Microservices API Gateway. |
| [estafet-microservices-scrum-api-project](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-project) | Microservices for managing scrum projects. |
| [estafet-microservices-scrum-api-project-burndown](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-project-burndown) | Microservices for aggregating and generating project burndown reports. |
| [estafet-microservices-scrum-api-sprint](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-sprint) | Microservices for managing sprints. |
| [estafet-microservices-scrum-api-sprint-board](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-sprint-board) | Microservices for aggregating and rendering a sprint board. |
| [estafet-microservices-scrum-api-sprint-burndown](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-sprint-burndown) | Microservices for aggregating and generating sprint burndown reports. |
| [estafet-microservices-scrum-api-story](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-story) | Microservices for managing stories. |
| [estafet-microservices-scrum-api-task](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-task) | Microservices for managing tasks. |
| [estafet-microservices-scrum-basic-ui](https://github.com/Estafet-LTD/estafet-microservices-scrum-basic-ui) | Basic User Interface that uses the scrum microservices. |
## Getting started
There are a couple of installation options for the demo application:

* [Local Environment Setup to Openshift](https://github.com/Estafet-LTD/estafet-microservices-scrum#local-setup)
* [Cloud Paas Setup](https://github.com/Estafet-LTD/estafet-microservices-scrum#cloud-paas-setup)

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
The ansible playbook assumes that you have installed Openshift on your local development machine. If this is not the case, you will need to amend the ansible `microservices-scrum-vars.yml` file and modify the `openshift: 192.168.99.100:8443` directive.

#### Openshift CLI (oc)
The playbook also assumes that the Openshift CLI `oc` is installed on the same machine that you have installed Ansible on. If this is not the case, you will need to amend the Ansible `microservices-scrum.yml` file and modify the `hosts: localhost` directive.

### Local Setup
Installing and configuring the scrum demo application to openshift manually is a lengthy process. There are 13 applications in total (8 microservices + db + jaeger + message broker). Fortunately this process has been automated using Ansible.

#### Steps

##### Step #1
Clone the master repository to a directory of your choice.

```
git clone https://github.com/Estafet-LTD/estafet-microservices-scrum.git
```

##### Step #2
Run the playbook. The playbook takes about 20 mins complete.

> Note:- If you are using minishift, it might be advisible to tweak the resources available.

```
$ cd estafet-microservices-scrum
$ ansible-playbook microservices-scrum.yml

```

#### Reseting application data
You can reset the application data by executing the following playbook. This will redeploy all of database dependent microservices so it takes about a 30 seconds to complete.

```
ansible-playbook reset-data.yml

```

### Cloud Paas Setup
tbc...

## Architecture
The application consists of 9 microservices + the user interface. These are deployed to openshift as pods. The postgres pod instance contains 6 databases, each "owned" by a microservice. The A-MQ broker processes messages sent to topics and distributes these to microservices that have subscribedtothose topics.

![alt tag](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/Estafet-Scrum-App-Gateway_V2.PNG)

### Domain Model
Here's the overall business domain model.

![alt tag](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/UnboundedDomainModel.png)

## Distributed Tracing with Jaegar
Here's a short summary of the Opentracing and Jaeger with microservices.

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/EdFYvUBaKbY/0.jpg)](https://www.youtube.com/watch?v=EdFYvUBaKbY)

This is a more detailed walkthrough of the scrum demo application and it's integration with Jaeger.

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/U04MzSGzF3s/0.jpg)](https://www.youtube.com/watch?v=U04MzSGzF3s)







