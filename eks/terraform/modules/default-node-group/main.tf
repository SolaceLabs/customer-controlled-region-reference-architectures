resource "aws_launch_template" "this" {
  name = "${var.cluster_name}-${var.node_group_name}"

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
    http_endpoint = "enabled"
    #checkov:skip=CKV_AWS_341:Two hops are required for various build-in services to work properly
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
    http_tokens                 = "required"
  }

  dynamic "tag_specifications" {
    for_each = length(var.worker_node_tags) > 0 ? [0] : []
    content {
      resource_type = "instance"
      tags          = var.worker_node_tags
    }
  }
}

resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.worker_node_role_arn
  subnet_ids      = var.subnet_ids

  version         = var.kubernetes_version
  release_version = var.worker_node_ami_version

  scaling_config {
    desired_size = var.node_group_desired_size
    min_size     = 0
    max_size     = 3
  }

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }
}

resource "aws_autoscaling_group_tag" "name" {
  autoscaling_group_name = aws_eks_node_group.this.resources[0].autoscaling_groups[0].name

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-${var.node_group_name}"
    propagate_at_launch = true
  }
}