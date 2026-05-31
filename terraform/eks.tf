resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_version

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  vpc_config {
    subnet_ids = [
      aws_subnet.public_1.id,
      aws_subnet.public_2.id,
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]

    endpoint_public_access  = true
    endpoint_private_access = false
  }

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_cloudwatch_log_group.eks_cluster_logs
  ]
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.environment}-devops-node-group"
  node_role_arn   = aws_iam_role.node_role.arn

  # Public subnets used intentionally because NAT Gateway is not required in this project.
  subnet_ids = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  scaling_config {
    desired_size = var.desired_node_count
    max_size     = var.max_node_count
    min_size     = var.min_node_count
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = [var.node_instance_type]
  capacity_type  = "ON_DEMAND"
  disk_size      = 20

  labels = {
    environment = var.environment
    project     = "devops-eks"
  }

  tags = {
    Name        = "${var.environment}-eks-node-group"
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_readonly,
    aws_iam_role_policy_attachment.cloudwatch_agent_policy
  ]
}
