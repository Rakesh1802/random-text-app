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
```

---

## Terraform State

Terraform state file added to the remote backend Azure blob storage account.

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
Required infra deployed by the Terraform IAC tool. All the terraform code resides in the terraform-infra folder.
- The code is modularized for better maintainability.
- Module **dns-link** creates private Dns zone and links it with vnets.
- Module **jump-vm** creates the VM in the Vnet's subnet of primary region.
- Module **oidc-db** creates user assigned managed identity for the apps to be able to connect to the primary Database in the sql server.
- Module **oidc-github** creates user assigned managed identity for the github actions CI/CD pipeline to be able to deploy the app code to Azure web app service.
- Module **region** creates common resources accross the both the regions like, Vnets, app service plan, web app service, subnets, SQL servers, private endpoints etc.,
- Module **resource-group** creates resource groups.
- Module **sql-geo** creates DB in the primary regions Sql server, and fail over group for it, to maintain High Avaialbility of the database.
- Module **traffic-manager** creates traffic manager profile, and links app endpoints of the both the regions.
- Module **vnet-peering** creates vnet peering between vnet1 and vnet2, also vice-versa.


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
- Vnet-peering established between the Vnets, so the primary data base can be accessed by both the region's apps.

---

## CI/CD deployment
The app will be automatically deployed to both the regions, via automated github actions workflow.
- It'll build the node.js app and compiles a zip file, will all the necessary files.
- The zip file will be deployed azure web app service in both the regions.

---

## High Availability
To maintain, High availability the application is deployed with two instances in the azure web app service.
- To maintain HA incase of regional outage, deployed the application in two regions and configured Azure Traffic manager ( though FrontDoor would've been ideal). As i'm using free subscription it did n't allow me to deploy azure front door.
- To maintain DB HA, created and added it faiover group, which replicates read-only replica in secondary region.

---

## Applicatin details:
- App url via traffic manager: http://app-prod.trafficmanager.net/
- App url in the region Central India : https://webapp-centralindia-15590.azurewebsites.net/
- App url in the region East Asia : https://webapp-eastasia-28062.azurewebsites.net/


