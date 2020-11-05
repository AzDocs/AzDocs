[CmdletBinding()]
param (
    [Parameter()]
    [String] $vnetResourceGroupName,

    [Parameter()]
    [String] $vnetName,

    [Parameter()]
    [String] $appConfigPrivateEndpointSubnetName,

    [Parameter()]
    [String] $applicationSubnetName,

    [Parameter()]
    [String] $appConfigName,

    [Parameter()]
    [String] $appConfigLocation = "westeurope",

    [Parameter()]
    [String] $appConfigResourceGroupName,

    [Parameter()]
    [String] $appConfigDiagnosticsName,

    [Parameter()]
    [String] $logAnalyticsWorkspaceName,

    [Parameter()]
    [String] $DNSZoneResourceGroupName,

    [Parameter()]
    [String] $privateDnsZoneName = "privatelink.azconfig.io"
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#. "$PSScriptRoot\..\common\Set-SubnetServiceEndpoint.ps1"
#endregion ===END IMPORTS===

$vnetId = (Invoke-Executable az network vnet show -g $vnetResourceGroupName -n $vnetName | ConvertFrom-Json).id
$appConfigPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show -g $vnetResourceGroupName -n $appConfigPrivateEndpointSubnetName --vnet-name $vnetName | ConvertFrom-Json).id
$applicationSubnetId = (Invoke-Executable az network vnet subnet show -g $vnetResourceGroupName -n $applicationSubnetName --vnet-name $vnetName | ConvertFrom-Json).id
$appConfigPrivateEndpointName = "$($appConfigName)-pvtappcfg"

# Create AppConfig with the appropriate tags
Invoke-Executable az appconfig create --resource-group $appConfigResourceGroupName --name $appConfigName --location $appConfigLocation --sku Standard

# Fetch the App Config ID to use while creating the Diagnostics settings in the next step
$appConfigId = (Invoke-Executable az appconfig show --name $appConfigName --resource-group $appConfigResourceGroupName | ConvertFrom-Json).id

# Create diagnostics settings for the App Config resource
Invoke-Executable az monitor diagnostic-settings create --resource $appConfigId --name $appConfigDiagnosticsName --workspace $logAnalyticsWorkspaceName --metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')

# Disable Private Endpoint policies, else we cannot add the private endpoint to this subnet
Invoke-Executable az network vnet subnet update --ids $appConfigPrivateEndpointSubnetId --disable-private-endpoint-network-policies true

# Create the Private Endpoint based on the resource id fetched in the previous step.
Invoke-Executable az network private-endpoint create --name $appConfigPrivateEndpointName --resource-group $appConfigResourceGroupName --subnet $appConfigPrivateEndpointSubnetId --private-connection-resource-id $appConfigId --group-id configurationStores --connection-name "$($appConfigName)-connection"

# Create Private DNS Zone for this service. This will enable us to get dynamic IP's within the subnet which will keep traffic within the subnet
if ([String]::IsNullOrWhiteSpace($(az network private-dns zone show -g $DNSZoneResourceGroupName -n $privateDnsZoneName))) {
    Invoke-Executable az network private-dns zone create --resource-group $DNSZoneResourceGroupName --name $privateDnsZoneName
}

$dnsZoneId = (Invoke-Executable az network private-dns zone show --name $privateDnsZoneName --resource-group $DNSZoneResourceGroupName | ConvertFrom-Json).id

if ([String]::IsNullOrWhiteSpace($(az network private-dns link vnet show --name "$($vnetName)-appcfg" --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName))) {
    Invoke-Executable az network private-dns link vnet create --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName --name "$($vnetName)-appcfg" --virtual-network $vnetId --registration-enabled false
}

Invoke-Executable az network private-endpoint dns-zone-group create --resource-group $appConfigResourceGroupName --endpoint-name $appConfigPrivateEndpointName --name "$($appConfigName)-zonegroup" --private-dns-zone $dnsZoneId --zone-name appconfiguration

# Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
# TODO this is not possible ATM
# Set-SubnetServiceEndpoint -SubnetResourceId $applicationSubnetId -ServiceName  "Microsoft.AppConfiguration"

# Assign Identity to App Configuration store
Invoke-Executable az appconfig identity assign --resource-group $appConfigResourceGroupName --name $appConfigName

# Disable public access on the App Configuration store
Invoke-Executable az appconfig update --resource-group $appConfigResourceGroupName --name $appConfigName --enable-public-network false