#!/bin/bash

set -e

python3.12 -m venv /tmp/venv
source /tmp/venv/bin/activate
pip install opencv-python-headless numpy

cp -r /tmp/venv/lib64/python3.12/site-packages/* /lambda/python/
cd /lambda
zip -r9 layer/$ARTIFACT python