#!/bin/bash

# To run properly read README.md

set -a
source .env
set +a

# TODO
# Set to "True" or "False", invalid inputs parsed as False
# DELETE_AFTER_FAIL="True"

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
  echo "Artifact name not provided, using packages-layer.zip"
  ARTIFACT="packages-layer.zip"
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

if [ $? -ne 0 ]; then
  echo "❌ Container run failed"
  echo "Check script-for-container.sh and error message to see what went wrong. Exiting."
  exit 1
fi

docker cp "$CONTAINER_NAME:/lambda/layer/$ARTIFACT" "$HOST_PATH/$ARTIFACT"

if [ $? -ne 0 ]; then
  echo "❌ Copying from container failed"
  echo "Container will not be deleted" # Change after adding DELETE_AFTER_FAIL
  echo "Check that the paths and names match. Exiting."
  exit 1
fi

docker rm $CONTAINER_NAME
