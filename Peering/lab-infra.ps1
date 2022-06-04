
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

Write-Host "Creating East US VM" -ForegroundColor "Yellow" -BackgroundColor "Black"
$eusVm = New-AzVM -Name 'eus-prod-server' `
  -ResourceGroupName $rg `
  -Location eastus `
  -Size 'Standard_B1s' `
  -Image UbuntuLTS `
  -VirtualNetworkName eus-vnet `
  -SubnetName 'default' `
  -Credential $credential `
  -PublicIpAddressName 'eus-vm-pip'

Write-Host "Creating West US VM" -ForegroundColor "Yellow" -BackgroundColor "Black" 
$wusVm = New-AzVM -Name 'wus-prod-server' `
-ResourceGroupName $rg `
-Location westus `
-Image UbuntuLTS `
-Size 'Standard_B1s' `
-VirtualNetworkName wus-vnet `
-SubnetName 'default' `
-Credential $credential

$fqdn = $eusVm.FullyQualifiedDomainName
Write-Host "East US VM DNS name : $fqdn "
$fqdn = $wusVm.FullyQualifiedDomainName
Write-Host "West US VM DNS name : $fqdn "
