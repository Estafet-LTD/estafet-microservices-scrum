# Configuring Webhooks in Jenkins and GitHub
This document describes how to set up GitHub Webhooks so that Jenkins automatically builds a component when changes are pushed to GitHub.

## Contents

* [Prerequisites](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#Prerequisites)
* [Configuring Jenkins](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#configuring-jenkins)
* [Installation](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#Installation)
* [Configuration](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#Configuration)
* [Running Minishift](https://github.com/stericbro/estafet-microservices-scrum/blob/master/WEBHOOKS.md#running-minishift)

## <a name="Prerequisites"></a>Prerequisites

You must have a GitHub account that can push to the GitHub repository (in this case, the GitHub repository for
[estafet-microservices-scrum-basic-ui](https://github.com/stericbro/estafet-microservices-scrum-basic-ui "basic-ui GitHub repository").)
If the repsoitory is provate, you must be set up as a contributor to the GitHub repository.

The Jenkins application on OpenShift must have an IP address and (optionally) DNS name that is accessible from GitHub.
If you are using Minishift or OKD on your local evironments, you can consider using [gogs](https://gogs.io/ "gogs").
Installing and configuring gogs is outside the scope of this document.

## <a name="configuring-jenkins"></a>Configuring Jenkins

Point a browser at Jenkins running on the OpenShift Cluster:

![Jenkins Menu](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_main_menu.png)

Then choose "Jenkins", "Manage Jenkins", then "Configure System"

Scroll down to the `GitHub` section:

![GitHub Configuration](https://github.com/stericbro/estafet-microservices-scrum/blob/master/md_images/webhooks/jenkins_github_configuration.png)

Enter "Public GitHub" in the GitHub Server `Name` field, then click on the 