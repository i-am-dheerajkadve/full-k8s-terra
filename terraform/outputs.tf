output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app_repo.repository_url
}

output "vpc_id" {
  value = aws_vpc.dheeraj_vpc.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "kubectl_update_command" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.eks.name}"
}
