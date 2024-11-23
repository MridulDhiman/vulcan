#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Installing Docker...
echo "Installing Docker..."
sudo apt-get install -y docker.io

# Start Docker service...
echo "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to docker group to avoid using sudo
echo "Adding current user to docker group..."
sudo usermod -aG docker ubuntu

echo "Pulling Docker image..."
sudo docker pull $DOCKER_USERNAME/$IMAGE_NAME:$TAG_NAME
# Run the container
echo "Running the container..."
sudo docker run -d -p 3000:3000 $DOCKER_USERNAME/$IMAGE_NAME:$TAG_NAME

# Print success message
echo "Setup complete! The application should now be running on port 3000"
echo "To check container status, run: docker ps"
echo "To view logs, run: docker logs <container_id>"