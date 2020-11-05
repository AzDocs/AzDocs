[CmdletBinding()]
param (
    [Parameter()]
    [String] $storageResourceGroupName,

    [Parameter()]
    [System.Object[]] $resourceTags,

    [Parameter()]
    [String] $vnetName,

    [Parameter()]
    [String] $vnetResourceGroupName,

    [Parameter()]
    [String] $storageAccountPrivateEndpointSubnetName,

    [Parameter()]
    [String] $applicationSubnetName,

    [Parameter()]
    [String] $storageAccountName,

    [Parameter()]
    [String] $privateEndpointGroupId,

    [Parameter()]
    [String] $DNSZoneResourceGroupName,

    [Parameter()]
    [String] $privateDnsZoneName = "privatelink.blob.core.windows.net"
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\Set-SubnetServiceEndpoint.ps1"
#endregion ===END IMPORTS===

$vnetId = (Invoke-Executable az network vnet show -g $vnetResourceGroupName -n $vnetName | ConvertFrom-Json).id
$storageAccountPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show -g $vnetResourceGroupName -n $storageAccountPrivateEndpointSubnetName --vnet-name $vnetName | ConvertFrom-Json).id
$applicationSubnetId = (Invoke-Executable az network vnet subnet show -g $vnetResourceGroupName -n $applicationSubnetName --vnet-name $vnetName | ConvertFrom-Json).id
$storageAccountPrivateEndpointName = "$($storageAccountName)-pvtstg-$($privateEndpointGroupId)"

# Create StorageAccount with the appropriate tags
Invoke-Executable az storage account create --name $storageAccountName --resource-group $storageResourceGroupName --kind StorageV2 --sku Standard_LRS --allow-blob-public-access false --tags ${resourceTags}

# Disable Private Endpoint policies, else we cannot add the private endpoint to this subnet
Invoke-Executable az network vnet subnet update --ids $storageAccountPrivateEndpointSubnetId --disable-private-endpoint-network-policies true

# Fetch the StorageAccount ID to use while creating the Private Endpoint in the next step
$storageAccountId = (Invoke-Executable az storage account show --name $storageAccountName --resource-group $storageResourceGroupName | ConvertFrom-Json).id

# Create the Private Endpoint based on the resource id fetched in the previous step.
Invoke-Executable az network private-endpoint create --name $storageAccountPrivateEndpointName --resource-group $storageResourceGroupName --subnet $storageAccountPrivateEndpointSubnetId --private-connection-resource-id $storageAccountId --group-id $privateEndpointGroupId --connection-name "$($storageAccountName)-connection"

# Create Private DNS Zone for this service. This will enable us to get dynamic IP's within the subnet which will keep traffic within the subnet
if ([String]::IsNullOrWhiteSpace($(az network private-dns zone show -g $DNSZoneResourceGroupName -n $privateDnsZoneName))) {
    Invoke-Executable az network private-dns zone create --resource-group $DNSZoneResourceGroupName --name $privateDnsZoneName
}

$dnsZoneId = (Invoke-Executable az network private-dns zone show --name $privateDnsZoneName --resource-group $DNSZoneResourceGroupName | ConvertFrom-Json).id

if ([String]::IsNullOrWhiteSpace($(az network private-dns link vnet show --name "$($vnetName)-storage" --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName))) {
    Invoke-Executable az network private-dns link vnet create --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName --name "$($vnetName)-storage" --virtual-network $vnetId --registration-enabled false
}

Invoke-Executable az network private-endpoint dns-zone-group create --resource-group $storageResourceGroupName --endpoint-name $storageAccountPrivateEndpointName --name "$($storageAccountName)-zonegroup" --private-dns-zone $dnsZoneId --zone-name storage

# Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
Set-SubnetServiceEndpoint -SubnetResourceId $applicationSubnetId -ServiceName "Microsoft.Storage"

# Whitelist our App's subnet in the storage account so we can connect
Invoke-Executable az storage account network-rule add --resource-group $storageResourceGroupName --account-name $storageAccountName --subnet $applicationSubnetId

# Make sure the default action is "deny" which causes public traffic to be dropped (like is defined in the KSP)
Invoke-Executable az storage account update --resource-group $storageResourceGroupName --name $storageAccountName --default-action Deny