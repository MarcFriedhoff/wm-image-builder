#!/bin/bash

debug=false

while getopts "t:i:d" opt; do
  case $opt in
    t)
      template="$OPTARG"
      ;;
    i)
      image="$OPTARG"
      ;;
    d)
      debug=true
      ;;
    \?)
      echo "Usage: $0 [-t template] [-i image] [-d]"
      echo "       template: the template file to use for creating the image"
      echo "       image: the name of the image to build"
      echo "       -d: enable debug mode (only runs the docker build command without installation)"
      exit 1
      ;;
  esac
done

# echo the provided arguments
echo "Template: $template"
echo "Image: $image"
echo "Debug mode: ${debug:-false}"

rm *.tmp 2>/dev/null

# check if template directory exists
if [ ! -d "./templates/$template" ]; then
  echo "Template directory $template does not exist. Please provide a valid template directory."
  exit 1
fi

# read products file from template directory
if [ ! -f "./templates/$template/products" ]; then
  echo "Products file not found in template directory. Please ensure the products file exists in the specified template directory."
  exit 1
fi

# read products from template directory
PRODUCTS=$(cat "templates/$template/products")  

# check if products are set
echo "Products: $PRODUCTS"

# Determine docker_cmd
if [[ -n "$docker_cmd" ]]; then
  # Use existing environment variable
  docker_cmd="$docker_cmd"
elif command -v docker &> /dev/null; then
  docker_cmd="docker"
elif command -v podman &> /dev/null; then
  docker_cmd="podman"
else
  echo "Error: Neither docker_cmd is set, nor docker/podman found in PATH." >&2
  exit 1
fi

# check if installer.bin exists
if [ ! -f installer.bin ]; then
  echo "installer.bin not found. Please place the installer.bin in the current directory. To download the installer visit https://www.ibm.com/support/fixcentral/ and search for 'webMethods Installer'. Download the latest version for Linux and place it in the current directory as installer.bin."
  exit 1
fi

# check if ENTITLEMENT_USER and ENTITELEMENT_KEY are set
if [ -z "${ENTITLEMENT_USER}" ] || [ -z "${ENTITLEMENT_KEY}" ]; then
  echo "Please set the ENTITLEMENT_USER and ENTITLEMENT_KEY environment variables. To obtain entitlment key and user, visit https://www.ibm.com/mysupport/ and log in with your IBM ID. Then navigate to 'My Products and Services' and find the webMethods product you are entitled to."
  exit 1
fi

cp Dockerfile Dockerfile.tmp
# if debug mode is enabled only run the docker build command
if [ "${debug:-false}" = true ]; then
  echo "Debug mode enabled. Only running the docker build command."
  cat "./templates/$template/install" >> installer.script.tmp

else 
  cat "./templates/$template/Dockerfile" >> Dockerfile.tmp
  cat "./templates/$template/install" >> installer.script.tmp
fi

# concatenate dockerfile from template directory and Dockerfile 

${docker_cmd} build --platform=linux/amd64 -f Dockerfile.tmp -t ${image} \
  --build-arg ENTITLEMENT_USER="${ENTITLEMENT_USER}" \
  --build-arg ENTITLEMENT_KEY="${ENTITLEMENT_KEY}" \
  --build-arg INSTALLER_VERSION="${INSTALLER_VERSION}" \
  --build-arg RELEASE="${RELEASE}" \
  --build-arg ADMIN_PASSWORD="${ADMIN_PASSWORD}" \
  --build-arg PRODUCTS="${PRODUCTS}"  \
  --build-arg BASE_IMAGE="${BASE_IMAGE}" \
  --build-arg DEBUG="${debug:-false}" \
  --no-cache \
  . 
