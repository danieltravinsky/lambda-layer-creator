## AWS Lambda - Opencv-Python layer creation

The scripts in this repo are for creation of a custom python layer for AWS Lambda on Python 3.12.  
This repo created mainly for an opencv-python layer on AWS Lambda because of lack of support in built-in layers but could be used for more than that.  

>[!NOTE]
>Since opencv-python was the reason for the creation of this repo, the layer is for Python 3.12.
>That is because Lambda 3.9 is on amazonlinux:2 doesn't natively support Python 3.9 (For some reason).
>So for simplicity's sake I used Python 3.12 on amazonlinux:2023 for the layer.

### How to use
First your system needs to have Docker and Docker Build installed and working.  
Edit [requirements.txt](./requirements.txt) for your liking, make sure the packages are supported in python 3.12  
Next make sure [.env](.env) file is set up correctly with the following:
 * ARTIFACT - Name of the file that will be created and copied ( .zip file ). Defaults to `packages-layer.zip`.
 * HOST_PATH - Directory you save the artifact to.
For creation, run [make-layer.sh](make-layer.sh). Make sure you run with elevated privileges since docker commands are being run.

![AVATAR](https://images.weserv.nl/?url=avatars.githubusercontent.com/u/73277118?v=4&width=50&height=50&mask=circle&maxage=7d
)