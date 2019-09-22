# Configuring Webhooks in Jenkins and GitHub
This document describes how to set up GitHub Webhooks so that Jenkins automatically builds a component when changes are pushed to GitHub.

## Contents

1. [Prerequisites](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#prerequisites)
1. [Get the Build Pipeline secret](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#get-build-pipline-secret)
1. [Configuring Jenkins](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#configuring-jenkins)
1. [Configuring GitHub](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#configuring-github)
1. [Validation](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#validation)

## <a name="prerequisites"></a>Prerequisites

You must have a GitHub account that can push to the GitHub repository (in this case, the GitHub repository for
estafet-microservices-scrum-basic-ui: `https://github.com/owner/estafet-microservices-scrum-basic-ui`.)
If the repository is private and you are not the owner, you must be set up as a collaborator to the GitHub repository.

The Jenkins application on OpenShift must have an IP address and (optionally) DNS name that is accessible from GitHub.
If you are using Minishift or OKD on your local evironments, you can consider using [gogs](https://gogs.io/ "gogs").
Installing and configuring gogs is outside the scope of this document.

## <a name="#get-build-pipline-secret"/>Get Build Pipeline Secret

1. Login to openshift as admin:

    ```
    [ec2-user@ip-10-0-1-136 estafet-microservices-scrum]$ oc login --insecure-skip-tls-verify=true -u admin -p 123 https://ip-10-0-1-105.eu-west-2.compute.internal:8443
    Login successful.
    
    You have access to the following projects and can switch between them with 'oc project <projectname>':
    
      * cicd
        default
        dev
        kube-public
        kube-service-catalog
        kube-system
        management-infra
        openshift
        openshift-ansible-service-broker
        openshift-console
        openshift-infra
        openshift-logging
        openshift-monitoring
        openshift-node
        openshift-sdn
        openshift-template-service-broker
        openshift-web-console
        prod
        test
    
    Using project "cicd".
    [ec2-user@ip-10-0-1-136 estafet-microservices-scrum]$ 
    
    ```
1. Make sure you are using the `cicd` project:

    ```
    [ec2-user@ip-10-0-1-136 estafet-microservices-scrum]$ oc project cicd
    Now using project "cicd" on server "https://ip-10-0-1-105.eu-west-2.compute.internal:8443".
    [ec2-user@ip-10-0-1-136 estafet-microservices-scrum]$ 
   ``` 
 1. <a name="extract-build-config-secret"/>Extract the secret with this jsonpath expression:
     ```
    [ec2-user@ip-10-0-1-136 estafet-microservices-scrum]$ oc get bc ci-basic-ui -o jsonpath="{.spec.triggers[?(@.type=='GitHub')].github.secret}";echo ""
    secret101
    [ec2-user@ip-10-0-1-136 estafet-microservices-scrum]$ 
    ```  
## <a name="configuring-jenkins"></a>Configuring Jenkins

Point a browser at Jenkins running on the OpenShift Cluster:

![Jenkins Menu](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_main_menu.png)

Then choose "Jenkins", "Manage Jenkins", then "Configure System"

Scroll down to the `GitHub` section:

![GitHub Configuration](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_github_configuration.png)

Enter "Public GitHub" in the GitHub Server `Name` field, then click on the `Advanced` button:

![Advanced GitHub Configuration](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_github_configuration_advanced.png)

Choose "`Convert login and password to token`" from the "`Manage addtional GitHub actions`" dropdown list:

![Convert login and password to token](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_github_convert_login_password.png)

Select "`From login and password`":

![From login and password](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_github_from_login_password.png)

Enter your GitHub Login username and password, then click on "`Create token credentials`"

![GitHub credential](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_github_credential.png)

Click the "Save button", then scroll up to:

![GitHub set credential and test](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_github_set_credential_and_test.png)

Select the credential you just created from the "`Credentials`" dropdown list and then choose "`Test connection`":

![GitHub credential test result](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_github_credential_test_result.png)

Click on `Advanced`:

![GitHub Advanced Settings](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_github_advanced_settings_2.png)

Check `Specify another hook URL for GitHib configuration`:

![GitHub Override Hook URL](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_github_override_hook_url.png)

<a name="save-hook-url"></a>Ignore the error message `Failed to test a connection to ...`.  Copy the highlighted  Webhook URL and save it.

1. Uncheck `Specify another hook URL for GitHib configuration`
1. Click on `Save`.

## <a name="configuring-github"></a>Configuring GitHub

Point a browser at the GitHub for the repository, in this case `estafet-microservices-scrum-basic-ui`:

![GitHub repository page](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/github_repo_page.png)

Choose Settings:

![GitHub repository settings page](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/github_repo_settings_page.png)

Choose `WebHooks`: 

![GitHub repository settings page](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/github_repo_webhooks_page.png)

Choose 'Add webhook':

![GitHub repository settings page](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/github_repo_add_webhook_page.png)

1. Copy the Jenkins hook URL from [save hook url](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#save-hook-url)
into the `Payload URL` field.
1. Change the `Content type` to `application/json` 
1. Set the `Secret` field to the secret value from [Get Build Pipeline Secret](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#extract-build-config-secret)
1. Under `SSL verification`, disable SSL verification because, in the AWS environment, Jenkins uses self-signed certificates. 
1. Cick on `Add webhook`

You will be prompted to enter you GitHiub password for verification.


## <a name="validation"> Validation

The best way to verify that the Webhook works is make an insignificant change, e.g add a comment to file, then commit and push
that change to GitHub. If the Webhook is working, you should see a build triggered in Jenkins.

This is the state of the `ci-basic-ui` build pipeline for the `estafe-microservices-scrum-basic-ui` microservice before validating the Webhook:

![Build pipeline before validation](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_basic_ui_before_push.png)


 