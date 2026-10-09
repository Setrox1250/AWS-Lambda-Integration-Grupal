locals {
  name_prefix = "image-processor-${var.environment}"
}

module "storage" {
  source        = "../../modules/storage"
  environment   = var.environment
  name_prefix   = local.name_prefix
  force_destroy = true
}

module "network" {
  source      = "../../modules/network"
  environment = var.environment
  name_prefix = local.name_prefix
  vpc_cidr    = var.vpc_cidr
  aws_region  = var.aws_region
  bucket_arn  = module.storage.bucket_arn
}

module "compute" {
  source              = "../../modules/compute"
  environment         = var.environment
  name_prefix         = local.name_prefix
  private_subnet_ids  = module.network.private_subnet_ids
  sg_upload_lambda_id = module.network.sg_upload_lambda_id
  sg_crop_lambda_id   = module.network.sg_crop_lambda_id
  bucket_id           = module.storage.bucket_id
  bucket_arn          = module.storage.bucket_arn
  main_queue_arn      = module.storage.main_queue_arn
  upload_zip_path     = var.upload_zip_path
  crop_zip_path       = var.crop_zip_path
  log_retention_days  = var.log_retention_days
}

module "api" {
  source                      = "../../modules/api"
  environment                 = var.environment
  name_prefix                 = local.name_prefix
  upload_invoke_arn       = module.compute.upload_invoke_arn
  upload_function_arn     = module.compute.upload_function_arn
}

module "observability" {
  source         = "../../modules/observability"
  environment    = var.environment
  name_prefix    = local.name_prefix
  dlq_queue_name = module.storage.dlq_name
}

