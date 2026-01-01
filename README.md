# App code + Azure infra

This repository provisions Azure infrastructure using Terraform and
application code for the random quote/text display.

---

## Architecture Overview

- Azure Virtual Network (VNet)
- Subnets
- App Service
- Azure SQL Database
- Managed Identity authentication
- Vnet Peering
- Azure Front Door
- Azure Traffic manager

---

## Repository Structure
```text
.
├── .github
│   └── workflows
│       └── main_webapp.yml
├── app
├── db
│   └── init.sql
├── public
│   ├── index.html
│   └── script.js
├── package.json
├── package-lock.json
├── server.js
├── terraform-infra
│   ├── envs
│   │   ├── .terraform.lock.hcl
│   │   ├── main.tf
│   │   ├── providers.tf
│   │   └── variables.tf
│   └── modules
│       ├── dns-link
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       ├── front-door
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       ├── jump-vm
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       ├── oidc-db
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       ├── oidc-github
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       ├── region
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       ├── resource-group
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       ├── sql-geo
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       ├── traffic-manager
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       └── vnet-peering
│           ├── main.tf
│           ├── outputs.tf
│           └── variables.tf
├── .gitignore
└── README.md

---

## Terraform State

As of now, the state is not added to the backend

---

## Configuration

No secrets are stored in this repository.

Required variables are supplied via:
- Environment variables
- CI/CD pipeline secrets
- `.tfvars` (excluded from Git)

---

## App code
All the app code resides in the app folder
- It's a node.js application
- Reads quote/text the from database and populate in the website

---

## Azure infrastructure code
Required infra deployed by the Terraform IAC tool.
- The code is modularized for better maintainability.

---

## Architecture
This infra and application is deployed in two regions Central India and East Asia to maintain regional failover availability.
- As i'm using free subscription it did n't allow to deploy azure front door, to maintain regional failover case.
- Went with Azure Traffic manager for now.
- A SQL Failover Group is configured to maintain database availability across regions.
- SQL servers are created with public access disabled.
- Private Endpoints are created for the SQL servers within private subnets of the VNets.
- The application is deployed to Azure Web App Service with two instances per region.
- App Service instances are integrated with the VNets.
- A jump VM is deployed inside the VNet for data population and user management.
- Vnet-peering established between the Vnets, so the primary data base can be accessed by both the regions apps.

---

## Applicatin details:
- App url via traffic manager: http://app-prod.trafficmanager.net/
- App url in the region Central India : https://webapp-centralindia-15590.azurewebsites.net/
- App url in the region East Asia : https://webapp-eastasia-28062.azurewebsites.net/


