# Estafet Microservices Scrum Demo Application
The scrum demo application is built upon microservices and provides a tangible example of how microservices are implemented to address common application aspects, such as data management, stateful domain objects and reporting. It is a useful starting point for a Java engineer who is interesting in understanding how microservices are built.

The application is designed to be deployed within an Openshift cluster and provides a convenient platform for demonstrating other aspects such as logging, monitoring, release management and testing.

We chose a scrum application for the demo because it is a business domain that pretty much everybody in the company understands. I did simplify some of the behaviour to limit the scope, but the core elements of scrum, such as project backlogs, stories, tasks, sprints, scrum boards and of course project burndown and sprint burndown reports exist.
## Structure
One thing to note is that each microservice has its own git repository. If all of the microservices are stored in a single repository there is a risk that they could be unintentionally recoupled. Separate repositories means that each service has its own specific lifecycle and can also be released independently (an important aspect for microservices). 

This can cause a management headache, as the number of microservices grow. Fortunately git provides a neat solution to this problem in the form of submodules. 

| Repository        | Description |
| ----------------- |-------------|
| [estafet-microservices-scrum](https://github.com/Estafet-LTD/estafet-microservices-scrum)| Master repository containing submodules for all microservices of the demo application. |
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


##### Wildfly


##### JBoss A-MQ




## Architecture

![alt tag](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/PodComponents.png)









