#######################
### Install Updates ###
#######################
sudo -i
# Fetch latest updates
sudo apt -qqy update && sudo apt upgrade -y

# Install all updates automatically
sudo DEBIAN_FRONTEND=noninteractive apt-get -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' dist-upgrade

######################
### Install Docker ###
######################
# Install dependencies to install Docker
sudo apt -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install ca-certificates curl gnupg lsb-release

# Register Docker package registry
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Refresh package udpates and install Docker
sudo apt -qqy update
sudo apt -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install docker-ce docker-ce-cli containerd.io docker-compose-plugin

##################
### Containers ###
##################
# Create installation directory for Wiki.js
mkdir -p /etc/wiki

# Generate DB secret
openssl rand -base64 32 > /etc/wiki/.db-secret

# Create internal docker network
sudo docker network create wikinet

# Create data volume for PostgreSQL
sudo docker volume create pgdata

# Create the containers
sudo docker create --name=db -e POSTGRES_DB=wiki -e POSTGRES_USER=wiki -e POSTGRES_PASSWORD_FILE=/etc/wiki/.db-secret -v /etc/wiki/.db-secret:/etc/wiki/.db-secret:ro -v pgdata:/var/lib/postgresql/data --restart=unless-stopped -h db --network=wikinet postgres:11
sudo docker create --name=wiki -e DB_TYPE=postgres -e DB_HOST=db -e DB_PORT=5432 -e DB_PASS_FILE=/etc/wiki/.db-secret -v /etc/wiki/.db-secret:/etc/wiki/.db-secret:ro -e DB_USER=wiki -e DB_NAME=wiki -e UPGRADE_COMPANION=1 --restart=unless-stopped -h wiki --network=wikinet -p 80:3000 -p 443:3443 ghcr.io/requarks/wiki:2
sudo docker create --name=wiki-update-companion -v /var/run/docker.sock:/var/run/docker.sock:ro --restart=unless-stopped -h wiki-update-companion --network=wikinet ghcr.io/requarks/wiki-update-companion:latest

################
### FireWall ###
################
#sudo ufw allow ssh
#sudo ufw allow http
#sudo ufw allow https

#sudo ufw --force enable

######################
### Containerizing ###
######################
sudo docker start db
sudo docker start wiki
sudo docker start wiki-update-companion

######################
### SSL Letencrypt ###
###################### 
###     You must complete the setup wizard (see Getting Started) BEFORE enabling Let's Encrypt!
###  1. Create an A record on your domain registrar to point a domain / sub-domain (e.g. wiki.example.com) to your server public IP.
###  2. Make sure you're able to load your wiki using that domain / sub-domain on HTTP (e.g. http://wiki.example.com).
###  3. Connect to your server via SSH.
###  4. Stop and remove the existing wiki container (no data will be lost) by running the commands below:
##docker stop wiki
##docker rm wiki

###  5. Run the following command by replacing the wiki.example.com and admin@example.com values with your own domain / sub-domain and the email address of your wiki administrator
##docker create --name=wiki -e LETSENCRYPT_DOMAIN=wiki.example.com -e LETSENCRYPT_EMAIL=admin@example.com -e SSL_ACTIVE=1 -e DB_TYPE=postgres -e DB_HOST=db -e DB_PORT=5432 -e DB_PASS_FILE=/etc/wiki/.db-secret -v /etc/wiki/.db-secret:/etc/wiki/.db-secret:ro -e DB_USER=wiki -e DB_NAME=wiki -e UPGRADE_COMPANION=1 --restart=unless-stopped -h wiki --network=wikinet -p 80:3000 -p 443:3443 ghcr.io/requarks/wiki:2

###  6. Start the container by running the command:
##docker start wiki

###  7. Wait for the container to start and the Let's Encrypt provisioning process to complete. You can optionaly view the container logs by running the command:
##docker logs wiki

##############################################
### Results at the end of Script after SSL ###
##############################################
###     The process will be completed once you see the following lines in the logs:
###
###     (LETSENCRYPT) New certifiate received successfully: [ COMPLETED ]
###     HTTPS Server on port: [ 3443 ]
###     HTTPS Server: [ RUNNING ]
###
###     Links: https://docs.requarks.io/install/ubuntu
###     Links: https://idroot.us/install-wiki-js-ubuntu-22-04/#:~:text=How%20To%20Install%20Wiki.js%20on%20Ubuntu%2022.04%20LTS,...%206%20Step%206.%20Accessing%20Wiki.js%20Web%20Interface.