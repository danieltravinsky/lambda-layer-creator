#!/bin/bash

# To run properly read README.md

# The priority for variables goes as following: artgument -> .env file -> shell variables -> default values

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --path)
            HOST_PATH="$2"
            shift 2
            ;;
	--artifact)
	    ARTIFACT="$2"
	    shift 2
	    ;;
	--delete-after-fail)
	    DELETE_AFTER_FAIL="$2"
	    shift 2
	    ;;
	--dont-build)
	    DONT_BUILD="$2"
	    shift 2
	    ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done

# Function to set default values of variables if it has no value already, pass in variable name and default value like so:
# set-defaults HOST_PATH default-path ARTIFACT default-artifact DELETE_AFTER_FAIL default-delete
# This will make it so that $HOST_PATH = default-path etc..
function set-defaults() {
  while [[ "$#" -gt 0 ]]; do
    var=$1
    default=$2
    if [ -z ${!var} ]; then
      echo "Setting default value of $var to $default"
      declare -g "$var=$default"
    fi
  shift 2
  done
}

# Function that checks if passed variables (pass variable names) are empty, if any of them is, read from .env
function check-if-empty() {
  declare -A env_map

  # Read .env file
  while IFS='=' read -r key val; do
    [[ -n "$key" ]] && env_map["$key"]="$val"
  done < .env

  # Read through variables and set empty ones .env
  while [[ "$#" -gt 0 ]]; do
    var=$1
    if [ -z ${!var} ]; then
      value=${env_map[$var]}
      # echo "Variable $var is missing, using $value from .env"
      # echo $(awk -F '=' -v k="$var" '$1 ~ var {print $2}' .env)
      # declare -g "$var=$(awk -F '=' -v k="$var" '$1 ~ var {print $2}' .env)"
      declare -g "$var=$value"
    fi
    shift 1
  done
}

check-if-empty HOST_PATH ARTIFACT DELETE_AFTER_FAIL HOST_PATH

set-defaults HOST_PATH layer ARTIFACT packages-layer.zip DELETE_AFTER_FAIL false DONT_BUILD true

if [[ "$DELETE_AFTER_FAIL" != "true" && "$DELETE_AFTER_FAIL" != "false" ]]; then
  echo "Invalid value for DELETE_AFTER_FAIL: $DELETE_AFTER_FAIL -> setting default value false"
  DELETE_AFTER_FAIL="False"
fi

mkdir -p $HOST_PATH

if [[ ! "$ARTIFACT" =~ \.zip$ ]]; then
  echo "artifact_name should end with .zip, changing it for you.."
  export ARTIFACT=$ARTIFACT.zip
fi

# Verify the path exists
if [ ! -d "$HOST_PATH" ]; then
  echo "Error: Directory does not exist."
  exit 1
fi

if [ $DONT_BUILD ]; then
  echo "DONT_BUILD variable set to true, skipping layer creation"
  exit 0
fi

if [ -e "$HOST_PATH/$ARTIFACT" ]; then
    echo "Layer already created or file with the name $HOST_PATH/$ARTIFACT alread exists, exiting"
    exit 0
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
  echo "Check that the paths and names match. Exiting."
  if [ $DELETE_AFTER_FAIL ]; then
    echo "DELETE_AFTER_FAIL set to True, deleting container $CONTAINER_NAME"
    docker rm $CONTAINER_NAME
  else
    echo "DELETE_AFTER_FAIL set to False, keeping container $CONTAINER_NAME"
  exit 1
else
  echo "Copying completed successfully to $HOST_PATH/$ARTIFACT"
  echo "Deleting container $CONTAINER_NAME"
  docker rm $CONTAINER_NAME
fi
