# ─────────────────────────────────────────────────────────────────────────────
# modules/network/security-groups.tf
# Tres Security Groups del Mermaid:
#   sg-upload-lambda : sin ingress; egress TCP 443 → S3 prefix list + SQS VPCE
#   sg-crop-lambda   : sin ingress; egress TCP 443 → S3 prefix list + SQS VPCE
#   sg-vpce-sqs      : ingress TCP 443 desde ambos SGs de Lambda
#
# Nota: el S3 Gateway Endpoint NO tiene SG propio (tipo Gateway, sin ENI)
# El egress hacia S3 se controla con la prefix list administrada por AWS
# ─────────────────────────────────────────────────────────────────────────────

# Prefix list de S3 administrada por AWS, necesaria para las reglas de egress
data "aws_ec2_managed_prefix_list" "s3" {
  name = "com.amazonaws.${var.aws_region}.s3"
}

# Security Groups 
# Las reglas se definen como recursos separados para evitar ciclos de dependencia

resource "aws_security_group" "upload_lambda" {
  name        = "${var.name_prefix}-sg-upload-lambda"
  description = "SG Upload Lambda: sin ingress, egress HTTPS a S3 GW y SQS VPCE"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-sg-upload-lambda"
  }
}

resource "aws_security_group" "crop_lambda" {
  name        = "${var.name_prefix}-sg-crop-lambda"
  description = "SG Crop Lambda: sin ingress, egress HTTPS a S3 GW y SQS VPCE"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-sg-crop-lambda"
  }
}

resource "aws_security_group" "vpce_sqs" {
  name        = "${var.name_prefix}-sg-vpce-sqs"
  description = "SG SQS Interface Endpoint: ingress TCP 443 desde Lambdas"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-sg-vpce-sqs"
  }
}

# Reglas de Upload Lambda

resource "aws_security_group_rule" "upload_egress_s3" {
  type              = "egress"
  security_group_id = aws_security_group.upload_lambda.id
  description       = "Salida HTTPS hacia S3 via Gateway Endpoint (prefix list)"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.s3.id]
}

resource "aws_security_group_rule" "upload_egress_sqs" {
  type                     = "egress"
  security_group_id        = aws_security_group.upload_lambda.id
  description              = "Salida HTTPS hacia SQS Interface Endpoint"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.vpce_sqs.id
}

# Reglas de Crop Lambda

resource "aws_security_group_rule" "crop_egress_s3" {
  type              = "egress"
  security_group_id = aws_security_group.crop_lambda.id
  description       = "Salida HTTPS hacia S3 via Gateway Endpoint (prefix list)"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.s3.id]
}

resource "aws_security_group_rule" "crop_egress_sqs" {
  type                     = "egress"
  security_group_id        = aws_security_group.crop_lambda.id
  description              = "Salida HTTPS hacia SQS Interface Endpoint"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.vpce_sqs.id
}

# Reglas del SQS VPCE SG

resource "aws_security_group_rule" "vpce_ingress_upload" {
  type                     = "ingress"
  security_group_id        = aws_security_group.vpce_sqs.id
  description              = "HTTPS desde sg-upload-lambda"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.upload_lambda.id
}

resource "aws_security_group_rule" "vpce_ingress_crop" {
  type                     = "ingress"
  security_group_id        = aws_security_group.vpce_sqs.id
  description              = "HTTPS desde sg-crop-lambda"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.crop_lambda.id
}
