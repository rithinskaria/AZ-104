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
$rg = "rg-vnet-peering-$(Get-Date -Format 'yyyyMMdd')"
New-AzResourceGroup -n $rg -l $region

Write-Host "Creating EUS VM"  -ForegroundColor Green 
New-AzVm `
    -ResourceGroupName $rg `
    -Name 'vm-eus' `
    -Location 'East US' `
    -image Ubuntu2204 `
    -size $VMSize `
    -PublicIpAddressName 'eus-vm-pip' `
    -OpenPorts 22 `
    -Credential $credential `
    -VirtualNetworkName 'vnet-eus' `
    -AddressPrefix '192.168.0.0/24' `
    -SubnetName 'default' `
    -SubnetAddressPrefix '192.168.0.0/24'

Write-Host "Creating WUS VM"  -ForegroundColor Green 
New-AzVm `
    -ResourceGroupName $rg `
    -Name 'vm-wus' `
    -Location 'West US' `
    -image Ubuntu2204 `
    -size $VMSize `
    -PublicIpAddressName 'wus-vm-pip' `
    -OpenPorts 22 `
    -Credential $credential `
    -VirtualNetworkName 'vnet-wus' `
    -AddressPrefix '192.168.1.0/24' `
    -SubnetName 'default' `
    -SubnetAddressPrefix '192.168.1.0/24'