infrastructure:
	# Get the modules, create the infrastructure.
	terraform init && terraform get && terraform apply -auto-approve

# Installs OpenShift on the cluster.
openshift:
	# Add our identity for ssh, add the host key to avoid having to accept the
	# the host key manually. Also add the identity of each node to the bastion.
	ssh-add ~/.ssh/id_rsa
	ssh-keyscan -t rsa -H $$(terraform output bastion-public_ip) >> ~/.ssh/known_hosts
	ssh -A ec2-user@$$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H master.openshift.local >> ~/.ssh/known_hosts"
	ssh -A ec2-user@$$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H node1.openshift.local >> ~/.ssh/known_hosts"
	ssh -A ec2-user@$$(terraform output bastion-public_ip) "ssh-keyscan -t rsa -H node2.openshift.local >> ~/.ssh/known_hosts"

	# Copy our inventory to the master and run the install script.
	scp ./rds-inventory.cfg ec2-user@$$(terraform output bastion-public_ip):~
	scp ./inventory.cfg ec2-user@$$(terraform output bastion-public_ip):~
	cat install-from-bastion.sh | ssh -o StrictHostKeyChecking=no -A ec2-user@$$(terraform output bastion-public_ip)

	# Now the installer is done, run the postinstall steps on each host.
	# Note: these scripts cause a restart, so we use a hyphen to ignore the ssh
	# connection termination.
	# - cat ./scripts/postinstall-master.sh | ssh -A ec2-user@$$(terraform output bastion-public_ip) ssh master.openshift.local
	# - cat ./scripts/postinstall-node.sh | ssh -A ec2-user@$$(terraform output bastion-public_ip) ssh node1.openshift.local
	# - cat ./scripts/postinstall-node.sh | ssh -A ec2-user@$$(terraform output bastion-public_ip) ssh node2.openshift.local
	#echo "Complete! Wait a minute for hosts to restart, then run 'make browse-openshift' to login."

# Destroy the infrastructure.
destroy:
	terraform init && terraform destroy -auto-approve

# Open the console.
master-url:
	echo $$(terraform output master-url)

# SSH onto the master.
ssh-bastion:
	ssh -t -A ec2-user@$$(terraform output bastion-public_ip)
ssh-master:
	ssh -t -A ec2-user@$$(terraform output bastion-public_ip) ssh master.openshift.local
ssh-node1:
	ssh -t -A ec2-user@$$(terraform output bastion-public_ip) ssh node1.openshift.local
ssh-node2:
	ssh -t -A ec2-user@$$(terraform output bastion-public_ip) ssh node2.openshift.local
