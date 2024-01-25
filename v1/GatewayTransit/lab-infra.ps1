$rg = read-host "(new) Resource Group Name"
$region = "eastus"
$username = "kodekloud" #username for the VM
$plainPassword = "VMP@55w0rd" #your VM password


#Creating VM credential; use your own password and username by changing the variables if needed
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $password);

#Create RG
New-AzResourceGroup -n $rg -l $region


#--------------------------Spoke 1-----------------------#

Write-Host "Adding spoke-1 subnet configuration" `
-ForegroundColor "Yellow" -BackgroundColor "Black"

$s1Subnet = New-AzVirtualNetworkSubnetConfig `
  -Name 'default' `
  -AddressPrefix 10.0.0.0/24

New-AzVirtualNetwork `
  -ResourceGroupName $rg `
  -Location eastus `
  -Name "spoke-1-vnet" `
  -AddressPrefix 10.0.0.0/16 `
  -Subnet $s1Subnet

$spoke1Vm = New-AzVM -Name 'spoke-1-vm' `
  -ResourceGroupName $rg `
  -Location eastus `
  -Size 'Standard_B1s' `
  -Image UbuntuLTS `
  -VirtualNetworkName spoke-1-vnet `
  -SubnetName 'default' `
  -Credential $credential `

Write-Host "Configuring spoke-1 VM" -BackgroundColor Green -ForegroundColor White 

$Params = @{
    ResourceGroupName  = $rg
    VMName             = 'spoke-1-vm'
    Name               = 'CustomScript'
    Publisher          = 'Microsoft.Azure.Extensions'
    ExtensionType      = 'CustomScript'
    TypeHandlerVersion = '2.1'
    Settings          = @{fileUris = @('https://raw.githubusercontent.com/rithinskaria/kodekloud-azure/main/GatewayTransit/configureSpoke1.sh'); commandToExecute = './configureSpoke1.sh'}
}


#--------------------------Spoke 2-----------------------#

Write-Host "Adding spoke-2 subnet configuration" `
-ForegroundColor "Yellow" -BackgroundColor "Black"

$s2Subnet = New-AzVirtualNetworkSubnetConfig `
  -Name 'default' `
  -AddressPrefix 10.1.0.0/24

New-AzVirtualNetwork `
  -ResourceGroupName $rg `
  -Location westus `
  -Name "spoke-2-vnet" `
  -AddressPrefix 10.1.0.0/16 `
  -Subnet $s2Subnet

$spoke2Vm = New-AzVM -Name 'spoke-2-vm' `
  -ResourceGroupName $rg `
  -Location westus `
  -Size 'Standard_B1s' `
  -Image UbuntuLTS `
  -VirtualNetworkName spoke-2-vnet `
  -SubnetName 'default' `
  -Credential $credential `


Write-Host "Configuring spoke-2 VM" -BackgroundColor Green -ForegroundColor White 

$Params = @{
    ResourceGroupName  = $rg
    VMName             = 'spoke-2-vm'
    Name               = 'CustomScript'
    Publisher          = 'Microsoft.Azure.Extensions'
    ExtensionType      = 'CustomScript'
    TypeHandlerVersion = '2.1'
    Settings          = @{fileUris = @('https://raw.githubusercontent.com/rithinskaria/kodekloud-azure/main/GatewayTransit/configureSpoke2.sh'); commandToExecute = './configureSpoke2.sh'}
}


#---------------------------Creating hub resources-----------------------#

$hubSubnet = New-AzVirtualNetworkSubnetConfig `
  -Name 'default' `
  -AddressPrefix 10.2.1.0/24

$hubGateway = New-AzVirtualNetworkSubnetConfig `
 -Name 'GatewaySubnet' `
 -AddressPrefix 10.2.0.0/28

New-AzVirtualNetwork `
  -ResourceGroupName $rg `
  -Location eastus `
  -Name "hub-vnet" `
  -AddressPrefix 10.2.0.0/16 `
  -Subnet $hubSubnet, $hubGateway

$hubgwpip= New-AzPublicIpAddress `
-Name pip-vpn-hub `
-ResourceGroupName $rg `
-Location 'East US' `
-AllocationMethod Dynamic

$vnet = Get-AzVirtualNetwork `
-Name hub-vnet `
-ResourceGroupName $rg

$subnet = Get-AzVirtualNetworkSubnetConfig `
-Name 'GatewaySubnet' `
-VirtualNetwork $vnet

$gwipconfig = New-AzVirtualNetworkGatewayIpConfig `
-Name 'hub-vpngw' `
-SubnetId $subnet.Id `
-PublicIpAddressId $hubgwpip.Id

New-AzVirtualNetworkGateway `
-Name hub-vpngw `
-ResourceGroupName $rg `
-Location 'East US' `
-IpConfigurations $gwipconfig `
-GatewayType Vpn `
-VpnType RouteBased `
-GatewaySku VpnGw1
