# ---------- flashlight lambda ----------

data "archive_file" "python_flashlight_lambda_package" {
  type        = "zip"
  source_file = "${var.lambda.path}/${var.lambda.flashlight.filename}.py"
  output_path = "${var.lambda.path}/${var.lambda.flashlight.filename}.zip"
}

resource "aws_lambda_function" "flashlight_lambda" {
  function_name = var.lambda.flashlight.name
  role          = aws_iam_role.flashlight_lambda_role.arn
  description   = var.lambda.flashlight.description
  handler       = "${var.lambda.flashlight.filename}.lambda_handler"
  filename      = "${var.lambda.path}/${var.lambda.flashlight.filename}.zip"

  runtime = var.lambda.flashlight.runtime
  timeout = var.lambda.flashlight.timeout

  source_code_hash = data.archive_file.python_flashlight_lambda_package.output_base64sha256
}

resource "aws_lambda_permission" "flashlight_lambd_permissions" {
  action         = "lambda:invokeFunction"
  function_name  = aws_lambda_function.flashlight_lambda.function_name
  principal      = "bedrock.amazonaws.com"
  source_account = local.account_id
  source_arn     = "arn:aws:bedrock:${local.region}:${local.account_id}:agent/*"
}

# ---------- drone lambdas ----------

data "archive_file" "python_drone_r_lambda_package" {
  type        = "zip"
  source_file = "${var.lambda.path}/${var.lambda.drone_r.filename}.py"
  output_path = "${var.lambda.path}/${var.lambda.drone_r.filename}.zip"
}

data "archive_file" "python_drone_l_lambda_package" {
  type        = "zip"
  source_file = "${var.lambda.path}/${var.lambda.drone_l.filename}.py"
  output_path = "${var.lambda.path}/${var.lambda.drone_l.filename}.zip"
}

resource "aws_lambda_function" "drone_l_lambda" {
  function_name = var.lambda.drone_l.name
  role          = aws_iam_role.drone_lambdas_role.arn
  description   = var.lambda.drone_l.description
  handler       = "${var.lambda.drone_l.filename}.lambda_handler"
  filename      = "${var.lambda.path}/${var.lambda.drone_l.filename}.zip"

  runtime = var.lambda.drone_l.runtime
  timeout = var.lambda.drone_l.timeout

  source_code_hash = data.archive_file.python_drone_r_lambda_package.output_base64sha256
}


resource "aws_lambda_function" "drone_r_lambda" {
  function_name = var.lambda.drone_r.name
  role          = aws_iam_role.drone_lambdas_role.arn
  description   = var.lambda.drone_r.description
  handler       = "${var.lambda.drone_r.filename}.lambda_handler"
  filename      = "${var.lambda.path}/${var.lambda.drone_r.filename}.zip"

  runtime = var.lambda.drone_r.runtime
  timeout = var.lambda.drone_r.timeout

  source_code_hash = data.archive_file.python_drone_l_lambda_package.output_base64sha256
}

resource "aws_lambda_permission" "drone_r_lambda_permissions" {
  action         = "lambda:invokeFunction"
  function_name  = aws_lambda_function.drone_r_lambda.function_name
  principal      = "bedrock.amazonaws.com"
  source_account = local.account_id
  source_arn     = "arn:aws:bedrock:${local.region}:${local.account_id}:agent/*"
}

resource "aws_lambda_permission" "drone_l_lambda_permissions" {
  action         = "lambda:invokeFunction"
  function_name  = aws_lambda_function.drone_l_lambda.function_name
  principal      = "bedrock.amazonaws.com"
  source_account = local.account_id
  source_arn     = "arn:aws:bedrock:${local.region}:${local.account_id}:agent/*"
}

# ---------- frames lambda ----------

# data "archive_file" "python_frames_lambda_package" {
#   type        = "zip"
#   source_file = "${var.lambda.path}/${var.lambda.frames.filename}.py"
#   output_path = "${var.lambda.path}/${var.lambda.frames.filename}.zip"
# }

# resource "aws_lambda_function" "frames_lambda" {
#   function_name = var.lambda.frames.name
#   role          = aws_iam_role.frames_lambda_role.arn
#   description   = var.lambda.frames.description
#   handler       = "${var.lambda.frames.filename}.lambda_handler"
#   filename      = "${var.lambda.path}/${var.lambda.frames.filename}.zip"

#   runtime = var.lambda.frames.runtime
#   timeout = var.lambda.frames.timeout

#   layers = [local.opencv_layer_arn]

