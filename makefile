infrastructure:
	# Get the modules, create the infrastructure.
	terraform init && terraform get && terraform apply
	#terraform remote config -backend=s3 -backend-config="bucket=openshift-terraform-state" -backend-config="key=global/s3/terraform.tfstate" -backend-config="region=eu-west-2" -backend-config="encrypt=true"

# Installs OpenShift on the cluster.
openshift:
	# Add our identity for ssh, add the host key to avoid having to accept the
	# the host key manually. Also add the identity of each node to the bastion.
	ssh-add ~/.ssh/id_rsa
	ssh-keyscan -t rsa -H $$(terraform output bastion-public_dns) >> ~/.ssh/known_hosts
	ssh -A ec2-user@$$(terraform output bastion-public_dns) "ssh-keyscan -t rsa -H master.openshift.local >> ~/.ssh/known_hosts"
	ssh -A ec2-user@$$(terraform output bastion-public_dns) "ssh-keyscan -t rsa -H cicd.openshift.local >> ~/.ssh/known_hosts"
	ssh -A ec2-user@$$(terraform output bastion-public_dns) "ssh-keyscan -t rsa -H dev.openshift.local >> ~/.ssh/known_hosts"
	ssh -A ec2-user@$$(terraform output bastion-public_dns) "ssh-keyscan -t rsa -H test.openshift.local >> ~/.ssh/known_hosts"
	ssh -A ec2-user@$$(terraform output bastion-public_dns) "ssh-keyscan -t rsa -H prod.openshift.local >> ~/.ssh/known_hosts"

	# Copy our inventory to the bastion and run the install script.
	scp ./inventory.cfg ec2-user@$$(terraform output bastion-public_dns):~
	cat install-from-bastion.sh | ssh -tt -o StrictHostKeyChecking=no -A ec2-user@$$(terraform output bastion-public_dns)

	# Now the installer is done, run the postinstall steps on each host.
	cat ./scripts/postinstall-master.sh | ssh -tt -A ec2-user@$$(terraform output bastion-public_dns) ssh master.openshift.local

openshift-post-install:
	# Now the installer is done, run the postinstall steps on each host.
	cat ./scripts/postinstall-master.sh | ssh -tt -A ec2-user@$$(terraform output bastion-public_dns) ssh master.openshift.local

stop-openshift:
	aws ec2 stop-instances --instance-ids $$(aws ec2 describe-instances --filters "Name=tag:Project,Values=openshift" --query "Reservations[].Instances[].[InstanceId]" --output text | tr '\n' ' ')

start-openshift:
	aws ec2 start-instances --instance-ids $$(aws ec2 describe-instances --filters "Name=tag:Project,Values=openshift" --query "Reservations[].Instances[].[InstanceId]" --output text | tr '\n' ' ')

# create the environments in openshift
environments:
	# Copy our inventory to the master and run the install script.
	scp ./environments-inventory.cfg ec2-user@$$(terraform output bastion-public_dns):~
	cat create-environments.sh | ssh -tt -A ec2-user@$$(terraform output bastion-public_dns)

# Open the console.
browse-openshift:
	echo $$(terraform output master-url)

ssh-update:
	ssh-add ~/.ssh/id_rsa
	ssh-keyscan -t rsa -H $$(terraform output bastion-public_dns) >> ~/.ssh/known_hosts
	ssh -A ec2-user@$$(terraform output bastion-public_dns) "ssh-keyscan -t rsa -H master.openshift.local >> ~/.ssh/known_hosts"
	ssh -A ec2-user@$$(terraform output bastion-public_dns) "ssh-keyscan -t rsa -H node1.openshift.local >> ~/.ssh/known_hosts"
	ssh -A ec2-user@$$(terraform output bastion-public_dns) "ssh-keyscan -t rsa -H node2.openshift.local >> ~/.ssh/known_hosts"

# SSH onto the master.
ssh-bastion:
	ssh -t -A ec2-user@$$(terraform output bastion-public_dns)
ssh-master:
	ssh -t -A ec2-user@$$(terraform output bastion-public_dns) ssh master.openshift.local
ssh-cicd:
	ssh -t -A ec2-user@$$(terraform output bastion-public_dns) ssh cicd.openshift.local
ssh-dev:
	ssh -t -A ec2-user@$$(terraform output bastion-public_dns) ssh dev.openshift.local
ssh-test:
	ssh -t -A ec2-user@$$(terraform output bastion-public_dns) ssh test.openshift.local
ssh-prod:
	ssh -t -A ec2-user@$$(terraform output bastion-public_dns) ssh prod.openshift.local		

