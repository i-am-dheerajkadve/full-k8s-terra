variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "dheeraj-eks-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment name like dev, oa, prod"
  type        = string
  default     = "dev"
}

variable "alert_email" {
  description = "Email address for SNS alert notification"
  type        = string
  default     = "dheerajeducation892@gmail.com"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "c7i-flex.large"
}

variable "desired_node_count" {
  type    = number
  default = 1
}

variable "min_node_count" {
  type    = number
  default = 1
}

variable "max_node_count" {
  type    = number
  default = 1
}

variable "eks_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.35"
}
