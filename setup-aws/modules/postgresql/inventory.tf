//  Collect together all of the output variables needed to build to the final
//  inventory from the inventory template.
data "template_file" "inventory" {
  template = "${file("${path.cwd}/rds-inventory.template.cfg")}"
  vars {
    database_hostname = "${module.db_instance.this_db_instance_address}"
  }
}

//  Create the remote aws rds inventory.
resource "local_file" "inventory" {
  content     = "${data.template_file.inventory.rendered}"
  filename = "${path.cwd}/rds-inventory.cfg"
}


