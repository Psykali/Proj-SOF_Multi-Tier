#!/bin/bash

# Update the package list
sudo apt-get update

# Install required packages
sudo apt-get install -y curl mongodb-server graphicsmagick

# Add the MongoDB GPG signing key
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

# Add the MongoDB repository
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list

# Update the package list again
sudo apt-get update

# Install snapd
sudo apt-get install snapd -y

# Install Rocket.Chat server
sudo snap install rocketchat-server

# Open the firewall for HTTP and HTTPS traffic
sudo ufw allow http
sudo ufw allow https

# Start the Rocket.Chat service
sudo systemctl start snap.rocketchat-server.rocketchat-server.service

# Enable the Rocket.Chat service to start on boot
sudo systemctl enable snap.rocketchat-server.rocketchat-server.service