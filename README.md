

# Azure AZ-104 Exam Preparation Scripts

**NOTE: This repository has been updated to v2, which includes refreshed scripts written in PowerShell 7 and aligned with the new course topics. The v1 directory is for reference purposes only.**

## About the AZ-104 Exam
The Azure AZ-104 exam, known as the Microsoft Azure Administrator Associate certification, assesses candidates' abilities to manage Azure identities and governance, implement and manage storage, deploy and manage Azure compute resources, configure and manage virtual networking, and monitor and back up Azure resources. This repository hosts scripts and resources aimed at aiding individuals in preparing for the AZ-104 exam, with practical use cases and exercises across various administrative domains.

## Folder Structure and Topics

The repository is organized into two main versions:

- `v1`: Contains the original scripts and resources based on the previous exam topics.
- `v2`: This is the latest version with updated scripts and resources that reflect the most recent exam topics and are written using PowerShell 7.

### v2 Lab Scripts

#### 050-Administer Virtual Networking
**`nsg-prep-infra.ps1`** - Network Security Groups Lab Infrastructure
- **Purpose**: Creates a test environment with two workloads (A & B) to practice Network Security Group configurations
- **Resources Created**:
  - Resource Group: `rg-nsg-workload-YYYYMMDD`
  - Virtual Network: `vnet-workloads` (192.168.0.0/16)
  - Subnets: `snet-workload-a` (192.168.1.0/24), `snet-workload-b` (192.168.2.0/24)
  - 4 Ubuntu VMs (2 per subnet) with Standard Public IPs
- **Use Case**: Practice configuring NSG rules, application security groups, and network traffic filtering

#### 060-Administer Intersite Connectivity

**`peering-pref-infra.ps1`** - VNet Peering Lab Infrastructure
- **Purpose**: Creates VMs in different Azure regions to practice VNet peering configurations
- **Resources Created**:
  - Resource Group: `rg-vnet-peering-YYYYMMDD`
  - VNet (East US): `vnet-eus` (192.168.0.0/24) with VM `vm-eus`
  - VNet (West US): `vnet-wus` (192.168.1.0/24) with VM `vm-wus`
- **Use Case**: Practice VNet peering, gateway transit, and cross-region connectivity

**`service-endpoints-prep-infra.ps1`** - Service Endpoints Lab Infrastructure
- **Purpose**: Creates infrastructure to practice Azure Service Endpoints with Storage Accounts
- **Resources Created**:
  - Resource Group: `rg-se-workload-YYYYMMDD`
  - Virtual Network: `vnet-01` with Ubuntu VM
  - Azure Storage Account (Standard LRS)
- **Use Case**: Configure service endpoints, private endpoints, and secure Azure services to VNets

#### 070-Administer Network Traffic

**`appgw-prep-infra.ps1`** - Application Gateway Lab Infrastructure
- **Purpose**: Creates a multi-tier web application environment for Application Gateway configuration
- **Resources Created**:
  - Resource Group: `rg-appgw-YYYYMMDD`
  - Virtual Network: `color-web-vnet` (10.0.0.0/16)
  - 4 Subnets: jumpbox, green, red, blue
  - 6 Backend VMs (2 per color pool) + 1 Jumpbox VM
  - NSG with HTTP allow rule
  - Custom Script Extension for web server configuration
- **Use Case**: Practice Application Gateway, backend pools, routing rules, URL-based routing, and health probes

**`loadbalancer-prep-infra.ps1`** - Azure Load Balancer Lab Infrastructure
- **Purpose**: Creates infrastructure for practicing Azure Load Balancer configurations
- **Resources Created**:
  - Resource Group: `rg-azlb-YYYYMMDD`
  - Virtual Network: `eus-web-dev` (10.0.0.0/16)
  - Availability Set with 3 web server VMs
  - Jumpbox VM with Custom Script Extension
  - NSG with HTTP allow rule
- **Use Case**: Configure Azure Load Balancer, backend pools, health probes, load balancing rules, and NAT rules

