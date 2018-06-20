locals {
  common_tags = "${map(
    "Project", "openshift",
    "KubernetesCluster", "${var.cluster_name}",
    "kubernetes.io/cluster/${var.cluster_name}", "${var.cluster_id}"
  )}"
}
