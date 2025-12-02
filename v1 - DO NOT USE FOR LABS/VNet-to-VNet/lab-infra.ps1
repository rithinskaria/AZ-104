
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

#########-----Create EUS resources---------######


Write-Host "Adding EUS subnet configuration" `
-ForegroundColor "Yellow" -BackgroundColor "Black"

$eusSubnet = New-AzVirtualNetworkSubnetConfig `
  -Name 'default' `
  -AddressPrefix 10.0.1.0/24
$eusGateway = New-AzVirtualNetworkSubnetConfig `
 -Name 'GatewaySubnet' `
 -AddressPrefix 10.0.0.0/28

New-AzVirtualNetwork `
  -ResourceGroupName $rg `
  -Location eastus `
  -Name "eus-vnet" `
  -AddressPrefix 10.0.0.0/16 `
  -Subnet $eusSubnet,$eusGateway

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


$eusgwpip= New-AzPublicIpAddress `
-Name pip-vpn-eus `
-ResourceGroupName $rg `
-Location 'East US' `
-AllocationMethod Dynamic

$vnet = Get-AzVirtualNetwork `
-Name eus-vnet `
-ResourceGroupName $rg

$subnet = Get-AzVirtualNetworkSubnetConfig `
-Name 'GatewaySubnet' `
-VirtualNetwork $vnet

$gwipconfig = New-AzVirtualNetworkGatewayIpConfig `
-Name vpngw-eus `
-SubnetId $subnet.Id `
-PublicIpAddressId $eusgwpip.Id

New-AzVirtualNetworkGateway `
-Name vpngw-eus `
-ResourceGroupName $rg `
-Location 'East US' `
-IpConfigurations $gwipconfig `
-GatewayType Vpn `
-VpnType RouteBased `
-GatewaySku VpnGw1


#########-----Create WUS resources---------######

Write-Host "Adding WUS subnet configuration" `
-ForegroundColor "Yellow" -BackgroundColor "Black"
$wusSubnet = New-AzVirtualNetworkSubnetConfig `
  -Name 'default' `
  -AddressPrefix 192.168.1.0/24

$wusGateway = New-AzVirtualNetworkSubnetConfig `
 -Name 'GatewaySubnet' `
 -AddressPrefix 192.168.0.0/28

New-AzVirtualNetwork `
  -ResourceGroupName $rg `
  -Location westus `
  -Name "wus-vnet" `
  -AddressPrefix 192.168.0.0/16 `
  -Subnet $wusSubnet,$wusGateway

Write-Host "Creating West US VM" -ForegroundColor "Yellow" -BackgroundColor "Black" 
$wusVm = New-AzVM -Name 'wus-prod-server' `
-ResourceGroupName $rg `
-Location westus `
-Image UbuntuLTS `
-Size 'Standard_B1s' `
-VirtualNetworkName wus-vnet `
-SubnetName 'default' `
-Credential $credential



$wusgwpip= New-AzPublicIpAddress `
-Name pip-vpn-wus `
-ResourceGroupName $rg `
-Location 'West US' `
-AllocationMethod Dynamic

$vnet = Get-AzVirtualNetwork `
-Name wus-vnet `
-ResourceGroupName $rg

$subnet = Get-AzVirtualNetworkSubnetConfig `
-Name 'GatewaySubnet' `
-VirtualNetwork $vnet

$gwipconfig = New-AzVirtualNetworkGatewayIpConfig `
-Name vpngw-wus `
-SubnetId $subnet.Id `
-PublicIpAddressId $wusgwpip.Id

New-AzVirtualNetworkGateway `
-Name vpngw-wus `
-ResourceGroupName $rg `
-Location 'West US' `
-IpConfigurations $gwipconfig `
-GatewayType Vpn `
-VpnType RouteBased `
-GatewaySku VpnGw1

$fqdn = $eusVm.FullyQualifiedDomainName
Write-Host "East US VM DNS name : $fqdn "
$fqdn = $wusVm.FullyQualifiedDomainName
Write-Host "West US VM DNS name : $fqdn "
