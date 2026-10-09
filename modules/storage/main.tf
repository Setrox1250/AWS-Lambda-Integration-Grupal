data "aws_caller_identity" "current" {}

locals {
  account_id       = data.aws_caller_identity.current.account_id
  bucket_name      = "${var.name_prefix}-images-${local.account_id}"
  uploads_prefix   = "uploads/"
  processed_prefix = "processed/"
}

resource "aws_s3_bucket" "images" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_public_access_block" "images" {
  bucket = aws_s3_bucket.images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "images" {
  bucket = aws_s3_bucket.images.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  depends_on = [aws_s3_bucket_versioning.images]

  rule {
    id     = "expire-uploads"
    status = "Enabled"

    filter {
      prefix = local.uploads_prefix
    }

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id     = "expire-processed"
    status = "Enabled"

    filter {
      prefix = local.processed_prefix
    }

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

#********
# SQS: cola principal + DLQ
#********

resource "aws_sqs_queue" "dlq" {
  name                      = "${var.name_prefix}-image-dlq"
  message_retention_seconds = 1209600 # 14 dias
}

resource "aws_sqs_queue" "main" {
  name                       = "${var.name_prefix}-image-queue"
  visibility_timeout_seconds = 360
  message_retention_seconds  = 86400 # 1 dia
  receive_wait_time_seconds  = 20    # long polling

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
}

# Solo la cola principal puede usar esta DLQ.
resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  queue_url = aws_sqs_queue.dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.main.arn]
  })
}

#********
# Permiso S3 -> SQS (restringido por bucket y cuenta)
#********

data "aws_iam_policy_document" "queue" {
  statement {
    sid       = "AllowS3SendMessage"
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.main.arn]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.images.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
  }
}

resource "aws_sqs_queue_policy" "main" {
  queue_url = aws_sqs_queue.main.id
  policy    = data.aws_iam_policy_document.queue.json
}


#********
# Evento: solo ObjectCreated bajo uploads/ 
#********

resource "aws_s3_bucket_notification" "uploads" {
  bucket = aws_s3_bucket.images.id

  queue {
    queue_arn     = aws_sqs_queue.main.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = local.uploads_prefix
  }

  depends_on = [aws_sqs_queue_policy.main]
}