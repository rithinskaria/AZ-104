#Load Balancing Lab - Infra only script

# LB is not included in the scrip

Clear-Host
#Variables
$region = "eastus"
$username = "kodekloud" #username for the VM
$plainPassword = "VMP@55w0rd" #your VM password
$VMSize = "Standard_B1s"

#Creating VM credential; use your own password and username by changing the variables
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force


#Create RG
$rg = Read-Host "(new)Resource group name"
New-AzResourceGroup -n $rg -l $region

#########-----Create resources---------######

#Creating vnet

Write-Host "Adding subnet configuration" `
-ForegroundColor "Yellow" -BackgroundColor "Black"

$jumpBox = New-AzVirtualNetworkSubnetConfig `
  -Name 'jumpboxSubnet' `
  -AddressPrefix 10.0.1.0/24
 
$webServers = New-AzVirtualNetworkSubnetConfig `
  -Name 'webSubnet' `
  -AddressPrefix 10.0.2.0/24

Write-Host "Creating eus-web-dev" `
-ForegroundColor "Yellow" -BackgroundColor "Black"

$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $rg `
  -Location $region `
  -Name "eus-web-dev" `
  -AddressPrefix 10.0.0.0/16 `
  -Subnet $jumpBox, $webServers

$webRule = New-AzNetworkSecurityRuleConfig -Name web-rule -Description "Allow HTTP" -Access Allow `
    -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 80

$networkSecurityGroup = New-AzNetworkSecurityGroup -ResourceGroupName $rg `
-Location $region -Name "webNSG" -SecurityRules $rdpRule

Set-AzVirtualNetworkSubnetConfig -Name webSubnet -VirtualNetwork $vnet -AddressPrefix "10.0.2.0/24" `
-NetworkSecurityGroup $networkSecurityGroup

$vnet | Set-AzVirtualNetwork

Write-Host "Creating availability set" `
-ForegroundColor "Yellow" -BackgroundColor "Black"

$avSet = New-AzAvailabilitySet -ResourceGroupName $rg -Name "az-web-set" `
-Location $region -PlatformUpdateDomainCount 3 `
-PlatformFaultDomainCount 3 -Sku "Aligned"

for($i=1; $i -le 3; $i++){

    $webServersNIC = New-AzNetworkInterface -Name "webserver-0$i-nic" -ResourceGroupName $rg `
    -Location $region -SubnetId $vnet.Subnets[1].Id

    Write-Host "----------------------------------------------------" `
    -ForegroundColor "Yellow" -BackgroundColor "Black"

    $credential = New-Object System.Management.Automation.PSCredential ($username, $password);

    Write-Host "Setting VM config" -ForegroundColor "Yellow" -BackgroundColor "Black"

    $VirtualMachine = New-AzVMConfig -VMName "webserver-0$i" -VMSize $VMSize -AvailabilitySetId $avSet.Id

    Write-Host "Setting OS Profile" -ForegroundColor "Yellow" -BackgroundColor "Black"

    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine `
    -Linux -ComputerName "webserver0$i" -Credential $credential

    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $webServersNIC.Id

        $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine `
            -PublisherName 'Canonical' `
            -Offer '0001-com-ubuntu-server-jammy' `
            -Skus '22_04-lts-gen2' `
            -Version latest 

    Write-Host "Creating VM webserver-0$i" -ForegroundColor "Yellow" -BackgroundColor "Black"
    New-AzVM -ResourceGroupName $rg -Location $region -VM $VirtualMachine

}

 
Write-Host "Creating jumpbox VM" -ForegroundColor "Yellow" -BackgroundColor "Black"
$jumpVm = New-AzVM -Name jumpbox-vm `
-ResourceGroupName $rg `
-Location $region `
-Size 'Standard_B1s' `
-Image UbuntuLTS `
-VirtualNetworkName eus-web-dev `
-SubnetName jumpboxSubnet `
-Credential $credential `
-PublicIpAddressName 'jumpbox-pip'

Write-Host "Configuring VMs..." -BackgroundColor Yellow -ForegroundColor White 

$Params = @{
    ResourceGroupName  = $rg
    VMName             = 'jumpbox-vm'
    Name               = 'CustomScript'
    Publisher          = 'Microsoft.Azure.Extensions'
    ExtensionType      = 'CustomScript'
    TypeHandlerVersion = '2.1'
    Settings          = @{fileUris = @('https://raw.githubusercontent.com/rithinskaria/kodekloud-azure/main/Azure%20Load%20Balancer/jumpbox.sh'); commandToExecute = './jumpbox.sh'}
}
Set-AzVMExtension @Params

Write-Host "Deployment Completed!!" -BackgroundColor Yellow -ForegroundColor White 

$fqdn = $jumpVm.FullyQualifiedDomainName
Write-Host "Jumpbox VM DNS name : $fqdn "
for ($i=1; $i -le 3; $i++){

    $vmIP= (Get-AzNetworkInterface -Name "webserver-0$i-nic").IpConfigurations.PrivateIPAddress
    Write-Host "Private IP (webserver-0$i) :$vmIP"

}
