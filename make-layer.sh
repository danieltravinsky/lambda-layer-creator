#!/bin/bash

# To run properly read README.md

if [ -z "$HOST_PATH" ] || [ -z "$ARTIFACT" ]; then
  echo "Either HOST_PATH or ARTIFACT env variables is missing, using .env"
  set -a
  source .env
  set +a
fi

if [ -z $HOST_PATH ]; then
  echo "Path not provided in .env, using default value: layer"
  HOST_PATH=layer
fi

mkdir -p $HOST_PATH

if [ -z $ARTIFACT ]; then
  echo "Artifact name not provided in .env, using default value: opencv-python312-layer.zip"
  ARTIFACT="opencv-python312-layer.zip"
fi

# Prompt for the path
# read -p "Enter the full path to mount (e.g. /home/username/data): " host_path

if [ -e "$HOST_PATH/$ARTIFACT" ]; then
    echo "Layer already created, exiting"
    exit 0
fi

if [[ ! "$ARTIFACT" =~ \.zip$ ]]; then
  echo "artifact_name should end with .zip, changing it for you.."
  export ARTIFACT=$ARTIFACT.zip
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
docker run -it -e ARTIFACT="$ARTIFACT" --name "$CONTAINER_NAME" makelayer:latest

docker cp "$CONTAINER_NAME:/lambda/layer/$ARTIFACT" "$HOST_PATH/$ARTIFACT"

if [ "$?" -eq 0 ]; then
  docker rm $CONTAINER_NAME
fi