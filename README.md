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

* [Deployment to Openshift](https://github.com/Estafet-LTD/estafet-microservices-scrum/tree/master/setup-openshift-deployment)
* [Setting up a Development Environment](https://github.com/Estafet-LTD/estafet-microservices-scrum/tree/master/setup-development-environment)

## Architecture
The application consists of 7 microservices + the user interface. These are deployed to openshift as pods. The postgres pod instance contains 6 databases, each "owned" by a microservice. The A-MQ broker processes messages sent to topics and distributes these to microservices that have subscribedtothose topics.

![alt tag](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/PodComponents.png)

### Domain Model
Here's the overall business domain model.

![alt tag](https://github.com/Estafet-LTD/estafet-microservices-scrum/blob/master/UnboundedDomainModel.png)

## Distributed Tracing with Jaegar
Here's a short summary of the Opentracing and Jaeger with microservices.

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/EdFYvUBaKbY/0.jpg)](https://www.youtube.com/watch?v=EdFYvUBaKbY)

This is a more detailed walkthrough of the scrum demo application and it's integration with Jaeger.

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/U04MzSGzF3s/0.jpg)](https://www.youtube.com/watch?v=U04MzSGzF3s)







