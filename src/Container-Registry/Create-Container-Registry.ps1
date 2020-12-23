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
#endregion ===END IMPORTS===

Write-Header

$vnetId = (Invoke-Executableaz network vnet show -g $vnetResourceGroupName -n $vnetName | ConvertFrom-Json).id
$containerRegistryPrivateEndpointSubnetId = (Invoke-Executableaz network vnet subnet show -g $vnetResourceGroupName -n $containerRegistryPrivateEndpointSubnetName --vnet-name $vnetName | ConvertFrom-Json).id
$applicationSubnetId = (Invoke-Executableaz network vnet subnet show -g $vnetResourceGroupName -n $applicationSubnetName --vnet-name $vnetName | ConvertFrom-Json).id
$containerRegistryPrivateEndpointName = "$($containerRegistryName)-pvtacr-$($privateEndpointGroupId)"

Invoke-Executableaz acr create --resource-group $containerRegistryResourceGroupName --name $containerRegistryName --sku Premium

# Disable Private Endpoint policies, else we cannot add the private endpoint to this subnet
Invoke-Executableaz network vnet subnet update --ids $containerRegistryPrivateEndpointSubnetId --disable-private-endpoint-network-policies true

# Fetch the ContainerRegistry ID to use while creating the Private Endpoint in the next step
$containerRegistryId = (Invoke-Executableaz acr show --name $containerRegistryName --resource-group $containerRegistryResourceGroupName | ConvertFrom-Json).id

# Create the Private Endpoint based on the resource id fetched in the previous step.
Invoke-Executableaz network private-endpoint create --name $containerRegistryPrivateEndpointName --resource-group $containerRegistryResourceGroupName --subnet $containerRegistryPrivateEndpointSubnetId --private-connection-resource-id $containerRegistryId --group-id $privateEndpointGroupId --connection-name "$($containerRegistryName)-connection"

# Create Private DNS Zone for this service. This will enable us to get dynamic IP's within the subnet which will keep traffic within the subnet
if([String]::IsNullOrWhiteSpace($(az network private-dns zone show -g $DNSZoneResourceGroupName -n $privateDnsZoneName)))
{
    Invoke-Executable az network private-dns zone create --resource-group $DNSZoneResourceGroupName --name $privateDnsZoneName
}

$dnsZoneId = (Invoke-Executable az network private-dns zone show --name $privateDnsZoneName --resource-group $DNSZoneResourceGroupName | ConvertFrom-Json).id

if([String]::IsNullOrWhiteSpace($(az network private-dns link vnet show --name "$($vnetName)-acr" --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName)))
{
    Invoke-Executable az network private-dns link vnet create --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName --name "$($vnetName)-acr" --virtual-network $vnetId --registration-enabled false
}

Invoke-Executable az network private-endpoint dns-zone-group create --resource-group $containerRegistryResourceGroupName --endpoint-name $containerRegistryPrivateEndpointName --name "$($containerRegistryName)-zonegroup" --private-dns-zone $dnsZoneId --zone-name $privateDnsZoneName

# Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
$endpoints = Invoke-Executable az network vnet subnet show --ids $applicationSubnetId --query=serviceEndpoints[].service --output=json | ConvertFrom-Json
if(![String]::IsNullOrWhiteSpace($endpoints) -and $endpoints -isnot [Object[]])
{
    $endpoints = @($endpoints)
}
Write-Host "Current service endpoints: $endpoints"
if(!($endpoints -contains 'Microsoft.ContainerRegistry'))
{
    Write-Host "Microsoft.ContainerRegistry Service Endpoint isnt defined yet. Adding it to the list."
    $endpoints += "Microsoft.ContainerRegistry"
}
Invoke-Executable az network vnet subnet update --ids $applicationSubnetId --service-endpoints $endpoints

# Whitelist our App's subnet in the Azure Container Registry so we can connect
Invoke-Executable az acr network-rule add --resource-group $containerRegistryResourceGroupName --name $containerRegistryName --subnet $applicationSubnetId

# Make sure the default action is "deny" which causes public traffic to be dropped (like is defined in the KSP)
Invoke-Executable az acr update --resource-group $containerRegistryResourceGroupName --name $containerRegistryName --default-action Deny

Write-Footer