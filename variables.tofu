# Common vars
variable "ami_id" {
    description = "EC2 AMI to use for both control plane and worker instances"
}
variable "app_name" {
}
variable "aws_region" {
    description = "The AWS region you're deploying to.  For example, 'us-east-1'"
}
variable "deployment_owner" {
    description = "Who did it"
}
variable "home_ipv4" {
    description = "Your IP address for basic testing; will need to be rm'd for practical use"
}
variable "key_name" {
    description = "AWS key for SSH"
}
variable "owner_contact" {
    description = "Team repsonsible for ownership"
}
variable "subnets" {
    description = "Subnets determine the VPC"
}

# Control vars
variable "control_asg_max_size" {
    description = "Max count of concurrent instances for control plane"
}
variable "control_asg_min_size" {
    description = "Min count of concurrent instances for control plane"
}
variable "control_asg_desired_size" {
    description = "Desired count of concurrent instances for control plane"
}
variable "control_ebs_volume_size" {
    description = "Disk size of control plane instance"
    default = 20
}
variable "control_instance_type" {
    description = "Instance type for control plane"
}
variable "control_user_data_path" {
    description = "EC2 user-data for contol plane"
}

# Worker vars
variable "worker_asg_max_size" {
    description = "Max count of concurrent instances for worker"
}
variable "worker_asg_min_size" {
    description = "Max count of concurrent instances for worker"
}
variable "worker_asg_desired_size" {
    description = "Desired count of concurrent instances for worker"
}
variable "worker_ebs_volume_size" {
    description = "Disk size of worker instance"
    default = 20
}
variable "worker_instance_type" {
    description = "Instance type for worker"
}
variable "worker_user_data_path" {
    description = "EC2 user-data for worker"
}

# SG vars
variable "vpc_id" {
    description = "VPC for SGs"
}