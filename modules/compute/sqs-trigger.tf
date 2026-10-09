
resource "aws_lambda_event_source_mapping" "crop_sqs" {
  event_source_arn        = var.main_queue_arn
  function_name           = aws_lambda_function.crop.arn
  batch_size              = 5
  function_response_types = ["ReportBatchItemFailures"]
  enabled                 = true
}