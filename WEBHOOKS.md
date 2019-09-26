# Configuring Webhooks in Jenkins and GitHub
This document describes how to set up GitHub Webhooks so that Jenkins automatically builds a component when changes are pushed to GitHub.

## Contents

1. [Prerequisites](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#prerequisites)
1. [Get the Build Pipeline secret](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#get-build-pipline-secret)
1. [Configuring Jenkins](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#configuring-jenkins)
1. [Configuring the GitHub Repository](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#configuring-the-github-repository)
1. [Validation](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#validation)

## <a name="prerequisites"></a>Prerequisites

You must have a GitHub account that can push to the GitHub repository (in this case, the GitHub repository for
estafet-microservices-scrum-basic-ui: `https://github.com/owner/estafet-microservices-scrum-basic-ui`.)
If the repository is private and you are not the owner, you must be set up as a collaborator to the GitHub repository.

The Jenkins application on OpenShift must have an IP address and (optionally) DNS name that is accessible from GitHub.
If you are using Minishift or OKD on your local evironments, you can consider using [gogs](https://gogs.io/ "gogs").
Installing and configuring gogs is outside the scope of this document.

## <a name="get-build-pipline-secret"/>Get Build Pipeline Secret

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

![GitHub section](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_configure_system_github.png)

### <a name="create-github-token"/>Create the GitHub Personal Access Token

Choose `Advanced`:

![Advanced GitHub Configuration](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_github_advanced_settings.png)

Choose "`Convert login and password to token`" from the "`Manage addtional GitHub actions`" dropdown list:

![Convert login and password to token](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_github_choose_credential.png)

1. Select the [credential you previously created](https://github.com/stericbro/estafet-microservices-scrum/blob/master/DEVOPS.md#create-github-credentials) from the `Credential`
dropdown list
2. Choose `Create token credentials`:

![GitHub token generated](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_github_token_generated.png)

The token has been created as a `Personal Access Token` in GitHub.

Click on `Save`.

### <a name="edit-github-personal-access-token"/> Edit the GitHub Personal Access Token

The GitHub Personal Access Token must have the `admin:org_hook` scope, otherwise the GitHub will deliver the Webhook
payload to Jenkins and Jenkins will return a 200 status code, but **no build will be trigged in Jenkins**.

Login to GitHub with your credentials, then choose`Your Profile', then `Developer Settings`, then `Personal access tokens`:

You should see this:

![GitHub PAT status](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/github_pat_status.png)

Click on the link for the `Jenkins GitHub Plugin token`:

![GitHub edit GitHub Plugin token](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/github_edit_pat.png)

1. Check `admin:org_hook` scope
2. Click on `Update token` at the bottom of the page (not on the screenshot):

![GitHub Plugin token has admin:org_hook scope](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/personal_access_token_has_admin_org_hook_scope.png)

The Jenkins GitHub Plugin token has the `admin:org_hook` scope.

### <a name="jenkins-create-github-server"/>Create a Jenkins GitHub Server

In Jenkins:

![Add GitHub Server](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_add_github_server.png)

Choose `Add GitHub Server`:

![Jenkins GitHub Server](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_github_server.png)

1. Set the `Name` field to `Public GitHub`
1. Choose `GitHub (https://api.github.com) auto generated token credentials for newowner` from the `Credential` dropdown list
1. Click `Test connection`:

![Jenkins GitHub Connection OK](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_github_server_connection_ok.png)

Click on `Save`.

### <a name="configure-build-pipeline-to-use-webhook"/> Configure the Build Pipeline to Use the GitHub Webhook

Now, choose the `cicd` link on the Jenkins dashboard, the click on the `cicd/ci-basic-ui` link:

![basic-ui Build pipeline](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_basic_ui_pipeline.png)

Choose `Configuration`:

![basic-ui buildpipeline configuration](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_cicd_basic_ui_build_triggers.png)

Check `GitHub hook trigger for GITScm polling` in the `Build Triggers` section, the click on the `Save` button.
 
## <a name="configuring-the-github-repository"/>Configuring the GitHub Repository

Point a browser at the GitHub repository, in this case `estafet-microservices-scrum-basic-ui`:

![GitHub repository page](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/github_repo_page.png)

Choose Settings:

![GitHub repository settings page](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/github_repo_settings_page.png)

Choose `WebHooks`:

![GitHub repository webhook settings page](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/github_repo_webhooks_page.png)

Choose 'Add webhook':

![GitHub repository add Webhook page](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/github_repo_add_webhook_page.png)

[Get the Jenkins host](https://github.com/stericbro/estafet-microservices-scrum/blob/master/DEVOPS.md#get-jenkins-host), e.g. `jenkins-cicd.3.9.50.47.xip.io`.
The Payload URL will be `https://jenkins-cicd.3.9.50.47.xip.io/github-webhook/`.

1. Enter the payload URL in the `Payload URL` field.
1. Change the `Content type` to `application/json`
1. Set the `Secret` field to the secret value from [Get Build Pipeline Secret](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#extract-build-config-secret)
1. Disable SSL verification under `SSL verification` because Jenkins (in the AWS environment) uses self-signed certificates.
1. Click on `Add webhook`

You will be prompted to enter you GitHiub password for verification.

You should see a a page like this:

![GitHub webhook successful page](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/github_webhook_successful.png)

## <a name="validation"/> Validation

The best way to verify that the Webhook works is to make an insignificant change, e.g add a comment to file, then commit and push
that change to GitHub. If the Webhook is working, you should see a build triggered in Jenkins.

This is the state of the `ci-basic-ui` build pipeline for the `estafet-microservices-scrum-basic-ui` microservice before validating the Webhook:

![Build pipeline before validation](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_basic_ui_before_push.png)

1. Add a class comment to `ErrorController.java`

1. Commit and push the changes:
   ```
   [stevebrown@6r4nm12 estafet-microservices-scrum-stericbro]$ cd estafet-microservices-scrum-basic-ui/
   [stevebrown@6r4nm12 estafet-microservices-scrum-basic-ui]$ git status
   On branch master
   Your branch is up to date with 'origin/master'.

   Changes not staged for commit:
     (use "git add <file>..." to update what will be committed)
     (use "git checkout -- <file>..." to discard changes in working directory)

	       modified:   src/main/java/com/estafet/microservices/scrum/basic/ui/controllers/ErrorController.java

   no changes added to commit (use "git add" and/or "git commit -a")
   [stevebrown@6r4nm12 estafet-microservices-scrum-basic-ui]$ git add src/main/java/com/estafet/microservices/scrum/basic/ui/controllers/ErrorController.java
   [stevebrown@6r4nm12 estafet-microservices-scrum-basic-ui]$ git commit -m "Add class comment to verify GitHub WebHooks work."
   [master 0a846a7] Add class comment to verify GitHub WebHooks work.
    1 file changed, 5 insertions(+), 1 deletion(-)
   [stevebrown@6r4nm12 estafet-microservices-scrum-basic-ui]$ git push
   Enumerating objects: 25, done.
   Counting objects: 100% (25/25), done.
   Delta compression using up to 8 threads
   Compressing objects: 100% (7/7), done.
   Writing objects: 100% (13/13), 900 bytes | 900.00 KiB/s, done.
   Total 13 (delta 4), reused 0 (delta 0)
   remote: Resolving deltas: 100% (4/4), completed with 4 local objects.
   To github.com:stericbro/estafet-microservices-scrum-basic-ui.git
      ed3d21b..0a846a7  master -> master
   [stevebrown@6r4nm12 estafet-microservices-scrum-basic-ui]$ 
   ```
    
   In Jenkins, you will see the build that is triggered by the `git push`:
    
   ![Jenkins build triggered by push to GitHub](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_build_triggered_by_push_to_github.png)