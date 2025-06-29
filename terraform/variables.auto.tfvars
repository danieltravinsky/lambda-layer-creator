env = {}

lambda = {
  path      = "lambda-stuff"

  frames = {
    name        = "sample"
    description = "sample lambda"
    filename    = "lambda-script.py"
    runtime     = "python3.12"
    timeout     = 10
    layer = {
      name = "opencv-python312-layer"
      artifact_name = "opencv-layer.zip" # Must end with .zip
      host_path = "layer"
      bucket = "sample-bucket-123"
    }
  }
}