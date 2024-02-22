locals {
  ami_name = var.worker_node_arch == "x86_64" ? "amazon-linux-2" : "amazon-linux-2-arm64"
}

resource "aws_launch_template" "this" {
  name = var.node_group_name_prefix

  vpc_security_group_ids = var.security_group_ids
  instance_type          = var.worker_node_instance_type

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = var.worker_node_volume_size
      volume_type           = var.worker_node_volume_type
    }
  }

  metadata_options {
    http_endpoint      = "enabled"
    http_protocol_ipv6 = var.ip_family == "ipv6" ? "enabled" : "disabled"
    #checkov:skip=CKV_AWS_341:Two hops are required for various build-in services to work properly
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
    http_tokens                 = "required"
  }
}

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/eks/optimized-ami/${var.kubernetes_version}/${local.ami_name}/recommended/release_version"
}

resource "aws_eks_node_group" "this" {
  count = length(var.subnet_ids)

  cluster_name           = var.cluster_name
  node_group_name_prefix = "${var.node_group_name_prefix}-${count.index}-"
  node_role_arn          = var.worker_node_role_arn
  subnet_ids             = [var.subnet_ids[count.index]]

  version         = var.kubernetes_version
  release_version = nonsensitive(data.aws_ssm_parameter.ami.value)

  ami_type = var.worker_node_arch == "x86_64" ? "AL2_x86_64" : "AL2_ARM_64"

  scaling_config {
    desired_size = var.node_group_desired_size
    min_size     = var.node_group_min_size
    max_size     = var.node_group_max_size
  }

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  labels = var.node_group_labels

  dynamic "taint" {
    for_each = var.node_group_taints
    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }
}

resource "aws_autoscaling_group_tag" "name_tag" {
  count = length(aws_eks_node_group.this)

  autoscaling_group_name = aws_eks_node_group.this[count.index].resources[0].autoscaling_groups[0].name

  tag {
    key                 = "Name"
    value               = var.node_group_name_prefix
    propagate_at_launch = true
  }
}

locals {
  labels_list = [
    for key, value in var.node_group_labels : {
      key   = key
      value = value
    }
  ]

  resources_tags_asg = [
    for pair in setproduct(aws_eks_node_group.this, var.node_group_resources_tags) : {
      autoscaling_group_name = pair[0].resources[0].autoscaling_groups[0].name
      tag                    = pair[1]
    }
  ]

  labels_tags_asg = [
    for pair in setproduct(aws_eks_node_group.this, local.labels_list) : {
      autoscaling_group_name = pair[0].resources[0].autoscaling_groups[0].name
      label                  = pair[1]
    }
  ]

  taints_tags_asg = [
    for pair in setproduct(aws_eks_node_group.this, var.node_group_taints) : {
      autoscaling_group_name = pair[0].resources[0].autoscaling_groups[0].name
      taint                  = pair[1]
    }
  ]
}

resource "aws_autoscaling_group_tag" "resources_tags" {
  count = length(local.resources_tags_asg)

  autoscaling_group_name = local.resources_tags_asg[count.index].autoscaling_group_name

  tag {
    key                 = local.resources_tags_asg[count.index].tag.key
    value               = local.resources_tags_asg[count.index].tag.value
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "labels_tags" {
  count = length(local.labels_tags_asg)

  autoscaling_group_name = local.labels_tags_asg[count.index].autoscaling_group_name

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/${local.labels_tags_asg[count.index].label.key}"
    value               = local.labels_tags_asg[count.index].label.value
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "taints_tags" {
  count = length(local.taints_tags_asg)

  autoscaling_group_name = local.taints_tags_asg[count.index].autoscaling_group_name

  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/taint/${local.taints_tags_asg[count.index].taint.key}"
    value               = "${local.taints_tags_asg[count.index].taint.value}:${local.taints_tags_asg[count.index].taint.effect}"
    propagate_at_launch = true
  }
}