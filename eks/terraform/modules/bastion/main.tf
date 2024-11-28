data "aws_partition" "current" {}

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_key_pair" "bastion" {
  count = var.create_bastion ? 1 : 0

  key_name   = "${var.cluster_name}-bastion"
  public_key = var.bastion_ssh_public_key

  lifecycle {
    precondition {
      condition     = var.bastion_ssh_public_key != ""
      error_message = "Public key must be provided if bastion host is being created."
    }
  }
}

resource "aws_iam_instance_profile" "bastion" {
  count = var.create_bastion ? 1 : 0

  name = "${var.cluster_name}-bastion"
  role = aws_iam_role.bastion[0].name
}

data "aws_iam_policy_document" "bastion" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "bastion" {
  count = var.create_bastion ? 1 : 0

  name               = "${var.cluster_name}-bastion"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.bastion.json
}

resource "aws_iam_role_policy_attachment" "bastion_AmazonSSMManagedInstanceCore" {
  count = var.create_bastion ? 1 : 0

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion[0].name
}

resource "aws_instance" "bastion" {
  count = var.create_bastion ? 1 : 0

  #checkov:skip=CKV_AWS_126:Solace is not opinionated on detailed monitoring for instances

  ami                    = data.aws_ami.amazon-linux.id
  instance_type          = "t3.micro"
  key_name               = var.bastion_public_access ? aws_key_pair.bastion[0].key_name : null
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.bastion[0].id]
  ebs_optimized          = true
  iam_instance_profile   = aws_iam_instance_profile.bastion[0].id

  #checkov:skip=CKV_AWS_88:The purpose of the bastion is to provide a single point of access to the VPC, but the public IP could be removed and Systems Manager used instead (for example) if desired
  associate_public_ip_address = var.bastion_public_access

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
    http_tokens                 = "required"
  }

  tags = {
    Name = "${var.cluster_name}-bastion"
  }

  lifecycle {
    precondition {
      condition     = var.subnet_id != null
      error_message = "Subnet ID must be provided if bastion host is being created."
    }
  }
}

resource "aws_security_group" "bastion" {
  count = var.create_bastion ? 1 : 0

  #checkov:skip=CKV2_AWS_5:False positive - the security group is connected to the bastion instance

  name        = "${var.cluster_name}-bastion"
  description = "Security group for bastion hosts"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.cluster_name}-bastion"
  }

  lifecycle {
    precondition {
      condition     = var.vpc_id != null
      error_message = "VPC ID must be provided if bastion host is being created."
    }
  }
}

resource "aws_security_group_rule" "bastion_egress" {
  count = var.create_bastion ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all egress"
  security_group_id = aws_security_group.bastion[0].id
}

resource "aws_security_group_rule" "bastion_ssh" {
  #checkov:skip=CKV_AWS_24:We recommend that 0.0.0.0/0 is not used for port 22 but do not explictly block its use

  count = var.create_bastion && var.bastion_public_access ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.bastion_ssh_authorized_networks
  description       = "Allow SSH to bastion from authorized networks"
  security_group_id = aws_security_group.bastion[0].id

  lifecycle {
    precondition {
      condition     = length(var.bastion_ssh_authorized_networks) > 0
      error_message = "At least one authorized network must be provided if bastion host is publically accessible."
    }
  }
}

resource "aws_security_group_rule" "cluster_from_bastion" {
  count = var.create_bastion ? 1 : 0

  description              = "Allow https traffic to cluster master from bastion"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  type                     = "ingress"
  security_group_id        = var.cluster_security_group_id
  source_security_group_id = aws_security_group.bastion[0].id

  lifecycle {
    precondition {
      condition     = var.cluster_security_group_id != null
      error_message = "Cluster Security Group ID must be provided if bastion host is being created."
    }
  }
}