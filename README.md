# Estafet Microservices Scrum Demo Application
The scrum demo application is composed of microservices and provides a example of how microservices implement common application aspects, such as data management, stateful domain objects and reporting in a distributed architecture. It is a useful starting point for a Java engineer who is interesting in understanding how microservices are built.

The application is designed to be deployed within an Openshift cluster and provides a convenient platform for demonstrating aspects such as logging, monitoring, release management and testing for microservices.
## Structure
One thing to note is that each microservice has its own git repository. If all of the microservices are stored in a single repository there is a risk that they could be unintentionally recoupled. Separate repositories means that each service has its own specific lifecycle and can also be released independently (an important aspect for microservices). 

This can cause a management headache, as the number of microservices grow. Fortunately git provides a neat solution to this problem in the form of submodules. 

| Repository        | Description |
| ----------------- |-------------|
| [estafet-microservices-scrum-api-project](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-project) | Microservices for managing scrum projects. |
| [estafet-microservices-scrum-api-project-burndown](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-project-burndown) | Microservices for aggregating and generating project burndown reports. |
| [estafet-microservices-scrum-api-sprint](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-sprint) | Microservices for managing sprints. |
| [estafet-microservices-scrum-api-sprint-board](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-sprint-board) | Microservices for aggregating and rendering a sprint board. |
| [estafet-microservices-scrum-api-sprint-burndown](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-sprint-burndown) | Microservices for aggregating and generating sprint burndown reports. |
| [estafet-microservices-scrum-api-story](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-story) | Microservices for managing stories. |
| [estafet-microservices-scrum-api-task](https://github.com/Estafet-LTD/estafet-microservices-scrum-api-task) | Microservices for managing tasks. |
| [estafet-microservices-scrum-basic-ui](https://github.com/Estafet-LTD/estafet-microservices-scrum-basic-ui) | Basic User Interface that uses the scrum microservices. |
## Getting started
The entire application can be cloned in one go by recursively cloning the master repository.

```
git clone --recursive https://github.com/Estafet-LTD/estafet-microservices-scrum.git
```

There are a couple of installation options for the demo application:

* Deployment to an Openshift Cluster
* Deployment to local application server (JBoss EAP and Wildfly are supported out-of-the-box).

### Openshift Installation

tbd

### Local Installation
Review the prerequities for the local installation for continuing.

1. Change to the root directory for of the repository.
2. Set all of the environment variables.
    
    ```
    $ ./setallenv.sh
    ```
    
3. Create the databases for each of the microservices 
    
    ```
    $ sudo su postgres
    bash-4.2$ createdb project-api
    bash-4.2$ createdb sprint-api
    bash-4.2$ createdb story-api
    bash-4.2$ createdb task-api
    bash-4.2$ createdb project-burndown
    bash-4.2$ createdb sprint-burndown
    ```
    
4. Generate all of the database schemas
    
    ```
    ./drop-create-all-db.sh
    ```
    
5. deploy all of the microservices

    ```
    ./deploy-all-services.sh
    ```
    
You can now access the application using the following url:

http://localhost:8080/projects

#### Prerequisites
Before installing the application you'll need to have a installed PostgreSQL, Wildfly (or JBoss EAP) and JBoss A-MQ (or ActiveMQ). If you choose to install the application on a different application server (other than Wildfly or JBoss EAP), you'll need to modify the source to change the context route of each application. 
##### PostgreSQL
Note:- You need to create a password for the postgres db user. The environment scripts default to "welcome1".

* [Linux Installation Guide](https://www.linode.com/docs/databases/postgresql/how-to-install-postgresql-relational-databases-on-centos-7)
* [Windows Installation Guide](https://labkey.org/Documentation/wiki-page.view?name=installPostgreSQLWindows)
##### Java 8

* You can download java 8 from [here](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

##### Wildfly
* [Wildfly installation for windows](http://wwu-pi.github.io/tutorials/lectures/eai/010_tutorial_jboss_setup.html)
* [Wildfly installation generic](https://docs.jboss.org/author/display/WFLY10/Getting+Started+Guide#GettingStartedGuide-Installation)

Create an environment variable for the installation directory so that the deployment scripts can work.

```
export WILDFLY_INSTALL={some directory}
```

##### JBoss A-MQ

* How can download the A-MQ from [here](https://developers.redhat.com/products/amq/download/)
* After you've installed A-MQ, you'll need to setup a user name and password. The environment scripts default to estafet/estafet.
* You can define a guide for setting up credentials for A-MQ (here)[https://developers.redhat.com/products/amq/hello-world/]

## Architecture
The application consists of 7 microservices + the user interface. These are deployed to openshift as pods. The postgres pod instance contains 6 databases, each "owned" by a microservice. The A-MQ broker processes messages sent to topics.

![alt tag](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/PodComponents.png)

### Domain Model
Here's the overall business domain model.

![alt tag](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/UnboundedDomainModel.png)








