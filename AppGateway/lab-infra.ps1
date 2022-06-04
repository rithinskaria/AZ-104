#Application Gateway Demo Infra - v2.0, written by Rithin Skaria
Clear-Host
#Variables
$rg = read-host "(new) Resource Group Name"
$region = "eastus"
$username = "kodekloud" #username for the VM
$plainPassword = "VMP@55w0rd" #your VM password
$VMSize = "Standard_B1s"

#Creating VM credential; use your own password and username by changing the variables if needed
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force

Write-Host "Application Gateway Demo Infra - v2.0, written by Rithin Skaria" `
-ForegroundColor "Red" -BackgroundColor "White"

#Create RG
New-AzResourceGroup -n $rg -l $region

#########-----Create resources---------######

#Creating vnet

Write-Host "Adding subnet configuration" `
-ForegroundColor "Yellow" -BackgroundColor "Black"

$jumpBox = New-AzVirtualNetworkSubnetConfig `
  -Name 'jumpboxSubnet' `
  -AddressPrefix 10.0.0.0/24
 
$greenSubnet = New-AzVirtualNetworkSubnetConfig `
  -Name 'greenSubnet' `
  -AddressPrefix 10.0.1.0/24
   
$redSubnet = New-AzVirtualNetworkSubnetConfig `
  -Name 'redSubnet' `
  -AddressPrefix 10.0.2.0/24

$blueSubnet = New-AzVirtualNetworkSubnetConfig `
  -Name 'blueSubnet' `
  -AddressPrefix 10.0.3.0/24

Write-Host "Creating color-web-vnet" `
-ForegroundColor "Yellow" -BackgroundColor "Black"

$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $rg `
  -Location $region `
  -Name "color-web-vnet" `
  -AddressPrefix 10.0.0.0/16 `
  -Subnet $jumpBox, $greenSubnet, $redSubnet, $blueSubnet

#---------------------------------------------------#

#-------------------NSG--------------------------------#

$webRule = New-AzNetworkSecurityRuleConfig -Name web-rule -Description "Allow HTTP" -Access Allow `
    -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 80

$networkSecurityGroup = New-AzNetworkSecurityGroup -ResourceGroupName $rg `
-Location $region -Name "appGwNSG" -SecurityRules $rdpRule

Set-AzVirtualNetworkSubnetConfig -Name greenSubnet -VirtualNetwork $vnet -AddressPrefix "10.0.1.0/24" `
-NetworkSecurityGroup $networkSecurityGroup

Set-AzVirtualNetworkSubnetConfig -Name redSubnet -VirtualNetwork $vnet -AddressPrefix "10.0.2.0/24" `
-NetworkSecurityGroup $networkSecurityGroup

Set-AzVirtualNetworkSubnetConfig -Name blueSubnet -VirtualNetwork $vnet -AddressPrefix "10.0.3.0/24" `
-NetworkSecurityGroup $networkSecurityGroup

$vnet | Set-AzVirtualNetwork

#---------------------------------------------------#

#---------------------green Pool Servers------------------------------#

for($i=1; $i -le 2; $i++){

    $workloadNIC = New-AzNetworkInterface -Name "green-0$i-nic" -ResourceGroupName $rg `
    -Location $region -SubnetId $vnet.Subnets[1].Id

    Write-Host "----------------------------------------------------" `
    -ForegroundColor "Yellow" -BackgroundColor "Black"

    $credential = New-Object System.Management.Automation.PSCredential ($username, $password);

    Write-Host "Setting VM config" -ForegroundColor "Yellow" -BackgroundColor "Black"

    $VirtualMachine = New-AzVMConfig -VMName "green-0$i" -VMSize $VMSize 

    Write-Host "Setting OS Profile" -ForegroundColor "Yellow" -BackgroundColor "Black"

    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine `
    -Linux -ComputerName "green0$i" -Credential $credential

    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $workloadNIC.Id

    $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine `
    -PublisherName 'Canonical' `
    -Offer 'UbuntuServer' `
    -Skus '18.04-LTS' `
    -Version latest

    Write-Host "Creating VM green-0$i" -ForegroundColor "Yellow" -BackgroundColor "Black"
    New-AzVM -ResourceGroupName $rg -Location $region -VM $VirtualMachine

}

#---------------------------------------------------#

#---------------------red Pool Servers------------------------------#

for($i=1; $i -le 2; $i++){

    $workloadNIC = New-AzNetworkInterface -Name "red-0$i-nic" -ResourceGroupName $rg `
    -Location $region -SubnetId $vnet.Subnets[2].Id

    Write-Host "----------------------------------------------------" `
    -ForegroundColor "Yellow" -BackgroundColor "Black"

    $credential = New-Object System.Management.Automation.PSCredential ($username, $password);

    Write-Host "Setting VM config" -ForegroundColor "Yellow" -BackgroundColor "Black"

    $VirtualMachine = New-AzVMConfig -VMName "red-0$i" -VMSize $VMSize 

    Write-Host "Setting OS Profile" -ForegroundColor "Yellow" -BackgroundColor "Black"

    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine `
    -Linux -ComputerName "red0$i" -Credential $credential

    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $workloadNIC.Id

    $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine `
    -PublisherName 'Canonical' `
    -Offer 'UbuntuServer' `
    -Skus '18.04-LTS' `
    -Version latest

    Write-Host "Creating VM red-0$i" -ForegroundColor "Yellow" -BackgroundColor "Black"
    New-AzVM -ResourceGroupName $rg -Location $region -VM $VirtualMachine

}

