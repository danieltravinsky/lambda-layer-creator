#!/bin/bash

# To run properly read README.md

set -a
source .env
set +a

# Parse arguments
# while [[ "$#" -gt 0 ]]; do
#     case $1 in
#         --path)
#             HOST_PATH="$2"
#             shift 2
#             ;;
#         *)
#             echo "Unknown parameter passed: $1"
#             exit 1
#             ;;
#     esac
# done

if [ -z $HOST_PATH ]; then
  echo "Path not provided, using ./layer"
  HOST_PATH=layer
fi

mkdir -p $HOST_PATH

if [ -z $ARTIFACT ]; then
  echo "Artifact name not provided, using opencv-python312-layer.zip"
  ARTIFACT="opencv-python312-layer.zip"
fi

# Prompt for the path
# read -p "Enter the full path to mount (e.g. /home/username/data): " host_path

if [ -e "$HOST_PATH/$ARTIFACT" ]; then
    echo "Layer already created, exiting"
    exit 0
fi

# Verify the path exists
if [ ! -d "$HOST_PATH" ]; then
  echo "Error: Directory does not exist."
  exit 1
fi

# Check if image "makelayer" exists
if ! docker image inspect makelayer > /dev/null 2>&1; then
  echo "🔍 Image 'makelayer' not found. Building from Dockerfile..."

  docker build -t makelayer .
  
  if [ $? -ne 0 ]; then
    echo "❌ Docker build failed."
    exit 1
  fi
else
  echo "✅ Image 'makelayer' found."
fi

# Generate timestamp-based name
CONTAINER_NAME="layer-builder-$(date +%s)"

# Run Docker container with volume attached
docker run -it --env-file .env --name "$CONTAINER_NAME" makelayer:latest

docker cp "$CONTAINER_NAME:/lambda/layer/$ARTIFACT" "$HOST_PATH/$ARTIFACT"

docker rm $CONTAINER_NAME