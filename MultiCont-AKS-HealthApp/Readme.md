# My Health Clinic Application

The My Health Clinic (MHC) application is a sample healthcare application that demonstrates the use of Kubernetes and Azure Container Registry (ACR) to deploy and manage microservices for a healthcare system. It includes a backend service using Redis as a database and a front-end service for the clinic's web application.

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Application Deployment](#application-deployment)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Introduction

The My Health Clinic (MHC) application consists of two microservices: the backend service and the front-end service. The backend service uses Redis as a database to store health-related data, and the front-end service provides a web-based user interface to interact with the clinic's services.

The application is deployed using Kubernetes and Azure Container Registry (ACR). The Redis database is deployed as a Kubernetes Deployment, and the front-end service is also deployed as a Kubernetes Deployment. The front-end service is exposed to the internet using a Kubernetes LoadBalancer Service.

## Prerequisites

Before you begin, make sure you have the following prerequisites:

- Kubernetes cluster (AKS or any other Kubernetes cluster)
- Azure Container Registry (ACR) to store the container images
- Terraform
- Docker to build and push the container images to ACR

## Getting Started

To get started with the My Health Clinic application, follow these steps:

1. Clone the repository: `git clone https://github.com/Your-Username/My-Health-Clinic.git`
2. Build the container images for the backend and front-end services using Docker.
3. Push the container images to your Azure Container Registry (ACR).
4. Update the `mhc-front.yaml` file with the correct ACR information in the `image` field.
5. Deploy the application to your Kubernetes cluster using the provided YAML files.


## Application Deployment

# Azure Kubernetes Service (AKS) Infrastructure Deployment
This Terraform script deploys the necessary infrastructure components to set up an Azure Kubernetes Service (AKS) cluster. The script will create the following resources:

- Azure Virtual Network
- Subnet for AKS
- Public IP Address for the Load Balancer
- Load Balancer
- Backend Address Pool for the Load Balancer
- Load Balancer Rule
- Network Interface for AKS
- AKS Cluster


1. Deploy the Redis backend service: kubectl apply -f mhc-back.yaml
2. Deploy the front-end service: kubectl apply -f mhc-front.yaml
3. Expose the front-end service to the internet:  kubectl apply -f mhc-front-service.yaml


The front-end service will be accessible using the public IP provided by the LoadBalancer service.

# Cleanup
To destroy the AKS infrastructure and associated resources, run the following command: terraform destroy

# Note
Please ensure that you have the appropriate permissions and access rights in your Azure subscription to create the resources specified in the Terraform script

## Usage

Once the application is deployed and the front-end service is exposed, you can access the My Health Clinic web application using the public IP provided by the LoadBalancer service. Open a web browser and navigate to the front-end service's public IP to interact with the application.

## Contributing

We welcome contributions to this Terraform script. If you find any issues or have suggestions for improvements, feel free to submit a pull request.

## License

This Terraform script is licensed under the MIT License. See the LICENSE file for more details..


