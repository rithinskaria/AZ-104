#Pref
$WarningPreference = 'SilentlyContinue'

#Variables
$region = "eastus"
$username = "kodekloud" #username for the VM
$plainPassword = "VMP@55w0rd" #your VM password
$VMSize = "Standard_B1s"

#Creating VM credential; use your own password and username by changing the variables
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $password);
#Create RG
$rg = "rg-secops-$(Get-Date -Format 'yyyyMMdd')"
New-AzResourceGroup -n $rg -l $region

########-----Create resources---------######

#Creating vnet

Write-Host "Adding subnet configuration" `
    -ForegroundColor "Yellow" -BackgroundColor "Black"

$windows = New-AzVirtualNetworkSubnetConfig `
    -Name 'windows' `
    -AddressPrefix 10.0.1.0/24
 
$linux = New-AzVirtualNetworkSubnetConfig `
    -Name 'linux' `
    -AddressPrefix 10.0.2.0/24

Write-Host "Creating vnet-workloads" `
    -ForegroundColor "Yellow" -BackgroundColor "Black"

New-AzVirtualNetwork `
    -ResourceGroupName $rg `
    -Location $region `
    -Name "vnet-workloads" `
    -AddressPrefix 10.0.0.0/16 `
    -Subnet $windows, $linux  | Out-Null

#Create Windows VM
Write-Host "Creating Windows VM" `
    -ForegroundColor "Yellow" -BackgroundColor "Black"
New-AzVm `
    -ResourceGroupName $rg `
    -Name 'win-ra-vm' `
    -Location $region `
    -Image 'MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest' `
    -VirtualNetworkName "vnet-workloads" `
    -SubnetName 'windows' `
    -SecurityGroupName 'windows-nsg' `
    -Credential $credential 

#Create Linux VM
Write-Host "Creating Linux VM" `
    -ForegroundColor "Yellow" -BackgroundColor "Black"
New-AzVm `
    -ResourceGroupName $rg `
    -Name 'linux-ra-vm' `
    -Location $region `
    -Image 'Ubuntu2204' `
    -VirtualNetworkName "vnet-workloads" `
    -SubnetName 'linux' `
    -SecurityGroupName 'linux-nsg' `
    -Credential $credential `
    -Size $VMSize

Write-Host "Creating App Service" `
    -ForegroundColor "Yellow" -BackgroundColor "Black"

    $asp  = New-AzAppServicePlan `
    -ResourceGroupName $rg `
    -Name "asp-$(Get-Random)" `
    -Location $region `
    -Tier Basic `
    -WorkerSize Small
New-AzWebApp `
    -ResourceGroupName $rg `
    -Name "demoApp$(Get-Random)" `
    -Location $region `
    -AppServicePlan $asp.Name
