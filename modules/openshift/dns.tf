//  Notes: We could make the internal domain a variable, but not sure it is
//  really necessary.

//  Create the internal DNS.
resource "aws_route53_zone" "internal" {
  name    = "openshift.local"
  comment = "OpenShift Cluster Internal DNS"
  vpc_id  = "${aws_vpc.openshift.id}"

  tags {
    Name    = "OpenShift Internal DNS"
    Project = "openshift"
  }
}

//  Routes for 'master', 'cicd', 'dev', 'test' and 'prod'.
resource "aws_route53_record" "master-a-record" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "master.openshift.local"
  type    = "A"
  ttl     = 300

  records = [
    "${aws_instance.master.private_ip}",
  ]
}

resource "aws_route53_record" "cicd-a-record" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "cicd.openshift.local"
  type    = "A"
  ttl     = 300

  records = [
    "${aws_instance.cicd.private_ip}",
  ]
}

resource "aws_route53_record" "dev-a-record" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "dev.openshift.local"
  type    = "A"
  ttl     = 300

  records = [
    "${aws_instance.dev.private_ip}",
  ]
}

resource "aws_route53_record" "test-a-record" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "test.openshift.local"
  type    = "A"
  ttl     = 300

  records = [
    "${aws_instance.test.private_ip}",
  ]
}

resource "aws_route53_record" "prod-a-record" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "prod.openshift.local"
  type    = "A"
  ttl     = 300

  records = [
    "${aws_instance.prod.private_ip}",
  ]
}
