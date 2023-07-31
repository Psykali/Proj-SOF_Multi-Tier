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
- Docker installed on your local machine to build and push the container images to ACR

## Getting Started

To get started with the My Health Clinic application, follow these steps:

1. Clone the repository: `git clone https://github.com/Your-Username/My-Health-Clinic.git`
2. Build the container images for the backend and front-end services using Docker.
3. Push the container images to your Azure Container Registry (ACR).
4. Update the `mhc-front.yaml` file with the correct ACR information in the `image` field.
5. Deploy the application to your Kubernetes cluster using the provided YAML files.

## Application Deployment

The application can be deployed to a Kubernetes cluster using the provided YAML files. Follow the steps below to deploy the application:

1. Deploy the Redis backend service:

