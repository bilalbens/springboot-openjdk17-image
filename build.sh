#!/bin/bash

# Echo starting of building process
echo "====================== building"
# Build the Docker image
chmod +x start.sh
docker build -t bilalbens/${IMAGE_NAME} -f Dockerfile .

# Check if CI_USER is not empty
if [ ! -z "${CI_USER}" ]; then
    # Login to Docker registry
    docker login -u ${CI_USER} -p ${CI_PASSWORD}
    # Echo starting of pushing process
    echo "====================== pushing"
    # Push the Docker image
    docker push bilalbens/${IMAGE_NAME}
fi
