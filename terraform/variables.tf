variable "env" {
  type = object({
    region = optional(string, "us-east-1")
  })
}


variable "lambda" {
  type = object({
    # Path to the all the lambda files ( without '/' in the end -> lambda_path not lambda_path/ )
    path = string
    function = object({
      # Name and description of the lambda function 
      name        = string
      description = string

      # Only runtime supported with my scripts is python3.12
      runtime     = optional(string, "python3.12")
      timeout     = optional(number, 10)
      # Name of the py file being pushed to lambda without the .py
      filename = string

      layer = object({
        name = string
        # Where the .zip artifact for the layer will be stored locally - usually `layer`
        host_path = optional(string, "layer")
        # S3 bucket to contain the opencv layer
        bucket = string
        # Must end with .zip
        artifact_name = string
      })
    })
  })

  validation {
    condition     = can(regex("\\.zip$", var.lambda.frames.layer.artifact_name))
    error_message = "artifact_name must end with .zip"
  }
}