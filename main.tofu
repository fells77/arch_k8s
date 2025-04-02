terraform {
    required_providers {
        aws = "~> 5"
    }
}

provider "aws" {
    region = var.aws_region
}

resource "aws_launch_template" "k8s_control" {
    name                            = "${var.app_name}-control_template"
    block_device_mappings {
        device_name                     = "/dev/sdf"
        ebs {
            volume_size = var.control_ebs_volume_size
            encrypted   = true
        }
    }
    ebs_optimized                   = true
    image_id                        = var.ami_id
    instance_type                   = var.control_instance_type
    key_name                        = var.key_name
    metadata_options {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
        instance_metadata_tags      = "enabled"
    }
    monitoring {
        enabled                     = true
    }
    network_interfaces {
        associate_public_ip_address = true
        security_groups             = [ aws_security_group.control_sg.id ]
    }
    tag_specifications {
        resource_type               = "instance"
        tags = {
            Name = "test"
        }
    }
    user_data = filebase64(var.control_user_data_path)
}

resource "aws_launch_template" "k8s_worker" {
    name                            = "${var.app_name}-worker_template"
    block_device_mappings {
        device_name                     = "/dev/sdf"
        ebs {
            volume_size = var.worker_ebs_volume_size
            encrypted   = true
        }
    }
    ebs_optimized                   = true
    image_id                        = var.ami_id
    instance_type                   = var.worker_instance_type
    key_name                        = var.key_name
    metadata_options {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
        instance_metadata_tags      = "enabled"
    }
    monitoring {
        enabled                     = true
    }
    network_interfaces {
        associate_public_ip_address = true
        security_groups             = [ aws_security_group.worker_sg.id ]
    }
    tag_specifications {
        resource_type               = "instance"
        tags = {
            Name = "test"
        }
    }
    user_data = filebase64(var.worker_user_data_path)
}

resource "aws_autoscaling_group" "control_fixer" {
    health_check_grace_period = 180
    health_check_type         = "EC2"
    launch_template {
        id      = aws_launch_template.k8s_control.id
        version = "$Latest"
    }
    max_size                  = var.control_asg_max_size
    min_size                  = var.control_asg_min_size
    name                      = "${var.app_name}-control"
    vpc_zone_identifier       = [ var.subnets ]
    tag {
        key                 = "Name"
        value               = "${var.app_name}-EC2"
        propagate_at_launch = true
    }
    tag {
        key                 = "Application"
        value               = var.app_name
        propagate_at_launch = true
    }
    tag {
        key                 = "OwnerContact"
        value               = var.owner_contact
        propagate_at_launch = true
    }
    tag {
        key                 = "DeploymentOwner"
        value               = var.deployment_owner
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_group" "worker_fixer" {
    health_check_grace_period = 180
    health_check_type         = "EC2"
    launch_template {
        id      = aws_launch_template.k8s_worker.id
        version = "$Latest"
    }
    max_size                  = var.worker_asg_max_size
    min_size                  = var.worker_asg_min_size
    name                      = "${var.app_name}-worker"
    vpc_zone_identifier       = [ var.subnets ]
    tag {
        key                 = "Name"
        value               = "${var.app_name}-EC2"
        propagate_at_launch = true
    }
    tag {
        key                 = "Application"
        value               = var.app_name
        propagate_at_launch = true
    }
    tag {
        key                 = "OwnerContact"
        value               = var.owner_contact
        propagate_at_launch = true
    }
    tag {
        key                 = "DeploymentOwner"
        value               = var.deployment_owner
        propagate_at_launch = true
    }
}

resource "aws_security_group" "control_sg" {
    name        = "${var.app_name}-control"
    description = "k8s control plane SG"
    vpc_id      = var.vpc_id
    ingress {
        description      = "SSH ingress"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = [ var.home_ipv4 ]
    }
    ingress {
        description      = "etcd server client API"
        from_port        = 2379
        to_port          = 2380
        protocol         = "tcp"
        security_groups  = [ aws_security_group.worker_sg.id ]
        self             = true
    }
    ingress {
        description      = "k8s API server"
        from_port        = 6443
        to_port          = 6443
        protocol         = "tcp"
        cidr_blocks      = [ var.home_ipv4 ]
    }
    ingress {
        description      = "Kubelet API"
        from_port        = 10250
        to_port          = 10250
        protocol         = "tcp"
        security_groups  = [ aws_security_group.worker_sg.id ]
        self             = true
    }
    ingress {
        description      = "kube-controller-manager"
        from_port        = 10257
        to_port          = 10257
        protocol         = "tcp"
        security_groups  = [ aws_security_group.worker_sg.id ]
    }
    ingress {
        description      = "kube-scheduler"
        from_port        = 10259
        to_port          = 10259
        protocol         = "tcp"
        security_groups  = [ aws_security_group.worker_sg.id ]
    }
    
    tags = {
        Application         = var.app_name
        DeploymentOwner     = var.deployment_owner
        OwnerContact        = var.owner_contact
    }
}

resource "aws_security_group" "worker_sg" {
    name        = "${var.app_name}-worker"
    description = "k8s worker SG"
    vpc_id      = var.vpc_id
    ingress {
        description      = "Kubelet API"
        from_port        = 10250
        to_port          = 10250
        protocol         = "tcp"
        security_groups  = [ aws_security_group.control_sg.id ]
        self             = true
    }
    ingress {
        description      = "kube-proxy"
        from_port        = 10256
        to_port          = 10256
        protocol         = "tcp"
        security_groups  = [ aws_security_group.control_sg.id ]
        self             = true
    }
    tags = {
        Application         = var.app_name
        DeploymentOwner     = var.deployment_owner
        OwnerContact        = var.owner_contact
    }
}