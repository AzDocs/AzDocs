[CmdletBinding()]
param (
    [Parameter()]
    [string] $containerRegistryName,

    [Parameter()]
    [string] $containerRegistryResourceGroupName,

    [Parameter()]
    [String] $vnetName,

    [Parameter()]
    [String] $vnetResourceGroupName,

    [Parameter()]
    [String] $containerRegistryPrivateEndpointSubnetName,

    [Parameter()]
    [String] $applicationSubnetName,

    [Parameter()]
    [String] $privateEndpointGroupId,

    [Parameter()]
    [String] $DNSZoneResourceGroupName,

    [Parameter()]
    [String] $privateDnsZoneName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\Set-SubnetServiceEndpoint.ps1"
#endregion ===END IMPORTS===

Write-Header

$vnetId = (Invoke-Executable az network vnet show -g $vnetResourceGroupName -n $vnetName | ConvertFrom-Json).id
$containerRegistryPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show -g $vnetResourceGroupName -n $containerRegistryPrivateEndpointSubnetName --vnet-name $vnetName | ConvertFrom-Json).id
$applicationSubnetId = (Invoke-Executable az network vnet subnet show -g $vnetResourceGroupName -n $applicationSubnetName --vnet-name $vnetName | ConvertFrom-Json).id
$containerRegistryPrivateEndpointName = "$($containerRegistryName)-pvtacr-$($privateEndpointGroupId)"

Invoke-Executable az acr create --resource-group $containerRegistryResourceGroupName --name $containerRegistryName --sku Premium

# Disable Private Endpoint policies, else we cannot add the private endpoint to this subnet
Invoke-Executable az network vnet subnet update --ids $containerRegistryPrivateEndpointSubnetId --disable-private-endpoint-network-policies true

# Fetch the ContainerRegistry ID to use while creating the Private Endpoint in the next step
$containerRegistryId = (Invoke-Executable az acr show --name $containerRegistryName --resource-group $containerRegistryResourceGroupName | ConvertFrom-Json).id

# Create the Private Endpoint based on the resource id fetched in the previous step.
Invoke-Executable az network private-endpoint create --name $containerRegistryPrivateEndpointName --resource-group $containerRegistryResourceGroupName --subnet $containerRegistryPrivateEndpointSubnetId --private-connection-resource-id $containerRegistryId --group-id $privateEndpointGroupId --connection-name "$($containerRegistryName)-connection"

# Create Private DNS Zone for this service. This will enable us to get dynamic IP's within the subnet which will keep traffic within the subnet
if ([String]::IsNullOrWhiteSpace($(az network private-dns zone show -g $DNSZoneResourceGroupName -n $privateDnsZoneName))) {
    Invoke-Executable az network private-dns zone create --resource-group $DNSZoneResourceGroupName --name $privateDnsZoneName
}

$dnsZoneId = (Invoke-Executable az network private-dns zone show --name $privateDnsZoneName --resource-group $DNSZoneResourceGroupName | ConvertFrom-Json).id

if ([String]::IsNullOrWhiteSpace($(az network private-dns link vnet show --name "$($vnetName)-acr" --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName))) {
    Invoke-Executable az network private-dns link vnet create --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName --name "$($vnetName)-acr" --virtual-network $vnetId --registration-enabled false
}

Invoke-Executable az network private-endpoint dns-zone-group create --resource-group $containerRegistryResourceGroupName --endpoint-name $containerRegistryPrivateEndpointName --name "$($containerRegistryName)-zonegroup" --private-dns-zone $dnsZoneId --zone-name $privateDnsZoneName

# Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
Set-SubnetServiceEndpoint  -SubnetResourceId $applicationSubnetId -ServiceName 'Microsoft.ContainerRegistry'

# Whitelist our App's subnet in the Azure Container Registry so we can connect
Invoke-Executable az acr network-rule add --resource-group $containerRegistryResourceGroupName --name $containerRegistryName --subnet $applicationSubnetId

# Make sure the default action is "deny" which causes public traffic to be dropped (like is defined in the KSP)
Invoke-Executable az acr update --resource-group $containerRegistryResourceGroupName --name $containerRegistryName --default-action Deny

Write-Footer