# Azure VNet-to-VNet VPN with Terragrunt

This project sets up VNet-to-VNet VPN connections between two Azure subscriptions using Terraform modules managed by Terragrunt. It creates a secure connection between virtual networks across different Azure subscriptions.

## 📋 Table of Contents

- [Architecture Overview](#https://github.com/chaudhrysahil08/assignment/blob/main/README.md#%EF%B8%8F-architecture-overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [Authentication Setup](#authentication-setup)
- [Backend Configuration](#backend-configuration)
- [Variable Configuration](#variable-configuration)
- [Running the Deployment](#running-the-deployment)
- [Sample Terraform Plan Output](#sample-terraform-plan-output)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)

## 🏗️ Architecture Overview

This solution creates:
- **Resource Groups** in both subscriptions
- **Virtual Networks** with appropriate subnets
- **VPN Gateways** for each VNet
- **VNet-to-VNet connections** between the networks

```
┌─────────────────────┐    VPN Connection    ┌─────────────────────┐
│   Subscription A    │◄────────────────────►│   Subscription B    │
│                     │                      │                     │
│  ┌───────────────┐  │                      │  ┌───────────────┐  │
│  │   VNet A      │  │                      │  │   VNet B      │  │
│  │ 10.1.0.0/16   │  │                      │  │ 10.2.0.0/16   │  │
│  │               │  │                      │  │               │  │
│  │  VPN Gateway  │  │                      │  │  VPN Gateway  │  │
│  └───────────────┘  │                      │  └───────────────┘  │
└─────────────────────┘                      └─────────────────────┘
```

## 📋 Prerequisites

### Required Software
- **Terraform** >= 1.0
- **Terragrunt** >= 0.80.0
- **Azure CLI** >= 2.0
- **Git**

### Azure Requirements
- Two Azure subscriptions
- Contributor or Owner access to both subscriptions
- Sufficient quota for VPN Gateways (Standard SKU)

### Install Required Tools

**Azure CLI:**
```bash
# Windows (using winget)
winget install Microsoft.AzureCLI

# macOS
brew install azure-cli

# Linux (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

**Terragrunt:**
```bash
# Using curl (Linux/macOS)
curl -Lo terragrunt https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64
chmod +x terragrunt
sudo mv terragrunt /usr/local/bin/

# Windows (using chocolatey)
choco install terragrunt

# macOS
brew install terragrunt
```

## 📁 Project Structure

```
assignment/
├── README.md
├── terragrunt.hcl                    # Root Terragrunt configuration
├── modules/                          # Reusable Terraform modules
│   ├── resource-group/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── virtual-network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── vpn-gateway/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── vpn-connection/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   ├── dev/
│   │   ├── subscription-a/
│   │   │   ├── resource-group/
│   │   │   │   └── terragrunt.hcl
│   │   │   ├── virtual-network/
│   │   │   │   └── terragrunt.hcl
│   │   │   ├── vpn-gateway/
│   │   │   │   └── terragrunt.hcl
│   │   │   └── vpn-connection/
│   │   │       └── terragrunt.hcl
│   │   └── subscription-b/
│   │       ├── resource-group/
│   │       │   └── terragrunt.hcl
│   │       ├── virtual-network/
│   │       │   └── terragrunt.hcl
│   │       ├── vpn-gateway/
│   │       │   └── terragrunt.hcl
│   │       └── vpn-connection/
│   │           └── terragrunt.hcl
│   └── prod/                         # Future production environment
```

## 🔧 Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/chaudhrysahil08/assignment.git
cd assignment
```

### 2. Authentication Setup

#### Method 1: Azure CLI Authentication (Recommended for local development)

```bash
# Login to Azure
az login

# Verify you have access to both subscriptions
az account list --output table

# Set default subscription (subscription-a)
az account set --subscription "12345678-1234-9876-4563-123456789015"
```

#### Method 2: Service Principal Authentication (Recommended for CI/CD)

```bash
# Create a service principal
az ad sp create-for-rbac --name "terraform-vpn-sp" --role Contributor \
  --scopes "/subscriptions/12345678-1234-9876-4563-123456789015" \
          "/subscriptions/12345678-1234-1234-1234-123456789abc"

# Set environment variables
export ARM_CLIENT_ID="<client-id>"
export ARM_CLIENT_SECRET="<client-secret>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"
```

### 3. Backend Configuration

#### Create Storage Accounts for Terraform State

Run this script to create storage accounts in both environments:

```bash
#!/bin/bash
# setup-backend.sh

ENVIRONMENTS=("dev" "prod")
LOCATION="East US"

for ENV in "${ENVIRONMENTS[@]}"; do
    # Create resource group for terraform state
    az group create \
        --name "rg-terraform-state-${ENV}" \
        --location "${LOCATION}"
    
    # Create storage account
    az storage account create \
        --name "satfstate${ENV}02" \
        --resource-group "rg-terraform-state-${ENV}" \
        --location "${LOCATION}" \
        --sku Standard_LRS \
        --kind StorageV2
    
    # Create container
    az storage container create \
        --name "tfstate" \
        --account-name "satfstate${ENV}02"
        
    echo "Backend setup completed for ${ENV} environment"
done
```

Make it executable and run:
```bash
chmod +x setup-backend.sh
./setup-backend.sh
```

### 4. Variable Configuration

#### Update Root Configuration

Edit the root `root.hcl` file and update the subscription IDs:

```hcl
# terragrunt.hcl - Update subscription mapping
subscription_mapping = {
  # Dev subscriptions
  "dev-subscription-a" = "12345678-1234-9876-4563-123456789015"
  "dev-subscription-b" = "12345678-1234-9876-4563-123456789016"
  # Prod subscriptions
  #"prod-subscription-a" = "abcdef12-3456-7890-abcd-ef1234567890"
  #"prod-subscription-b" = "fedcba09-8765-4321-fedc-ba0987654321"
}
```

## 🚀 Running the Deployment

### Pre-deployment Validation

```bash
# Validate Terragrunt configuration
cd assignment
terragrunt validate --all --working-dir=./environments/dev

# Check formatting
terragrunt hclfmt --working-dir=./environments/dev
```

### Planning (Dry Run)

#### Plan All Resources
```bash
# Plan all resources in dev environment
terragrunt plan --all --working-dir=./environments/dev 2>&1 | tee "dev-plan-$(date +%Y%m%d-%H%M%S).txt"
```

#### Plan Specific Subscription
```bash
# Plan only subscription-a resources
cd environments/dev/subscription-a
terragrunt plan --all 2>&1 | tee "../../../subscription-a-plan.txt"

# Plan only subscription-b resources
cd environments/dev/subscription-b
terragrunt plan --all 2>&1 | tee "../../../subscription-b-plan.txt"
```

#### Plan Individual Components
```bash
# Plan only resource groups
terragrunt plan --working-dir=./environments/dev/subscription-a/resource-group
terragrunt plan --working-dir=./environments/dev/subscription-b/resource-group

# Plan only virtual networks
terragrunt plan --working-dir=./environments/dev/subscription-a/virtual-network
terragrunt plan --working-dir=./environments/dev/subscription-b/virtual-network
```

### Applying Changes

#### Recommended Deployment Order

```bash
# Step 1: Deploy resource groups first
terragrunt apply --working-dir=./environments/dev/subscription-a/resource-group
terragrunt apply --working-dir=./environments/dev/subscription-b/resource-group

# Step 2: Deploy virtual networks
terragrunt apply --working-dir=./environments/dev/subscription-a/virtual-network
terragrunt apply --working-dir=./environments/dev/subscription-b/virtual-network

# Step 3: Deploy VPN gateways (takes 20-45 minutes)
terragrunt apply --working-dir=./environments/dev/subscription-a/vpn-gateway
terragrunt apply --working-dir=./environments/dev/subscription-b/vpn-gateway

# Step 4: Create VPN connections
terragrunt apply --working-dir=./environments/dev/subscription-a/vpn-connection
terragrunt apply --working-dir=./environments/dev/subscription-b/vpn-connection
```

#### Apply All at Once (Alternative)
```bash
# Apply all resources in dev environment
terragrunt apply-all --working-dir=./environments/dev
```

### Monitoring Deployment

```bash
# Check deployment status
terragrunt show --working-dir=./environments/dev/subscription-a/vpn-gateway

# View outputs
terragrunt output --working-dir=./environments/dev/subscription-a/vpn-gateway
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Authentication Errors
```bash
# Error: Failed to obtain the token
az login --scope https://management.azure.com//.default
az account set --subscription "your-subscription-id"
```

#### 2. Backend Storage Issues
```bash
# Error: storage account not found
az storage account show --name "satfstatedev02" --resource-group "rg-terraform-state-dev"

# If not exists, run the backend setup script again
./setup-backend.sh
```

#### 3. VPN Gateway Quota Issues
```bash
# Check current usage and limits
az vm list-usage --location "East US 2" --query "[?contains(name.value, 'Gateway')]"

# Request quota increase if needed
az support tickets create --ticket-name "VPN Gateway Quota Increase" --issue-type "QuotaIssue"
```

#### 4. VPN Connection Failures
```bash
# Check VPN gateway status
az network vnet-gateway show --name "vpngw-azure-vnet-vpn-dev-a" --resource-group "rg-azure-vnet-vpn-dev-a"

# Check connection status
az network vpn-connection show --name "conn-dev-a-to-b" --resource-group "rg-azure-vnet-vpn-dev-a"
```

### Debug Commands

```bash
# Enable detailed logging
export TF_LOG=DEBUG
export TERRAGRUNT_LOG_LEVEL=debug

# Validate individual modules
terraform init
terraform validate
terraform plan

# Check state
terragrunt state list
terragrunt state show <resource-name>
```

## 🧹 Cleanup

### Destroy Resources

```bash
# Destroy all resources (CAUTION: This will delete everything)
terragrunt destroy-all --working-dir=./environments/dev

# Destroy specific subscription
cd environments/dev/subscription-a
terragrunt run-all destroy

# Destroy in reverse order (recommended)
terragrunt destroy --working-dir=./environments/dev/subscription-a/vpn-connection
terragrunt destroy --working-dir=./environments/dev/subscription-b/vpn-connection
terragrunt destroy --working-dir=./environments/dev/subscription-a/vpn-gateway
terragrunt destroy --working-dir=./environments/dev/subscription-b/vpn-gateway
terragrunt destroy --working-dir=./environments/dev/subscription-a/virtual-network
terragrunt destroy --working-dir=./environments/dev/subscription-b/virtual-network
terragrunt destroy --working-dir=./environments/dev/subscription-a/resource-group
terragrunt destroy --working-dir=./environments/dev/subscription-b/resource-group
```

### Clean Backend Resources

```bash
# Remove terraform state storage (optional)
az group delete --name "rg-terraform-state-dev" --yes --no-wait
az group delete --name "rg-terraform-state-prod" --yes --no-wait
```

## 📚 Additional Resources

- [Azure VNet-to-VNet VPN Documentation](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-vnet-vnet-resource-manager-portal)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

---

**⚠️ Important Notes:**
- I have replaced the subscription_id's with mock values
- I have also used mock_outputs to avoid dependency issues
- I have only created one environment(dev) and we can replicate all the other environments in the same way
- I generated the plan on my local with backend in Azure Storage account but did not do apply due to non availability of multiple subscriptions
- Provided the output of the plan in the text file - plan.txt which is at the root directory of the repo