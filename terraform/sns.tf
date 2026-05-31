resource "aws_sns_topic" "alerts" {
  name = "${var.environment}-devops-alerts"

  tags = {
    Name        = "${var.environment}-devops-alerts"
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
