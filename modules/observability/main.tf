resource "aws_sns_topic" "dlq_alerts" {
  name = "${var.name_prefix}-dlq-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  count     = var.alert_email != null ? 1 : 0
  topic_arn = aws_sns_topic.dlq_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "dlq_alarm" {
  alarm_name          = "${var.name_prefix}-dlq-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Alarma cuando hay mensajes en la DLQ"

  dimensions = {
    QueueName = var.dlq_queue_name
  }

  alarm_actions = [aws_sns_topic.dlq_alerts.arn]
}
