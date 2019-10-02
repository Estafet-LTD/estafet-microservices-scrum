//  Setup the core provider information.
provider "aws" {
  region  = "${var.region}"
}

//  Create the OpenShift cluster using our module.
module "openshift" {
  source          = "./modules/openshift"
  region          = "${var.region}"
  amisize         = "m5.2xlarge"    
  vpc_cidr        = "10.0.0.0/16"
  subnet_cidr     = "10.0.1.0/24"
  key_name        = "openshift"
  public_key_path = "${var.public_key_path}"
  cluster_name    = "openshift-cluster"
  cluster_id      = "openshift-cluster-${var.region}"
}

resource "aws_subnet" "db_subnet_a" {
  vpc_id                  = "${module.openshift.aws_vpc_openshift}"
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}a"

  tags {
    Name = "Openshift RDS Database Subnet Zone A"
  }
}

resource "aws_subnet" "db_subnet_b" {
  vpc_id                  = "${module.openshift.aws_vpc_openshift}"
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "${var.region}b"

  tags {
    Name = "Openshift RDS Database Subnet Zone B"
  }
}

module "db" {
  source = "./modules/postgresql"

  identifier = "microservices-scrum"

  engine            = "postgres"
  engine_version    = "9.6.3"
  instance_class    = "db.t2.large"
  allocated_storage = 5
  storage_encrypted = false

  # kms_key_id        = "arm:aws:kms:<region>:<account id>:key/<kms key id>"
  name = "scrumdb"

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  username = "postgres"

  password = "welcome1"
  port     = "5432"

  vpc_security_group_ids = ["${module.openshift.aws_security_group_vpc}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  #enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # DB subnet group
  subnet_ids = ["${aws_subnet.db_subnet_a.id}", "${aws_subnet.db_subnet_b.id}"]

  # DB parameter group
  family = "postgres9.6"

  # DB option group
  major_engine_version = "9.6"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "scrumdb"

  # Database Deletion Protection
  deletion_protection = false
}

//  Output some useful variables for quick SSH access etc.
output "master-url" {
  value = "https://${module.openshift.master-public_ip}.xip.io:8443"
}
output "master-public_ip" {
  value = "${module.openshift.master-public_ip}"
}
output "bastion-public_ip" {
  value = "${module.openshift.bastion-public_ip}"
}


