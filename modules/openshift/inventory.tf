//  Collect together all of the output variables needed to build to the final
//  inventory from the inventory template.
data "template_file" "inventory" {
  template = "${file("${path.cwd}/inventory.template.cfg")}"

  vars {
    access_key       = "${aws_iam_access_key.openshift-aws-user.id}"
    secret_key       = "${aws_iam_access_key.openshift-aws-user.secret}"
    public_hostname  = "${aws_instance.master.public_ip}.xip.io"
    master_inventory = "${aws_instance.master.private_dns}"
    master_hostname  = "${aws_instance.master.private_dns}"
    cicd_hostname    = "${aws_instance.cicd.private_dns}"
    dev_hostname     = "${aws_instance.dev.private_dns}"
    test_hostname    = "${aws_instance.test.private_dns}"
    prod_hostname    = "${aws_instance.prod.private_dns}"
    cluster_id       = "${var.cluster_id}"
  }
}

data "template_file" "environments-inventory" {
  template = "${file("${path.cwd}/environments-inventory.template.cfg")}"

  vars {
    master_hostname = "${aws_instance.master.private_dns}"
  }
}

//  Create the inventory.
resource "local_file" "inventory" {
  content  = "${data.template_file.inventory.rendered}"
  filename = "${path.cwd}/inventory.cfg"
}

resource "local_file" "environments-inventory" {
  content  = "${data.template_file.environments-inventory.rendered}"
  filename = "${path.cwd}/environments-inventory.cfg"
}
