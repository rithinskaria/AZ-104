#Preferences
$WarningPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Break'

#Variables
$rg = "rg-se-workload-$(Get-Date -Format 'yyyyMMdd')"
$region = "eastus"
$username = "kodekloud" #username for the VM
$plainPassword = "VMP@55w0rd" #your VM password
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $password);
#Create VM
Write-Host "Creating VM" -ForegroundColor "Yellow" -BackgroundColor "Black"
$spAvm = New-AzVM -Name "vm-01" `
    -ResourceGroupName $rg `
    -Location eastus `
    -Size 'Standard_B1s' `
    -Image "Ubuntu2204" `
    -VirtualNetworkName "vnet-01" `
    -SubnetName 'default' `
    -Credential $credential `
    -PublicIpAddressName "vm-01-pip" `
    -PublicIpSku Standard
$fqdn = $spAvm.FullyQualifiedDomainName
Write-Host "workload-a-vm-$i FQDN : $fqdn " -ForegroundColor Green 

#Create storage
Write-Host "Creating storage" -ForegroundColor "Yellow" -BackgroundColor "Black"
New-AzStorageAccount `
    -ResourceGroupName $rg `
    -Name "st$(Get-Random)$(Get-Date -Format 'yyyyMMdd')" `
    -Location $region `
    -Kind StorageV2 `
    -AllowBlobPublicAccess $true `
    -SkuName Standard_LRS