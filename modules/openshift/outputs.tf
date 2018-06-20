//  Output some useful variables for quick SSH access etc.
// master node
output "master-public_dns" {
  value = "${aws_instance.master.public_dns}"
}

output "master-public_ip" {
  value = "${aws_instance.master.public_ip}"
}

output "master-private_dns" {
  value = "${aws_instance.master.private_dns}"
}

output "master-private_ip" {
  value = "${aws_instance.master.private_ip}"
}

// cicd node
output "cicd-public_dns" {
  value = "${aws_instance.cicd.public_dns}"
}

output "cicd-public_ip" {
  value = "${aws_instance.cicd.public_ip}"
}

output "cicd-private_dns" {
  value = "${aws_instance.cicd.private_dns}"
}

output "cicd-private_ip" {
  value = "${aws_instance.cicd.private_ip}"
}

// dev node
output "dev-public_dns" {
  value = "${aws_instance.dev.public_dns}"
}

output "dev-public_ip" {
  value = "${aws_instance.dev.public_ip}"
}

output "dev-private_dns" {
  value = "${aws_instance.dev.private_dns}"
}

output "dev-private_ip" {
  value = "${aws_instance.dev.private_ip}"
}

// test node
output "test-public_dns" {
  value = "${aws_instance.test.public_dns}"
}

output "test-public_ip" {
  value = "${aws_instance.test.public_ip}"
}

output "test-private_dns" {
  value = "${aws_instance.test.private_dns}"
}

output "test-private_ip" {
  value = "${aws_instance.test.private_ip}"
}

// prod node
output "prod-public_dns" {
  value = "${aws_instance.prod.public_dns}"
}

output "prod-public_ip" {
  value = "${aws_instance.prod.public_ip}"
}

output "prod-private_dns" {
  value = "${aws_instance.prod.private_dns}"
}

output "prod-private_ip" {
  value = "${aws_instance.prod.private_ip}"
}

// bastion node
output "bastion-public_dns" {
  value = "${aws_instance.bastion.public_dns}"
}

output "bastion-public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "bastion-private_dns" {
  value = "${aws_instance.bastion.private_dns}"
}

output "bastion-private_ip" {
  value = "${aws_instance.bastion.private_ip}"
}
