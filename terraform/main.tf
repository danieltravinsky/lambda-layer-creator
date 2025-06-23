data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}
data "aws_region" "this" {}

locals {
  account_id = data.aws_caller_identity.this.account_id
  partition  = data.aws_partition.this.partition
  region     = data.aws_region.this.name

  # opencv_layer_local_artifact = "${var.lambda.frames.layer.host_path}/${var.lambda.frames.layer.artifact_name}"
  # opencv_layer_s3_artifact    = "${var.lambda.frames.layer.bucket}/${var.lambda.frames.layer.artifact_name}"
  # opencv_layer_arn = data.external.layer_check.result.exists == "true" ? data.external.layer_check.result.arn : aws_lambda_layer_version.this[0].arn
}