resource "aws_cloudwatch_log_group" "eks_cluster_logs" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7

  tags = {
    Name        = "${var.environment}-eks-cluster-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "eks_node_cpu_high" {
  alarm_name          = "${var.environment}-eks-node-cpu-high"
  alarm_description   = "Alert when EKS worker node CPU is high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = aws_eks_node_group.nodes.resources[0].autoscaling_groups[0].name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
