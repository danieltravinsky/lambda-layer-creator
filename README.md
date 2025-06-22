## AWS Lambda - Opencv-Python layer creation

The scripts in this repo are for creation of a custom Opencv-Python layer for AWS Lambda on Python 3.12

>[!NOTE]
>The layer is for Python 3.12 because Lambda 3.9 is on amazonlinux:2 which doesn't natively support Python 3.9 ( For some reason ).
>So for simplicity's sake I used Python 3.12 on amazonlinux:2023 for the layer.

### How to use
First your system needs to have Docker and Docker Build installed and working.
Next make sure [.env](.env) file is set up correctly with the following:
 * ARTIFACT - Name of the file that will be created and copied ( .zip file ). Defaults to `opencv-python312-layer.zip`.
 * HOST_PATH - Directory you save the artifact to.
For creation, run [make-layer.sh](make-layer.sh)