#### 090-Administer Azure Virtual Machines

**`bastion-prep-infra.ps1`** - Azure Bastion Lab Infrastructure
- **Purpose**: Creates test VMs for practicing secure remote access with Azure Bastion
- **Resources Created**:
  - Resource Group: `rg-remoteaccess-YYYYMMDD`
  - Virtual Network: `vnet-remoteaccess` (10.0.0.0/16)
  - Windows Server 2022 VM in `windows` subnet
  - Ubuntu 22.04 VM in `linux` subnet
  - Individual NSGs for each subnet
- **Use Case**: Deploy and configure Azure Bastion for secure RDP/SSH access without public IPs

#### 120-Administer Monitoring

**`monitoring-prep-infra.ps1`** - Monitoring and Diagnostics Lab Infrastructure
- **Purpose**: Creates diverse Azure resources for practicing monitoring and diagnostics
- **Resources Created**:
  - Resource Group: `rg-secops-YYYYMMDD`
  - Virtual Network: `vnet-workloads` (10.0.0.0/16)
  - Windows Server 2022 VM and Ubuntu VM
  - Azure App Service with Basic tier App Service Plan
- **Use Case**: Configure Azure Monitor, Log Analytics, metrics, alerts, diagnostic settings, and Application Insights

## Prerequisites

Before running the scripts, ensure you have the following prerequisites installed and configured:

- **PowerShell 7** or later
- **Azure PowerShell Module** (`Install-Module -Name Az -Repository PSGallery -Force`)
- **Azure Subscription** with appropriate permissions to create resources
- **Azure CLI** (optional, for alternative management tasks)

## How to Use

1. **Authenticate to Azure**:
   ```powershell
   Connect-AzAccount
   ```

2. **Select your subscription** (if you have multiple):
   ```powershell
   Set-AzContext -SubscriptionId "your-subscription-id"
   ```

3. **Navigate to the desired lab folder** and run the PowerShell script:
   ```powershell
   cd "v2/050- Administer Virtual Networking"
   .\nsg-prep-infra.ps1
   ```

4. **Review the output** - Each script displays:
   - Resource group name
   - VM FQDNs and private IPs
   - Default credentials (username: `kodekloud`, password: `VMP@55w0rd`)

5. **Clean up resources** when done:
   ```powershell
   Remove-AzResourceGroup -Name "resource-group-name" -Force
   ```

## Common Configuration

All v2 scripts use consistent default settings:
- **Default Region**: East US (some scripts use multiple regions)
- **VM Username**: `kodekloud`
- **VM Password**: `VMP@55w0rd`
- **VM Size**: `Standard_B1s` (cost-effective for labs)
- **OS Image**: Ubuntu 22.04 LTS (Linux VMs) / Windows Server 2022 (Windows VMs)
- **Resource Group Naming**: `rg-{purpose}-YYYYMMDD` (includes date stamp)

## Important Notes

⚠️ **Security Warning**: These scripts use hardcoded credentials for lab purposes only. Do not use these credentials or scripts in production environments.

⚠️ **Cost Management**: All scripts create billable Azure resources. Remember to delete resource groups after completing labs to avoid unnecessary charges.

⚠️ **Resource Limits**: Ensure your subscription has sufficient quota for the VMs and resources being created.

## v1 Legacy Scripts

The `v1` folder contains older scripts which shouldn't be used for labs as they are not under active development and may encounter issues:
- **AppGateway**: Multi-tier application gateway demonstration with color-coded backend pools
- **Azure Bastion**: Bastion host deployment for secure VM access
- **Azure Load Balancer**: Standard load balancer with backend pool configuration
- **GatewayTransit**: VNet peering with gateway transit configuration
- **Peering**: Basic VNet peering setup
- **VNet-to-VNet**: VNet-to-VNet VPN gateway configuration


## Issues and Contributions

Encounter an issue or error in the code? Please feel free to open an issue in this repository. Contributions are also welcome if you have enhancements or fixes for the scripts provided.

## License

For learning and development purposes only.
