#!/bin/bash

# Set variables
vm_username="skrcadmin"
vm_password="P@P@ssw0rd123P@ssw0rd123"
vm_ip_address="skrcvm.francecentral.cloudapp.azure.com"

# Copy rocket-chat-install.sh to the Azure VM
sshpass -p "$vm_password" scp rocket-chat-install.sh "$vm_username@$vm_ip_address:/tmp/rocket-chat-install.sh"

# Run rocket-chat-install.sh on the Azure VM
sshpass -p "$vm_password" ssh "$vm_username@$vm_ip_address" << EOF
  chmod +x /tmp/rocket-chat-install.sh
  /tmp/rocket-chat-install.sh
EOF