#---------------------------------------------------#

#---------------------blue Pool Servers------------------------------#

for($i=1; $i -le 2; $i++){

    $workloadNIC = New-AzNetworkInterface -Name "blue-0$i-nic" -ResourceGroupName $rg `
    -Location $region -SubnetId $vnet.Subnets[3].Id

    Write-Host "----------------------------------------------------" `
    -ForegroundColor "Yellow" -BackgroundColor "Black"

    $credential = New-Object System.Management.Automation.PSCredential ($username, $password);

    Write-Host "Setting VM config" -ForegroundColor "Yellow" -BackgroundColor "Black"

    $VirtualMachine = New-AzVMConfig -VMName "blue-0$i" -VMSize $VMSize 

    Write-Host "Setting OS Profile" -ForegroundColor "Yellow" -BackgroundColor "Black"

    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine `
    -Linux -ComputerName "blue0$i" -Credential $credential

    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $workloadNIC.Id

    $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine `
    -PublisherName 'Canonical' `
    -Offer 'UbuntuServer' `
    -Skus '18.04-LTS' `
    -Version latest

    Write-Host "Creating VM blue-0$i" -ForegroundColor "Yellow" -BackgroundColor "Black"
    New-AzVM -ResourceGroupName $rg -Location $region -VM $VirtualMachine

}



#---------------------------------------------------#

#---------------------Jumpbox------------------------------#
 
Write-Host "Creating jumpbox VM" -ForegroundColor "Yellow" -BackgroundColor "Black"
$jumpVm = New-AzVM -Name jumpbox-vm `
-ResourceGroupName $rg `
-Location $region `
-Size 'Standard_B1s' `
-Image UbuntuLTS `
-VirtualNetworkName color-web-vnet `
-SubnetName jumpboxSubnet `
-PublicIpAddressName 'jumpbox-appgw-pip' `
-Credential $credential 

Write-Host "Running script on jumpbox..." -BackgroundColor Green -ForegroundColor White 

$Params = @{
    ResourceGroupName  = $rg
    VMName             = 'jumpbox-vm'
    Name               = 'CustomScript'
    Publisher          = 'Microsoft.Azure.Extensions'
    ExtensionType      = 'CustomScript'
    TypeHandlerVersion = '2.1'
    Settings          = @{fileUris = @('https://raw.githubusercontent.com/rithinskaria/kodekloud-azure/main/AppGateway/jumpbox.sh'); commandToExecute = './jumpbox.sh'}
}
Set-AzVMExtension @Params

#---------------------------------------------------#

#---------------------Output------------------------------#

Write-Host "Deployment Completed!!" -BackgroundColor Green -ForegroundColor White 

$fqdn = $jumpVm.FullyQualifiedDomainName
Write-Host "Jumpbox VM DNS name : $fqdn "
for ($i=1; $i -le 2; $i++){

    $vmIP= (Get-AzNetworkInterface -Name "green-0$i-nic").IpConfigurations.PrivateIPAddress
    Write-Host "Private IP (green-0$i) :$vmIP"

}
for ($i=1; $i -le 2; $i++){

    $vmIP= (Get-AzNetworkInterface -Name "red-0$i-nic").IpConfigurations.PrivateIPAddress
    Write-Host "Private IP (red-0$i) :$vmIP"

}
for ($i=1; $i -le 2; $i++){

    $vmIP= (Get-AzNetworkInterface -Name "blue-0$i-nic").IpConfigurations.PrivateIPAddress
    Write-Host "Private IP (blue-0$i) :$vmIP"

}
