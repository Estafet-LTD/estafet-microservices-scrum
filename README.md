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

> Note:-  If you are working with a forked repository, you must fork all the sub modules and make sure that your fork
> does not update [the original GitHub repository](https://github.com/Estafet-Ltd/estafet-microservices-scrum "The original GitHub repository")

Each microservice has its own Git repository. Separate Git repositories allow each service to be released independently.

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

#### OpenShift

There are three ways of installing OpenShift on a laptop for development:

* Use Minishift (See The [MINISHIFT.md](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/MINISHIFT.md).
* "oc cluster up (See this [Medium article](https://medium.com/@fabiojose/working-with-oc-cluster-up-a052339ea219 "Medium article"))
* Install OKD on your laptop (see this [YouTube video](https://youtu.be/ZkFIozGY0IA) "YouTube video")

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

For Debian-based distributions:

```
$ sudo apt-get install python-jmespath
```

For Red Hat-based distributions:

```
$ sudo yum -y install python-jmespath
```

#### Openshift
The ansible playbook assumes that you have installed Openshift on your local development machine. If this is not the case, you will need to amend the ansible `create-local-environment-vars.yml` or `create-devops-environments-vars.yml` file (depending on which environment you are installing) and modify the `openshift: 192.168.99.100:8443` directive.

#### Minishift

The local environment can be run on [Minishift](https://docs.okd.io/latest/minishift/index.html "Minishift Homepage"). To install and configure
Minishift, please see the [Minishift ReadMe](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/MINISHIFT.md "Minishift Readme") file.

#### Openshift CLI (oc)
The playbook also assumes that the Openshift CLI `oc` is installed on the same machine that you have installed Ansible on. If this is not the case, you will need to amend the Ansible `microservices-scrum.yml` file and modify the `hosts: localhost` directive.

##### Windows Users
Windows users will need to install the Openshift CLI onto WSL for linux so that the ansible scripts can run. They will also need to copy the kuberenetes credentials from the windows to WSL. This will alllow the ansible script perform certain operations as the system administrator.

```
cp /mnt/c/Users/<Windows User>/.kube/config ~/.kube
```

### Local Environment Setup

The local environment is intended for development purposes, e.g. on a user's laptop.

Installing and configuring the scrum demo application to openshift manually is a lengthy process. There are 13 applications in total (8 microservices + db + jaeger + message broker). Fortunately this process has been automated using Ansible.

#### Steps

##### Step #1
Clone the master repository to a directory of your choice.

```
$ git clone --recurse-submodules https://github.com/Estafet-LTD/estafet-microservices-scrum.git
$ git checkout master
$ git submodule foreach 'git checkout master || :'
$
```

##### Step #2
Create an inventory file:

```
$ cd estafet-microservices-scrum/ansible
$ cp inventory.template inventory
$ vi iniventory
localhost ansible_connection=local openshift=192.168.42.34:8443
```

If you are using Minishift, the `openshift` value is taken from the output of starting minishift (see the [Minishift README](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/MINISHIFT.md)):

```
OpenShift server started.

The server is accessible via web console at:
    https://192.168.42.34:8443/console

```

Otherwise, the value is the public IP or DNS address of the Master OpenShift node.

#### Step 3
Run the playbook. The playbook takes about 15 mins complete.

> Note:- If you are using Minishift, you set the Minishift configuration to specify the resources available. (see the [Minishift README](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/MINISHIFT.md#configuration)).

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

Please refer to [DEVOPS.md](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/DEVOPS.md)

## Environments

The environments are:

* **local dev**: Runs on the developer's laptop. Supports development on a laptoop.
* **local tes**: Runs on the developer's laptop. Supports development and testing on a laptoop.
* **dev**: Runs in AWS. When a devloper pushes changes to GitHub, A GitHub Webhook ensures that the changes are autmatically
built the `dev` environment,
* **test**: Runs in AWS. A Jenkins pipeline promotes changes from the `dev` environment to the `test` environment and
runs automated integration tests.
* **prod**: Runs in AWS. A Jenkins pipeline promotes changes from the `test` environment to the `prod` environment.

## Architecture
The application consists of 9 microservices + the user interface. These are deployed to openshift as pods. The postgres pod instance contains 6 databases, each "owned" by a microservice. The A-MQ broker processes messages sent to topics and distributes these to microservices that have subscribedtothose topics.

![alt tag](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/md_images/readme/PodComponents.png)

### Domain Model
Here's the overall business domain model.

![alt tag](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/md_images/readme/UnboundedDomainModel.png)

## Distributed Monitoring
Here's a short summary of the Opentracing and Jaeger with microservices.

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/EdFYvUBaKbY/0.jpg)](https://www.youtube.com/watch?v=EdFYvUBaKbY)

This is a more detailed walkthrough of the scrum demo application and it's integration with Jaeger.

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/U04MzSGzF3s/0.jpg)](https://www.youtube.com/watch?v=U04MzSGzF3s)