### Local Installation
The entire application source must be cloned in one go by recursively cloning the master repository.

```
git clone --recursive https://github.com/Estafet-LTD/estafet-microservices-scrum.git
```

Review the [prerequities](https://github.com/Estafet-LTD/estafet-microservices-scrum#prerequisites) for the local installation before continuing.

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

Create environment variables for the db schema generation


	export POSTGRESQL_SERVICE_HOST=localhost
	export POSTGRESQL_SERVICE_PORT=5432

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
* You can define a guide for setting up credentials for A-MQ [here](https://developers.redhat.com/products/amq/hello-world/)