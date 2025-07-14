## Opencv layer creation
The main idea of this method is checking if layer was created using [check-layer.sh](./lambda-stuff/for-layer-creation/check-layer.sh), then depending on the output of the script either build, push to S3, and create layer for the lambda or skip all that process entirely.

The intended folder structure would be the following:

📂 **terraform/**  
├── 📄 `main.tf`  
├── 📄 `variables.tf`  
├── 📄 `outputs.tf`  
├── 📄 `providers.tf`  
├── 📄 `other-terraform-files.tf`  
├── 📂 **lambda-stuff/**  
│   ├── 🐍 `lambda-script.py`  
│   ├── 📂 **for-layer-creation/** <--- Contents of [this repo](/../)  
│   │   ├── 🐳 `Dockerfile`  
│   │   ├── ⚙️ `make-layer.sh`  
│   │   ├── 📝 `.env`  
│   │   ├── ⚙️ `script-for-container.sh`  
└   └   └── ⚙️ `check-layer.sh`  
  
>[!NOTE]
>While the structure exists in this repo, the files within [for-layer-creation](./lambda-stuff/for-layer-creation/) don't contain
the real scripts to avoid copy pasting after every change.  
>Make sure you swap them.
