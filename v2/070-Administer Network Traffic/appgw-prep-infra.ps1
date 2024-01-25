#Pref
$WarningPreference = 'SilentlyContinue'

#Variables
$rg = "rg-appgw-$(Get-Date -Format 'yyyyMMdd')"
$region = "eastus"
$username = "kodekloud" #username for the VM
$plainPassword = "VMP@55w0rd" #your VM password

#Creating VM credential; use your own password and username by changing the variables if needed
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $password);
#Pool server function
function  Deploy-PoolServers {
    [CmdletBinding()]
    param (
        # color-code
        [Parameter(Mandatory = $true)]
        [String]
        $Color,
       
        # Subnet
        [Parameter(Mandatory = $true)]
        [String]
        $SubnetPointer
    )
    #Variables
    $rg = "rg-appgw-$(Get-Date -Format 'yyyyMMdd')"
    $region = "eastus"
    $username = "kodekloud" #username for the VM
    $plainPassword = "VMP@55w0rd" #your VM password

    #Creating VM credential; use your own password and username by changing the variables if needed
    $password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
    Write-Host "Creating $Color color vms" `
    -ForegroundColor "Yellow" -BackgroundColor "Black"
    for ($i = 1; $i -le 2; $i++) {

        $workloadNIC = New-AzNetworkInterface -Name "$Color-0$i-nic" -ResourceGroupName $rg `
            -Location $region -SubnetId $vnet.Subnets[$SubnetPointer].Id
    
        Write-Host "----------------------------------------------------" `
            -ForegroundColor "Yellow" -BackgroundColor "Black"
    
        $credential = New-Object System.Management.Automation.PSCredential ($username, $password);
    
        Write-Host "Setting VM config" -ForegroundColor "Yellow" -BackgroundColor "Black"
    
        $VirtualMachine = New-AzVMConfig -VMName "$Color-0$i" -VMSize "Standard_B1s"
    
        Write-Host "Setting OS Profile" -ForegroundColor "Yellow" -BackgroundColor "Black"
    
        $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine `
            -Linux -ComputerName "$($Color)0$($i)" -Credential $credential
    
        $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $workloadNIC.Id
    
        $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine `
            -PublisherName 'Canonical' `
            -Offer '0001-com-ubuntu-server-jammy' `
            -Skus '22_04-lts-gen2' `
            -Version latest 
    
        Write-Host "Creating VM $Color-0$i" -ForegroundColor "Yellow" -BackgroundColor "Black"
        New-AzVM -ResourceGroupName $rg -Location $region -VM $VirtualMachine
    
    }

}

function Find-PoolServerIP {
    [CmdletBinding()]
    param (
        # Color
        [Parameter(Mandatory = $true)]
        [String]
        $Color
        
    )
    for ($i = 1; $i -le 2; $i++) {

        $vmIP = (Get-AzNetworkInterface -Name "$($Color)-0$i-nic").IpConfigurations.PrivateIPAddress
        Write-Host "Private IP ($($Color)-0$i) :$vmIP"
    
    }
}

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
    -Location $region -Name "appGwNSG" -SecurityRules $webRule

Set-AzVirtualNetworkSubnetConfig -Name greenSubnet -VirtualNetwork $vnet -AddressPrefix "10.0.1.0/24" `
    -NetworkSecurityGroup $networkSecurityGroup

Set-AzVirtualNetworkSubnetConfig -Name redSubnet -VirtualNetwork $vnet -AddressPrefix "10.0.2.0/24" `
    -NetworkSecurityGroup $networkSecurityGroup

Set-AzVirtualNetworkSubnetConfig -Name blueSubnet -VirtualNetwork $vnet -AddressPrefix "10.0.3.0/24" `
    -NetworkSecurityGroup $networkSecurityGroup

$vnet | Set-AzVirtualNetwork

#------------Creating pool servers---------------------------------------#

Deploy-PoolServers -Color 'green' -SubnetPointer 1
Deploy-PoolServers -Color 'red' -SubnetPointer 2
Deploy-PoolServers -Color 'blue' -SubnetPointer 3

#---------------------------------------------------#

#---------------------Jumpbox------------------------------#

Write-Host "Creating jumpbox VM" -ForegroundColor "Yellow" -BackgroundColor "Black"
$jumpVm = New-AzVM -Name jumpbox-vm `
    -ResourceGroupName $rg `
    -Location $region `
    -Size 'Standard_B1s' `
    -Image Ubuntu2204 `
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
    Settings           = @{fileUris = @('https://raw.githubusercontent.com/rithinskaria/kodekloud-az500/main/000-Code%20files/AppGateway/jumpbox.sh'); commandToExecute = './jumpbox.sh' }
}
Set-AzVMExtension @Params

#---------------------------------------------------#

#---------------------Output------------------------------#

Write-Host "Deployment Completed!!" -BackgroundColor Green -ForegroundColor White 

$fqdn = $jumpVm.FullyQualifiedDomainName
Write-Host "Jumpbox VM DNS name : $fqdn "
Find-PoolServerIP -Color green
Find-PoolServerIP -Color blue
Find-PoolServerIP -Color red
Write-Host "Use username: $username and password: $plainPassword to login to any VMs" `
    -ForegroundColor "Green" -BackgroundColor "White"