# 🛠 IBM webMethods container Image Builder

This repository includes a `build.sh` script for building custom Docker images using predefined templates. The script supports dynamic template selection, image naming, and a debug mode.

---

## Prerequisites

- Download th IBM webMethods Installer from IBM and copy the file as ```installer.bin```to the root folder
- get an entitlement key and user from IBM
- Set the environments variables (see [Environment Variables](#Environment-Variables))

## 🚀 Usage

```bash
./build.sh [-t template] [-i image] [-d]
```

### **Options**
- **`-t template`**  
  The template directory inside `./templates/` to use for building the image.  
  Example: `-t mws` (which uses `./templates/mws/`)

- **`-i image`**  
  The name (and optionally tag) of the image to build.  
  Example: `-i myimage:latest`

- **`-d`**  
  **Debug mode.** Only runs the `docker build` command without appending the installation instructions from the template.

---

## 🔧 Requirements

### **Dependencies**
- Docker or Podman installed
- `installer.bin` file placed in the project root directory
- A `products` file inside the template directory listing the products to install
- A valid `Dockerfile` in the repository (used as the base Dockerfile)
- A `templates/<template>/Dockerfile` and `templates/<template>/install` file to extend the base image

### **Environment Variables**
You must set the following environment variables before running `build.sh`:
- **`ENTITLEMENT_USER`** – Your IBM entitlement username
- **`ENTITLEMENT_KEY`** – Your IBM entitlement key
- **`INSTALLER_VERSION`** – (Optional) Version of the installer
- **`RELEASE`** – (Optional) Release name or version
- **`ADMIN_PASSWORD`** – (Optional) Password for the admin user
- **`BASE_IMAGE`** – (Optional) Base image to use in the Docker build

---

## 📂 Template Structure

A typical template directory should look like this:
```
templates/
  <template>/
    Dockerfile          # Docker instructions specific to this template
    install             # Installation instructions appended to Dockerfile.tmp
    products            # List of products to be installed
```

---

## 🧪 Debug Mode

Use `-d` to enable debug mode:
```bash
./build.sh -t mws -i testimage:debug -d
```
This will:
- Skip adding the template's `Dockerfile` and `install` content
- Run only the raw `docker build` command

---

## 🧹 Cleanup

Temporary files `Dockerfile.tmp` and `installer.script.tmp` may be created during build. Remove them if needed:
```bash
rm -f Dockerfile.tmp installer.script.tmp
```

---

## 🔍 Example Command

```bash
ENTITLEMENT_USER=myuser ENTITLEMENT_KEY=mykey RELEASE=1015 BASE_IMAGE=docker.io/redhat/ubi8:latest ADMIN_PASSWORD=manage ./build.sh -t mws -i mws-custom:10.15
```

---

## ⚠️ Notes

- Make sure to download **`installer.bin`** from [IBM FixCentral](https://www.ibm.com/support/fixcentral/) (search for **webMethods Installer**).
- Your IBM ID and entitlement details are required to access certain components.
