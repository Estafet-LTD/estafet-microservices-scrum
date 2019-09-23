# Creating the devops Environment For the Estafet Microservices Scrum Demo Application
## Contents

* [Overview](https://github.com/stericbro/estafet-microservices-scrum#overview)
* [Prerequisites](https://github.com/stericbro/estafet-microservices-scrum#prerequisites)
* [Forking the GitHub Repositories](https://github.com/stericbro/estafet-microservices-scrum#forking-the-github-repositories)
* [Creating the Infrastructure](https://github.com/stericbro/estafet-microservices-scrum#creating-the-infrastructure)
* [Creating the Devops Environments](https://github.com/stericbro/estafet-microservices-scrum#procedure)
* [Getting Started](https://github.com/stericbro/estafet-microservices-scrum#getting-started)
* [Environments](https://github.com/stericbro/estafet-microservices-scrum#environments)
* [Architecture](https://github.com/stericbro/estafet-microservices-scrum#architecture)
* [Distributed Monitoring](https://github.com/stericbro/estafet-microservices-scrum#distributed-monitoring)

## <a name="overview"/>Overview

The Devops environment for the Estafet Microservices Scrum (EMS) demo application runs on Amazon Web Services (AWS).

> Note:- The Terraform scripts in [the original GitHub repository](https://github.com/Estafet-Ltd/estafet-microservices-scrum "The original GitHub repository")
> require an AWS Elastic IP (EIP) for each host. Because the global IPV4 Address pool is nearly exhausted, AWS impose a
> strict limit on static IP V4 allocation - our AWS account has a limit of five EIP's across the _whole account_. For this
> reason, the environment created by [this fork](https://github.com/Estafet-Ltd/estafet-microservices-scrum "Steve Brown's Fork")
> uses only two EIP's: one for the master node and one for the bastion.

The AWS environment consists of four nodes:

1. The `bastion`, from which the EMS deployments are controlled.
1. The Master node for OpenShift
1. Two OpenShift compute nodes - `node1` and `node2`

There is also a PostgreSQL database, implemented on AWS [RDS](https://aws.amazon.com/rds/).

## <a name="prerequisites"/>Prerequisites

1. You must have access to an AWS account. Estafet employees can be added to the Estafet AWS account.

1. You must configure your [AWS IAM Security Credentials](https://eu-west-2.console.aws.amazon.com/console/home?region=eu-west-2# "AWS settings menu"):

   ![AWS settings menu](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/devops/aws_settings_menu.png)

   Choose `My Security Credentials` and follow the instructions. You only need to configure your IAM security credentials.
   
   You must create the `~/.aws/credential` file:
   
   ```
   [default]
   aws_access_key_id = <your AWS access key>
   aws_secret_access_key = <your AWS secret access key>
   ```

1. You must have Ansible, Terraform and the Openshift client installed on your laptop:

   | Package          | Version       | Details |
   | -------------    |:--------------|:--------|  
   | Ansible          | `2.8.4`       | [Ansible Documentation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#latest-release-via-dnf-or-yum)
   | Terraform        | `v0.11.14`    | [Terraform download page](https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_linux_amd64.zip)
   | Openshift Client | `v3.11`       | [OKD GitHub Releases page](https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz)

   Use yum to install Ansible.

   Terraform and the Openshift Client Tools are shipped as executables. Uncompress the downloaded files and put the
   executables in `/usr/local/bin'`

1. You must have cloned [the original GitHub repository](https://github.com/Estafet-Ltd/estafet-microservices-scrum "The original GitHub repository"), made
a GitHub fork of it, or cloned a GitHub fork of it.

    > Note:-  If you have forked the original GitHub repository, you must fork all the sub modules and make sure that your fork
    > cannot update [the original GitHub repository](https://github.com/Estafet-Ltd/estafet-microservices-scrum "The original GitHub repository") __or any of its submodules__

## <a name="forking-the-github-repositories"/>Forking the GitHub Repositories

The policy for the ESM demo is to take forks of the original repositories, so as to avoid inadvertently breaking the ESM demo.

To fork the GitHub repositories:

1. Login to GitHub Fork the [the original GitHub repository](https://github.com/Estafet-Ltd/estafet-microservices-scrum "The original GitHub repository")

   Click on `Fork` and follow the instructions

1. Fork the GitHub repository for each microservice:

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
      
1. Clone your new fork of [the original GitHub repository](https://github.com/Estafet-Ltd/estafet-microservices-scrum "The original GitHub repository"):

    ```
    $ git clone --recurse-submodules git@github.com:<your GitHub login name>/estafet-microservices-scrum.git estafet-microservices-scrum-<your GitHub login name>
    ```
    or 
    ```
    $ git clone https://github.com/<your GitHub login name>/estafet-microservices-scrum.git estafet-microservices-scrum-<your GitHub login name>
    ``` 
    then:
    ```
    $ cd estafet-microservices-scrum-<your GitHub login name>
    ``` 
    
1. Make sure you are on the master branch:

    ```
    $ git checkout master
    ``` 
1. Edit the .gitmodules file:

   Change all occurrences of "`Estafet-LTD`" to your GitHub login name, e.g.:
   
   ```
   [submodule "estafet-microservices-scrum-api-project"]
    path = estafet-microservices-scrum-api-project
    url = git@github.com:<your GitHub kogin name>/estafet-microservices-scrum-api-project.git
   
   The rest of the file has been omitted for brevity.
    ```
1. Synchronise Git to use your forks, rather than the original repositories:

    ```
    $ git submodule sync
    ```
1.  Commit and push this change:

    ```
    $ git commit .gitmodules -m "Switch to my forks."
    $ git push
    ```
1. Ensure all the submodules are on the master branch:

    ```
    $ git submodule foreach 'git checkout master || :'
    ``` 
1. Ensure that there are no hardcoded references to `Estafet-LTD` in any of your repositories:

    Change all occurrences of `Estafet-LTD` to your GitHub login name in all instances of these files:
    
    * pom.xml
    * *.groovy
    * *.yml
    * *.sh

1. Commit and push all submodule changes:

    ```
    $ git submodule foreach git 'commit -a -m "Switch hard-coded GitHub references to my forks." || :'
    $ git submodule foreach 'git push || :'
    ```

1. Commit and push all changes to the main repository:

    ```
    $ git commit -a -m "Switch hard-coded GitHub references to my forks."
    $ git push
    ```

Your GitHub repositories are now completely separated from the original repositories and you cannot inadvertently make changes
to any of the original repositories.

## <a name="creating-the-infrastructure"/>Creating the Infrastructure
