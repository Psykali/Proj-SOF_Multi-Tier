#!/bin/bash

# Create resource group
##az group create --name PERSO_SIEF --location eastus

# Create virtual network
az network vnet create --resource-group PERSO_SIEF --name skvnet --address-prefixes 10.0.0.0/16

# Create subnet
az network vnet subnet create --resource-group PERSO_SIEF --vnet-name skvnet --name sksubnet --address-prefixes 10.0.0.0/24

# Create public IP address
az network public-ip create --resource-group PERSO_SIEF --name skpublicip

# Create load balancer
az network lb create --resource-group PERSO_SIEF --name sklb --public-ip-address skpublicip --frontend-ip-name skfrontendip --backend-pool-name skbackendpool

# Create health probe
az network lb probe create --resource-group PERSO_SIEF --lb-name sklb --name skhealthprobe --protocol tcp --port 80

# Create load balancing rule
az network lb rule create --resource-group PERSO_SIEF --lb-name sklb --name skloadbalancingrule --protocol tcp --frontend-port 80 --backend-port 80 --frontend-ip-name skfrontendip --backend-pool-name skbackendpool --probe-name skhealthprobe

# Create two virtual machines
az vm create \
    --resource-group PERSO_SIEF \
    --name skvm1 \
    --image UbuntuLTS \
    --admin-username azureuser \
    --generate-ssh-keys \
    --vnet-name skvnet \
    --subnet sksubnet \
    --nsg "" \
    --public-ip-address ""

az vm create \
    --resource-group PERSO_SIEF \
    --name skvm2 \
    --image UbuntuLTS \
    --admin-username azureuser \
    --generate-ssh-keys \
    --vnet-name skvnet \
    --subnet sksubnet \
    --nsg "" \
    --public-ip-address ""

# Add virtual machines to backend pool
az network nic ip-config address-pool add \
    -g PERSO_SIEF \
    -n ipconfig1 \
    -lb-name sklb \
    -lb-address-pools skbackendpool

az network nic ip-config address-pool add \
    -g PERSO_SIEF \
    -n ipconfig1 \
    -lb-name sklb \
    -lb-address-pools skbackendpool