# ---------- lambda ----------

resource "aws_iam_role" "lambda_role" {
  name = "FunctionExecutionRoleForLambda_lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "${local.account_id}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  policy = data.aws_iam_policy.lambda_basic_execution.policy
  role   = aws_iam_role.lambda_role.id
}