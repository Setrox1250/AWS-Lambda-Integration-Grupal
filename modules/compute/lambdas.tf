
resource "aws_cloudwatch_log_group" "upload" {
  name              = "/aws/lambda/${local.upload_function_name}"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "crop" {
  name              = "/aws/lambda/${local.crop_function_name}"
  retention_in_days = var.log_retention_days
}


resource "aws_lambda_function" "upload" {
  function_name = local.upload_function_name
  role          = aws_iam_role.upload.arn
  runtime       = var.runtime
  handler       = "index.handler"
  memory_size   = 256
  timeout       = 30

  filename         = var.upload_zip_path
  source_code_hash = filebase64sha256(var.upload_zip_path)

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.upload_lambda_sg_id]
  }

  environment {
    variables = {
      S3_BUCKET     = var.bucket_id
      UPLOAD_PREFIX = "uploads/"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.upload,
    aws_iam_role_policy_attachment.upload_basic,
    aws_iam_role_policy_attachment.upload_vpc,
    aws_iam_role_policy.upload_s3,
  ]
}


resource "aws_lambda_function" "crop" {
  function_name = local.crop_function_name
  role          = aws_iam_role.crop.arn
  runtime       = var.runtime
  handler       = "index.handler"
  memory_size   = 512
  timeout       = 60

  filename         = var.crop_zip_path
  source_code_hash = filebase64sha256(var.crop_zip_path)

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.crop_lambda_sg_id]
  }

  environment {
    variables = {
      S3_BUCKET        = var.bucket_id
      PROCESSED_PREFIX = "processed/"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.crop,
    aws_iam_role_policy_attachment.crop_basic,
    aws_iam_role_policy_attachment.crop_vpc,
    aws_iam_role_policy.crop_access,
  ]
}