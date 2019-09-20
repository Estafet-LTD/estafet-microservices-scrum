# Installing and configuring Minishift on Centos 7
This document describes how to install and configure [Minishift](https://docs.okd.io/latest/minishift/index.html "Minishift home page") on Centos 7.

The install process for other Linux distributions (MacOS, Debian, Ubuntu etc.) will be similar.

Windows 10 Pro users can try to install Minishift on [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/faq "WSL FAQ page") (WSL)

Installing Minishift into a Virtuak Machine requires the Virtual Machine to support nested virtualization.

Installing Minishift in an [Oracle VirtualBox](https://www.oracle.com/uk/virtualization/virtualbox/ "Oracle VirtualBox home page" ) Virtual machine is only supported for host machines that use AMD processors.

VMWare supports nested virtualisation for Intel processors, but there are licensing issues for the [VMWare Player](https://www.vmware.com/uk/products/workstation-player.html "VMWare Player home page").

## Contents

* [Prerequisites](https://github.com/stericbro/estafet-microservices-scrum/blob/master/MINISHIFT.md#Prerequisites)
* [Nested Virtualization with Intel](https://github.com/stericbro/estafet-microservices-scrum/blob/master/MINISHIFT.md#nested-virtualization)
* [Installation](https://github.com/stericbro/estafet-microservices-scrum/blob/master/MINISHIFT.md#Installation)
* [Configuration](https://github.com/stericbro/estafet-microservices-scrum/blob/master/MINISHIFT.md#Configuration)
* [Running Minishift](https://github.com/stericbro/estafet-microservices-scrum/blob/master/MINISHIFT.md#running-minishift)

## <a name="Prerequisites"></a>Prerequisites

### KVM

KVM (Kernel-based Virtual Machine) is virtualization software for CentOS or RHEL 7. KVM turns your laptop into a hypervisor. 

Before installing KVM,  make sure that Virtualization Technology (VT) is enabled in your laptop’s BIOS. Run this command to
verify that your laptop supports (VT):

```
$ lscpu | grep Virtualization
Virtualization: VT-x*
```
If your laptop supports VT, you should see the line "`Virtualization: VT-x`" If not, check your BIOS settings and change them if necessary.

Check that the logged in user can run sudo:

```
$ id
uid= ... ,10(wheel), ...
```

If a user can run sudo, they will be a member of the `wheel` group. Otherwise, log in as `root` and then

```
# usermod -aG wheel <your username>
# exit
$ newgrp
$
```

Install the KVM packages:

```
$ sudo yum install -y qemu-kvm libvirt libvirt-python libguestfs-tools virt-install
```

Start the `libvirtd` service:

```
$ sudo systemctl enable libvirtd
$ sudo systemctl start libvirtd
```
Add the user to the libvirt group:

```
$ sudo usermod -a -G libvirt $(whoami)
$ newgrp libvirt
```

Install docker-machine and make it executable:

```
$ sudo curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine
$ sudo chmod +x /tmp/docker-machine
$ sudo mv /tmp/docker-machine /usr/local/bin
$
```
Install the KVM driver binary and make it executable:

```
$ sudo curl -L https://github.com/dhiltgen/docker-machine-kvm/releases/download/v0.10.0/docker-machine-driver-kvm-centos7 \
-o /usr/local/bin/docker-machine-driver-kvm
$ sudo chmod +x /usr/local/bin/docker-machine-driver-kvm
```
### <a name="nested-virtualization"></a>KVM Nested Virtualization with Intel

Nested virtualization should only be used when your VM host is Windows and one of these situations applies:

  1. You cannot get Minishift to run under Windows
  2. You don't have [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/about "Windows Subsystem for Linux") (WSL) installed
  3. You cannot get Minishift to work with WSL.
 
Nested Virtualisation is not required if your VM host is running Linux.
 
As you may expect, it is very resource intensive running (slow) a Minishift VM
within a Linux VM hostsed on Windows.

Currently (September, 2019), Oracle VirtualBox does not support nested virtualization on Intel processors, but VMWare does.

The necessary steps to run Minishift nested in a Linux VM are as follows:

* Make sure your BIOS settings allow Virtual Machines
* Download and install the [VMWare Workstation Player](https://www.vmware.com/uk/products/workstation-player.html "VMWare Workstation PLayer")
* Run the VMWare Player and create a Linux VM with the Virtualization engine '`Virtualize Intel VT-x/EPT or AMD-V/RVI`' box checked under the Processors tab
* Follow [these instructions](https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/ "nested virtualization") on the Fedora website.
* [Install Minishift](https://github.com/stericbro/estafet-microservices-scrum/blob/master/MINISHIFT.md#Installation) in the Linix VM you just created.

## <a name="Installation"></a>Install Minishift

To install Minishift, the steps are:

* Download Minishift
* Install Minishift

Download Minishift software for your operating system from the [Minishift Releases](https://github.com/minishift/minishift/releases "Minishift releases page") page:

```
$ curl -Ss -w "\n%{http_code}\n" \
-L https://github.com/minishift/minishift/releases/download/v1.34.1/minishift-1.34.1-linux-amd64.tgz \
-o ~/Downloads/minishift-1.34.1-linux-amd64.tgz

200
$
```

The download succeeds when "`200`" shows as the HTTP status code.

Install Minishift into ~/tools/minishift-1.34.1:

```
$ mkdir -p ~/tools
$ tar zxf ~/Downloads/minishift-1.34.1-linux-amd64.tgz -C ~/tools/
$ mv ~/tools/minishift-1.34.1-linux-amd64 ~/tools/minishift-1.34.1
$
```

## <a name="configuration"></a>Configuration

Set up the user's bash profile:

Edit the user's BASH profile (`~/.bash_profile`) as follows:

```
#!/bin/bash
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# User specific environment and startup programs

TOOLS_HOME="${HOME}/tools"

export MINISHIFT_VERSION=1.34.1
export OKD_VERSION=3.11.0
export MINISHIFT_HOME=${TOOLS_HOME}/minishift-${MINISHIFT_VERSION}

OLD_PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:${HOME}/.local/bin:${HOME}/bin

PATH=${MINISHIFT_HOME}:\
${MINISHIFT_HOME}/cache/oc/v${OKD_VERSION}/linux/:\
${OLD_PATH}
export PATH

```

Source the updated BASH profile:

```
$ source ~/.bash_profile
$
```
Configure Minishift:

These are suggested values:

| Settings         | Value         |
| -------------    |:--------------|
| Virtualization   | `KVM`         |
| Memory           | `8Gb`         | 
| Number of CPUs   | `4`           |
| Disk Space       | `100Gb`       |

```
$  minishift config set vm-driver kvm
$  minishift config set memory 8G
$  minishift config set cpus 4
$  minishift config set disk-size 100G

```
## <a name="running-minishift"></a>Running Minishift

This what running Minishift for the first time should look like:

```
$ minishift start
Starting minishift VM ...
-- Starting profile 'minishift'
-- Check if deprecated options are used ... OK
-- Checking if https://github.com is reachable ... OK
-- Checking if requested OpenShift version 'v3.11.0' is valid ... OK
-- Checking if requested OpenShift version 'v3.11.0' is supported ... OK
-- Checking if requested hypervisor 'kvm' is supported on this platform ... OK
-- Checking if KVM driver is installed ... 
   Driver is available at /usr/local/bin/docker-machine-driver-kvm ... 
   Checking driver binary is executable ... OK
-- Checking if Libvirt is installed ... OK
-- Checking if Libvirt default network is present ... OK
-- Checking if Libvirt default network is active ... OK
-- Checking the ISO URL ... OK
-- Downloading OpenShift binary 'oc' version 'v3.11.0'
 53.89 MiB / 53.89 MiB [===============================================================================================================================================================================] 100.00% 0s-- Downloading OpenShift v3.11.0 checksums ... OK
-- Checking if provided oc flags are supported ... OK
-- Starting the OpenShift cluster using 'kvm' hypervisor ...
-- Minishift VM will be configured with ...
   Memory:    8 GB
   vCPUs :    4
   Disk size: 100 GB

   Downloading ISO 'https://github.com/minishift/minishift-centos-iso/releases/download/v1.15.0/minishift-centos7.iso'
 355.00 MiB / 355.00 MiB [=============================================================================================================================================================================] 100.00% 0s
-- Starting Minishift VM .............. OK
-- Checking for IP address ... OK
-- Checking for nameservers ... OK
-- Checking if external host is reachable from the Minishift VM ... 
   Pinging 8.8.8.8 ... OK
-- Checking HTTP connectivity from the VM ... 
   Retrieving http://minishift.io/index.html ... OK
-- Checking if persistent storage volume is mounted ... OK
-- Checking available disk space ... 1% used OK
-- Writing current configuration for static assignment of IP address ... WARN
   Importing 'openshift/origin-control-plane:v3.11.0' . CACHE MISS
   Importing 'openshift/origin-docker-registry:v3.11.0'  CACHE MISS
   Importing 'openshift/origin-haproxy-router:v3.11.0'  CACHE MISS
-- OpenShift cluster will be configured with ...
   Version: v3.11.0
-- Pulling the OpenShift Container Image ........... OK
-- Copying oc binary from the OpenShift container image to VM ... OK
-- Starting OpenShift cluster ........................................................
Getting a Docker client ...
Checking if image openshift/origin-control-plane:v3.11.0 is available ...
Pulling image openshift/origin-cli:v3.11.0
E0917 12:30:01.992777    4775 helper.go:173] Reading docker config from /home/docker/.docker/config.json failed: open /home/docker/.docker/config.json: no such file or directory, will attempt to pull image docker.io/openshift/origin-cli:v3.11.0 anonymously
Image pull complete
Pulling image openshift/origin-node:v3.11.0
E0917 12:30:03.949554    4775 helper.go:173] Reading docker config from /home/docker/.docker/config.json failed: open /home/docker/.docker/config.json: no such file or directory, will attempt to pull image docker.io/openshift/origin-node:v3.11.0 anonymously
Pulled 5/6 layers, 90% complete
Pulled 6/6 layers, 100% complete
Extracting
Image pull complete
Checking type of volume mount ...
Determining server IP ...
Using public hostname IP 192.168.42.34 as the host IP
Checking if OpenShift is already running ...
Checking for supported Docker version (=>1.22) ...
Checking if insecured registry is configured properly in Docker ...
Checking if required ports are available ...
Checking if OpenShift client is configured properly ...
Checking if image openshift/origin-control-plane:v3.11.0 is available ...
Starting OpenShift using openshift/origin-control-plane:v3.11.0 ...
I0917 12:30:13.426734    4775 config.go:40] Running "create-master-config"
I0917 12:30:15.089117    4775 config.go:46] Running "create-node-config"
I0917 12:30:15.758151    4775 flags.go:30] Running "create-kubelet-flags"
I0917 12:30:16.118612    4775 run_kubelet.go:49] Running "start-kubelet"
I0917 12:30:16.381191    4775 run_self_hosted.go:181] Waiting for the kube-apiserver to be ready ...
I0917 12:30:52.394195    4775 interface.go:26] Installing "kube-proxy" ...
I0917 12:30:52.394866    4775 interface.go:26] Installing "kube-dns" ...
I0917 12:30:52.394871    4775 interface.go:26] Installing "openshift-service-cert-signer-operator" ...
I0917 12:30:52.394876    4775 interface.go:26] Installing "openshift-apiserver" ...
I0917 12:30:52.394900    4775 apply_template.go:81] Installing "openshift-apiserver"
I0917 12:30:52.395026    4775 apply_template.go:81] Installing "kube-dns"
I0917 12:30:52.395044    4775 apply_template.go:81] Installing "openshift-service-cert-signer-operator"
I0917 12:30:52.395864    4775 apply_template.go:81] Installing "kube-proxy"
I0917 12:30:54.400508    4775 interface.go:41] Finished installing "kube-proxy" "kube-dns" "openshift-service-cert-signer-operator" "openshift-apiserver"
I0917 12:33:22.421538    4775 run_self_hosted.go:242] openshift-apiserver available
I0917 12:33:22.422206    4775 interface.go:26] Installing "openshift-controller-manager" ...
I0917 12:33:22.422219    4775 apply_template.go:81] Installing "openshift-controller-manager"
I0917 12:33:24.274346    4775 interface.go:41] Finished installing "openshift-controller-manager"
Adding default OAuthClient redirect URIs ...
Adding persistent-volumes ...
Adding web-console ...
Adding sample-templates ...
Adding centos-imagestreams ...
Adding registry ...
Adding router ...
I0917 12:33:24.291924    4775 interface.go:26] Installing "persistent-volumes" ...
I0917 12:33:24.291932    4775 interface.go:26] Installing "openshift-web-console-operator" ...
I0917 12:33:24.291936    4775 interface.go:26] Installing "sample-templates" ...
I0917 12:33:24.291940    4775 interface.go:26] Installing "centos-imagestreams" ...
I0917 12:33:24.291946    4775 interface.go:26] Installing "openshift-image-registry" ...
I0917 12:33:24.291950    4775 interface.go:26] Installing "openshift-router" ...
I0917 12:33:24.293016    4775 apply_template.go:81] Installing "openshift-web-console-operator"
I0917 12:33:24.293053    4775 apply_list.go:67] Installing "centos-imagestreams"
I0917 12:33:24.293121    4775 interface.go:26] Installing "sample-templates/dancer quickstart" ...
I0917 12:33:24.293127    4775 interface.go:26] Installing "sample-templates/nodejs quickstart" ...
I0917 12:33:24.293131    4775 interface.go:26] Installing "sample-templates/rails quickstart" ...
I0917 12:33:24.293134    4775 interface.go:26] Installing "sample-templates/sample pipeline" ...
I0917 12:33:24.293138    4775 interface.go:26] Installing "sample-templates/mysql" ...
I0917 12:33:24.293141    4775 interface.go:26] Installing "sample-templates/mariadb" ...
I0917 12:33:24.293145    4775 interface.go:26] Installing "sample-templates/postgresql" ...
I0917 12:33:24.293149    4775 interface.go:26] Installing "sample-templates/cakephp quickstart" ...
I0917 12:33:24.293153    4775 interface.go:26] Installing "sample-templates/django quickstart" ...
I0917 12:33:24.293157    4775 interface.go:26] Installing "sample-templates/jenkins pipeline ephemeral" ...
I0917 12:33:24.293161    4775 interface.go:26] Installing "sample-templates/mongodb" ...
I0917 12:33:24.293183    4775 apply_list.go:67] Installing "sample-templates/mongodb"
I0917 12:33:24.293296    4775 apply_list.go:67] Installing "sample-templates/dancer quickstart"
I0917 12:33:24.293370    4775 apply_list.go:67] Installing "sample-templates/nodejs quickstart"
I0917 12:33:24.302689    4775 apply_list.go:67] Installing "sample-templates/django quickstart"
I0917 12:33:24.302892    4775 apply_list.go:67] Installing "sample-templates/rails quickstart"
I0917 12:33:24.304226    4775 apply_list.go:67] Installing "sample-templates/sample pipeline"
I0917 12:33:24.304494    4775 apply_list.go:67] Installing "sample-templates/mysql"
I0917 12:33:24.304765    4775 apply_list.go:67] Installing "sample-templates/mariadb"
I0917 12:33:24.304955    4775 apply_list.go:67] Installing "sample-templates/postgresql"
I0917 12:33:24.305136    4775 apply_list.go:67] Installing "sample-templates/cakephp quickstart"
I0917 12:33:24.305385    4775 apply_list.go:67] Installing "sample-templates/jenkins pipeline ephemeral"
I0917 12:33:29.543608    4775 interface.go:41] Finished installing "sample-templates/dancer quickstart" "sample-templates/nodejs quickstart" "sample-templates/rails quickstart" "sample-templates/sample pipeline" "sample-templates/mysql" "sample-templates/mariadb" "sample-templates/postgresql" "sample-templates/cakephp quickstart" "sample-templates/django quickstart" "sample-templates/jenkins pipeline ephemeral" "sample-templates/mongodb"
I0917 12:34:00.675883    4775 interface.go:41] Finished installing "persistent-volumes" "openshift-web-console-operator" "sample-templates" "centos-imagestreams" "openshift-image-registry" "openshift-router"
Login to server ...
Creating initial project "myproject" ...
Server Information ...
OpenShift server started.

The server is accessible via web console at:
    https://192.168.42.34:8443/console

You are logged in as:
    User:     developer
    Password: <any value>

To login as administrator:
    oc login -u system:admin


-- Exporting of OpenShift images is occuring in background process with pid 32342.
Started Minishift OK.

```