[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $vnetResourceGroupName,

    [Parameter(Mandatory)]
    [string] $vnetName,

    [Parameter(Mandatory)]
    [string] $applicationPrivateEndpointSubnetName,

    [Parameter(Mandatory)]
    [string] $appServicePlanName,

    [Parameter(Mandatory)]
    [string] $appServicePlanResourceGroupName,

    [Parameter(Mandatory)]
    [string] $appServicePlanSkuName,

    [Parameter(Mandatory)]
    [System.Object[]] $resourceTags,

    [Parameter(Mandatory)]
    [string] $appServiceResourceGroupName,

    [Parameter(Mandatory)]
    [string] $appServiceName,

    [Parameter(Mandatory)]
    [string] $appServiceRunTime,

    [Parameter(Mandatory)]
    [string] $appServiceDiagnosticsName,

    [Parameter(Mandatory)]
    [string] $logAnalyticsWorkspaceName,

    [Parameter(Mandatory)]
    [string] $DNSZoneResourceGroupName,

    [Parameter()]
    [string] $privateDnsZoneName = "privatelink.azurewebsites.net"
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

$vnetId = (Invoke-Executable az network vnet show -g $vnetResourceGroupName -n $vnetName | ConvertFrom-Json).id
$applicationPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show -g $vnetResourceGroupName -n $applicationPrivateEndpointSubnetName --vnet-name $vnetName | ConvertFrom-Json).id
$appServicePrivateEndpointName = "$($appServiceName)-pvtapp"

# Create AppService Plan
$appServicePlanId = (Invoke-Executable az appservice plan create --is-linux --resource-group $appServicePlanResourceGroupName  --name $appServicePlanName --sku $appServicePlanSkuName --tags ${resourceTags} | ConvertFrom-Json).id

# Create AppService
Invoke-Executable az webapp create --runtime $appServiceRunTime --name $appServiceName --plan $appServicePlanId --resource-group $appServiceResourceGroupName --tags ${resourceTags}

# Fetch the ID from the AppService
$webAppId = (Invoke-Executable az webapp show --name $appServiceName --resource-group $appServiceResourceGroupName | ConvertFrom-Json).id

# Disable HTTPS
Invoke-Executable az webapp update --ids $webAppId --https-only true

# Disable FTPS
Invoke-Executable az webapp config set --ids $webAppId --ftps-state Disabled

# Set logging to FileSystem
Invoke-Executable az webapp log config --ids $webAppId --detailed-error-messages true --docker-container-logging filesystem --failed-request-tracing true --level warning --web-server-logging filesystem

#  Create diagnostics settings
Invoke-Executable az monitor diagnostic-settings create --resource $webAppId --name $appServiceDiagnosticsName --workspace $logAnalyticsWorkspaceName --logs "[{ 'category': 'AppServiceHTTPLogs', 'enabled': true }, { 'category': 'AppServiceConsoleLogs', 'enabled': true }, { 'category': 'AppServiceAppLogs', 'enabled': true }, { 'category': 'AppServiceFileAuditLogs', 'enabled': true }, { 'category': 'AppServiceIPSecAuditLogs', 'enabled': true }, { 'category': 'AppServicePlatformLogs', 'enabled': true }, { 'category': 'AppServiceAuditLogs', 'enabled': true } ]".Replace("'", '\"') --metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')

# Create & Assign WebApp identity to AppService
Invoke-Executable az webapp identity assign --ids $webAppId

# Disable private-endpoint-network-policies
Invoke-Executable az network vnet subnet update --ids $applicationPrivateEndpointSubnetId --disable-private-endpoint-network-policies true

# Create private endpoint for AppService
Invoke-Executable az network private-endpoint create --name $appServicePrivateEndpointName --resource-group $appServiceResourceGroupName --subnet $applicationPrivateEndpointSubnetId --connection-name "$($appServiceName)-connection" --private-connection-resource-id $webAppId --group-id sites

# Add Private DNS zone & set it up
if ([String]::IsNullOrWhiteSpace($(az network private-dns zone show -g $DNSZoneResourceGroupName -n $privateDnsZoneName))) {
    Invoke-Executable az network private-dns zone create --resource-group $DNSZoneResourceGroupName --name $privateDnsZoneName
}

$dnsZoneId = (Invoke-Executable az network private-dns zone show --resource-group $DNSZoneResourceGroupName --name $privateDnsZoneName | ConvertFrom-Json).id

if ([String]::IsNullOrWhiteSpace($(az network private-dns link vnet show --name "$($vnetName)-appservice" --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName))) {
    Invoke-Executable az network private-dns link vnet create --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName --name "$($vnetName)-appservice" --virtual-network $vnetId --registration-enabled false
}

# Create DNS Zone Group
Invoke-Executable az network private-endpoint dns-zone-group create --resource-group $appServiceResourceGroupName --endpoint-name $appServicePrivateEndpointName --name "$($appServiceName)-zonegroup" --private-dns-zone $dnsZoneId --zone-name appservice