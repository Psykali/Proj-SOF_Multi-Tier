#######################
### Install Updates ###
#######################
# Fetch latest updates
sudo apt -qqy update && sudo apt upgrade -y

###################################
### Installing the Dependencies ###
###################################
sudo apt install ca-certificates curl openssh-server postfix tzdata perl

#########################
### Installing Gitlab ###
#########################
cd /tmp

curl -LO https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh

sudo bash /tmp/script.deb.sh

sudo apt install gitlab-ce

################
### FireWall ###
################
#sudo ufw allow http
#sudo ufw allow https
#sudo ufw allow OpenSSH

##########################
### Gitlab File Config ###
##########################
sudo sed -i 's/http://your_domain/http://IPAddr/' /etc/gitlab/gitlab.rb

sudo gitlab-ctl reconfigure