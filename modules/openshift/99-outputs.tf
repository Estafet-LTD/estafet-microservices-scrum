//  Output some useful variables for quick SSH access etc.
output "master-public_ip" {
  value = "${aws_eip.master_eip.public_ip}"
}
output "master-private_dns" {
  value = "${aws_instance.master.private_dns}"
}
output "master-private_ip" {
  value = "${aws_instance.master.private_ip}"
}

output "node1-public_ip" {
  value = "${aws_eip.node1_eip.public_ip}"
}
output "node1-private_dns" {
  value = "${aws_instance.node1.private_dns}"
}
output "node1-private_ip" {
  value = "${aws_instance.node1.private_ip}"
}

output "node2-public_ip" {
  value = "${aws_eip.node2_eip.public_ip}"
}
output "node2-private_dns" {
  value = "${aws_instance.node2.private_dns}"
}
output "node2-private_ip" {
  value = "${aws_instance.node2.private_ip}"
}

output "bastion-public_ip" {
  value = "${aws_eip.bastion_eip.public_ip}"
}
output "bastion-private_dns" {
  value = "${aws_instance.bastion.private_dns}"
}
output "bastion-private_ip" {
  value = "${aws_instance.bastion.private_ip}"
}
output "aws_vpc_openshift" {
  value = "${aws_vpc.openshift.id}"
}
output "aws_security_group_vpc" {
  value = "${aws_security_group.openshift-vpc.id}"
}
output "aws_subnet_public_subnet" {
  value = "${aws_subnet.public-subnet.id}"
}


