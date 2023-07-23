#!/bin/bash

# Update the system
sudo apt update && sudo apt upgrade

# Install Java
sudo apt install default-jdk gnupg2

# Add the XWiki GPG public key and repository
wget https://maven.xwiki.org/xwiki-keyring.gpg -P /usr/share/keyrings/
wget https://maven.xwiki.org/stable/xwiki-stable.list -P /etc/apt/sources.list.d/
sudo apt update

# Install XWiki along with Tomcat and MySQL
sudo apt install xwiki-tomcat9-common xwiki-tomcat9-mariadb

# Install Nginx as a web server
sudo apt install nginx

# Create a new Nginx virtual host file
sudo bash -c "cat > /etc/nginx/sites-available/xwiki.conf << EOL
server {
    listen 80;
    server_name example.com;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    server_name example.com;

    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

    location / {
        proxy_pass http://localhost:8080/xwiki/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
EOL"

# Enable the virtual host
sudo ln -s /etc/nginx/sites-available/xwiki.conf /etc/nginx/sites-enabled/

# Restart Nginx
sudo systemctl restart nginx

echo "XWiki has been installed. You can access the web interface by navigating to http://your_server_ip:8080/xwiki/ in your web browser."
