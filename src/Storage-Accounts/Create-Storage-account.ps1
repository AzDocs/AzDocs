[CmdletBinding()]
param (
    [Alias("StorageResourceGroupName")]
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupName,
    [Parameter(Mandatory)][System.Object[]] $ResourceTags,
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $StorageAccountPrivateEndpointVnetName,
    [Alias("VnetResourceGroupName")]
    [Parameter(Mandatory)][string] $StorageAccountPrivateEndpointVnetResourceGroupName,
    [Parameter(Mandatory)][string] $StorageAccountPrivateEndpointSubnetName,
    [Parameter(Mandatory)][string] $ApplicationVnetResourceGroupName,
    [Parameter(Mandatory)][string] $ApplicationVnetName,
    [Parameter(Mandatory)][string] $ApplicationSubnetName,
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Parameter(Mandatory)][string] $PrivateEndpointGroupId,
    [Parameter(Mandatory)][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $StorageAccountPrivateDnsZoneName = "privatelink.blob.core.windows.net"
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\PrivateEndpoint-Helper-Functions.ps1"
#endregion ===END IMPORTS===

Write-Header

$vnetId = (Invoke-Executable az network vnet show --resource-group $StorageAccountPrivateEndpointVnetResourceGroupName --name $StorageAccountPrivateEndpointVnetName | ConvertFrom-Json).id
$storageAccountPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $StorageAccountPrivateEndpointVnetResourceGroupName --name $StorageAccountPrivateEndpointSubnetName --vnet-name $StorageAccountPrivateEndpointVnetName | ConvertFrom-Json).id
$applicationSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ApplicationVnetResourceGroupName --name $ApplicationSubnetName --vnet-name $ApplicationVnetName | ConvertFrom-Json).id
$storageAccountPrivateEndpointName = "$($StorageAccountName)-pvtstg-$($PrivateEndpointGroupId)"

# Create StorageAccount with the appropriate tags
Invoke-Executable az storage account create --name $StorageAccountName --resource-group $StorageAccountResourceGroupName --kind StorageV2 --sku Standard_LRS --allow-blob-public-access false --tags ${ResourceTags}

# Fetch the StorageAccount ID to use while creating the Private Endpoint in the next step
$storageAccountId = (Invoke-Executable az storage account show --name $StorageAccountName --resource-group $StorageAccountResourceGroupName | ConvertFrom-Json).id

# Add private endpoint & Setup Private DNS
Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $storageAccountPrivateEndpointSubnetId -PrivateEndpointName $storageAccountPrivateEndpointName -PrivateEndpointResourceGroupName $StorageAccountResourceGroupName -TargetResourceId $storageAccountId -PrivateEndpointGroupId $PrivateEndpointGroupId -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $StorageAccountPrivateDnsZoneName -PrivateDnsLinkName "$($StorageAccountPrivateEndpointVnetName)-storage"

# Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
Set-SubnetServiceEndpoint -SubnetResourceId $applicationSubnetId -ServiceEndpointServiceIdentifier "Microsoft.Storage"

# Whitelist our App's subnet in the storage account so we can connect
Invoke-Executable az storage account network-rule add --resource-group $StorageAccountResourceGroupName --account-name $StorageAccountName --subnet $applicationSubnetId

# Make sure the default action is "deny" which causes public traffic to be dropped (like is defined in the KSP)
Invoke-Executable az storage account update --resource-group $StorageAccountResourceGroupName --name $StorageAccountName --default-action Deny

Write-Footer