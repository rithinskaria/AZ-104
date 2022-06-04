
Clear-Host
#Variables
$rg = read-host "(new) Resource Group Name"
$region = "eastus"
$username = "kodekloud" #username for the VM
$plainPassword = "VMP@55w0rd" #your VM password

#Creating VM credential; use your own password and username by changing the variables if needed
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $password);

#Create RG
New-AzResourceGroup -n $rg -l $region

#########-----Create resources---------######

#Creating vnet and VMs

Write-Host "Adding subnet configuration" `
-ForegroundColor "Yellow" -BackgroundColor "Black"
$workloads = New-AzVirtualNetworkSubnetConfig `
  -Name 'privateSubnet' `
  -AddressPrefix 10.0.0.0/24

New-AzVirtualNetwork `
  -ResourceGroupName $rg `
  -Location $region `
  -Name "prod-eus-vnet" `
  -AddressPrefix 10.0.0.0/16 `
  -Subnet $workloads

Write-Host "Creating Linux VM" -ForegroundColor "Yellow" -BackgroundColor "Black"
$linuxVm = New-AzVM -Name 'linux-prod-server' `
  -ResourceGroupName $rg `
  -Location $region `
  -Size 'Standard_B1s' `
  -Image UbuntuLTS `
  -VirtualNetworkName prod-eus-vnet `
  -SubnetName 'privateSubnet' `
  -Credential $credential 
$windowsVm = New-AzVM -Name 'win-prod-server' `
-ResourceGroupName $rg `
-Location $region `
-Size 'Standard_D2s_v3' `
-VirtualNetworkName prod-eus-vnet `
-SubnetName 'privateSubnet' `
-Credential $credential

$fqdn = $linuxVm.FullyQualifiedDomainName
Write-Host "Linux VM DNS name : $fqdn "
$fqdn = $windowsVm.FullyQualifiedDomainName
Write-Host "Windows VM DNS name : $fqdn "