#   source_code_hash = data.archive_file.python_frames_lambda_package.output_base64sha256
# }

# data "external" "layer_check" {
#   program = ["bash", "${path.module}/${var.lambda.path}/for-layer-creation/check-layer.sh", var.lambda.frames.layer.name]
# }

# resource "terraform_data" "build_layer" {
#   count = data.external.layer_check.result.exists == "false" ? 1 : 0

#   provisioner "local-exec" {
#     command = <<EOT
#       set -e
#       export ARTIFACT=${var.lambda.frames.layer.artifact_name}
#       export HOST_PATH=${var.lambda.frames.layer.host_path}
#       cd ${var.lambda.path}/for-layer-creation/
#       ./make-layer.sh
#     EOT
#   }

#   depends_on = [ data.external.layer_check ]
# }

# resource "aws_s3_object" "lambda_layer_zip" {
#   count = data.external.layer_check.result.exists == "false" ? 1 : 0

#   bucket = var.lambda.frames.layer.bucket
#   key    = var.lambda.frames.layer.artifact_name
#   source = "${var.lambda.path}/for-layer-creation/${var.lambda.frames.layer.host_path}/${var.lambda.frames.layer.artifact_name}"

#   depends_on = [terraform_data.build_layer]
# }

# resource "aws_lambda_layer_version" "this" {
#   count = data.external.layer_check.result.exists == "false" ? 1 : 0

#   s3_bucket           = var.lambda.frames.layer.bucket
#   s3_key              = var.lambda.frames.layer.artifact_name
#   layer_name          = var.lambda.frames.layer.name
#   compatible_runtimes = [var.lambda.frames.runtime]
#   skip_destroy        = true

#   depends_on = [ aws_s3_object.lambda_layer_zip ]
# }



# For now, layer creation will be a separate process, please make sure a layer file exists within
# s3://${var.lambda.frames.layer.bucket}/${var.lambda.frames.layer.artifact_name}
# For further information on layer creation please go to ${var.lambda.path}/for-layer-creation/README.md

data "archive_file" "python_frames_lambda_package" {
  type        = "zip"
  source_file = "${var.lambda.path}/${var.lambda.frames.filename}.py"
  output_path = "${var.lambda.path}/${var.lambda.frames.filename}.zip"
}

resource "aws_lambda_function" "frames_lambda" {
  function_name = var.lambda.frames.name
  role          = aws_iam_role.frames_lambda_role.arn
  description   = var.lambda.frames.description
  handler       = "${var.lambda.frames.filename}.lambda_handler"
  filename      = "${var.lambda.path}/${var.lambda.frames.filename}.zip"
  
  runtime = var.lambda.frames.runtime
  timeout = var.lambda.frames.timeout
  
  layers = [ aws_lambda_layer_version.opencv_layer.arn ]
  source_code_hash = data.archive_file.python_frames_lambda_package.output_base64sha256
}

resource "aws_lambda_layer_version" "opencv_layer" {
  s3_bucket           = var.lambda.frames.layer.bucket
  s3_key              = var.lambda.frames.layer.artifact_name
  layer_name          = var.lambda.frames.layer.name
  compatible_runtimes = [var.lambda.frames.runtime]

  skip_destroy        = true
}


# ---------- agent invocatio lambda ----------

data "archive_file" "python_agent_invocation_lambda_package" {
  type        = "zip"
  source_file = "${var.lambda.path}/${var.lambda.agent_invocation.filename}.py"
  output_path = "${var.lambda.path}/${var.lambda.agent_invocation.filename}.zip"
}

resource "aws_lambda_function" "agent_invocation_lambda" {
  function_name = var.lambda.agent_invocation.name
  role          = aws_iam_role.agent_invocation_lambda_role.arn
  description   = var.lambda.agent_invocation.description
  handler       = "${var.lambda.agent_invocation.filename}.lambda_handler"
  filename      = "${var.lambda.path}/${var.lambda.agent_invocation.filename}.zip"

  runtime = var.lambda.agent_invocation.runtime
  timeout = var.lambda.agent_invocation.timeout

  source_code_hash = data.archive_file.python_agent_invocation_lambda_package.output_base64sha256
}

resource "aws_lambda_permission" "agent_invocation_lambd_permissions" {
  action         = "lambda:invokeFunction"
  function_name  = aws_lambda_function.agent_invocation_lambda.function_name
  principal      = "bedrock.amazonaws.com"
  source_account = local.account_id
  source_arn     = "arn:aws:bedrock:${local.region}:${local.account_id}:agent/*"
}