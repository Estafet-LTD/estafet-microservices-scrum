# Estafet Microservices Scrum Demo Application
The scrum demo application is composed of microservices and provides a example of how microservices implement common application aspects, such as data management, stateful domain objects and reporting in a distributed architecture. It is a useful starting point for a Java engineer who is interesting in understanding how microservices are built.

The application is designed to be deployed within an Openshift cluster and provides a convenient platform for demonstrating aspects such as logging, monitoring, release management and testing for microservices.

## Contents

* [Project Structure](https://github.com/Estafet-LTD/estafet-microservices-scrum#project-structure)
* [Getting Started](https://github.com/Estafet-LTD/estafet-microservices-scrum#getting-started)
* [Architecture](https://github.com/Estafet-LTD/estafet-microservices-scrum#architecture)
* Distributed Tracing with Jaegar

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
| [estafet-microservices-scrum-basic-ui](https://github.com/Estafet-LTD/estafet-microservices-scrum-basic-ui) | Basic User Interface that uses the scrum microservices. |
## Getting started
There are a couple of installation options for the demo application:

* Deployment to an Openshift Cluster
* Deployment to local application server (JBoss EAP and Wildfly are supported out-of-the-box).

### Openshift Installation
The openshift deployment is based on ansible. You can find the instructions [here.](https://github.com/Estafet-LTD/estafet-microservices-scrum/tree/master/setup-openshift-deployment)

### Local Installation
If you do not want to deploy this application to openshift, you can still run this. You can find the sintructions here.

## Architecture
The application consists of 7 microservices + the user interface. These are deployed to openshift as pods. The postgres pod instance contains 6 databases, each "owned" by a microservice. The A-MQ broker processes messages sent to topics.

![alt tag](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/PodComponents.png)

### Domain Model
Here's the overall business domain model.

![alt tag](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/UnboundedDomainModel.png)

## Distributed Tracing with Jaegar

tbd








