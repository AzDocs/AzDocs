[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $vnetResourceGroupName,

    [Parameter(Mandatory)]
    [string] $vnetName,

    [Parameter(Mandatory)]
    [string] $functionAppPrivateEndpointSubnetName,

    [Parameter(Mandatory)]
    [string] $appServicePlanName,

    [Parameter(Mandatory)]
    [string] $appServicePlanResourceGroupName,

    [Parameter(Mandatory)]
    [string] $appServicePlanSkuName,

    [Parameter(Mandatory)]
    [System.Object[]] $resourceTags,

    [Parameter(Mandatory)]
    [string] $functionAppResourceGroupName,

    [Parameter(Mandatory)]
    [string] $functionAppName,

    [Parameter(Mandatory)]
    [string] $functionAppStorageAccountName,

    [Parameter(Mandatory)]
    [string] $functionAppDiagnosticsName,

    [Parameter(Mandatory)]
    [string] $logAnalyticsWorkspaceName,

    [Parameter(Mandatory)]
    [string] $DNSZoneResourceGroupName,

    [Parameter()]
    [string] $privateDnsZoneName = "privatelink.azurewebsites.net",

    [Parameter(Mandatory)]
    [string] $alwaysOn,

    [Parameter(Mandatory)]
    [string] $FUNCTIONS_EXTENSION_VERSION,

    [Parameter(Mandatory)]
    [string] $ASPNETCORE_ENVIRONMENT
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

$vnetId = (Invoke-Executable az network vnet show -g $vnetResourceGroupName -n $vnetName | ConvertFrom-Json).id
$functionAppPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show -g $vnetResourceGroupName -n $functionAppPrivateEndpointSubnetName --vnet-name $vnetName | ConvertFrom-Json).id
$functionAppPrivateEndpointName = "$($functionAppName)-pvtfunc"

# Create AppService Plan
$appServicePlanId = (Invoke-Executable az appservice plan create --resource-group $appServicePlanResourceGroupName  --name $appServicePlanName --sku $appServicePlanSkuName --tags ${resourceTags} | ConvertFrom-Json).id

# Create FunctionApp
Invoke-Executable az functionapp create --name $functionAppName --plan $appServicePlanId --resource-group $functionAppResourceGroupName --storage-account $functionAppStorageAccountName --runtime dotnet --functions-version 3 --disable-app-insights --tags ${resourceTags}

# Fetch the ID from the FunctionApp
$functionAppId = (Invoke-Executable az functionapp show --name $functionAppName --resource-group $functionAppResourceGroupName | ConvertFrom-Json).id

# Disable HTTPS
Invoke-Executable az functionapp update --ids $functionAppId --set httpsOnly=true

# Disable FTPS
Invoke-Executable az functionapp config set --ids $functionAppId --ftps-state Disabled

# Set Always On
Invoke-Executable az functionapp config set --always-on $alwaysOn --ids $functionAppId

# Set some basic configs (including vnet route all)
Invoke-Executable az functionapp config appsettings set --ids $functionAppId --settings "ASPNETCORE_ENVIRONMENT=$($ASPNETCORE_ENVIRONMENT)" "FUNCTIONS_EXTENSION_VERSION=$($FUNCTIONS_EXTENSION_VERSION)" "WEBSITE_VNET_ROUTE_ALL=1"

#  Create diagnostics settings
Invoke-Executable az monitor diagnostic-settings create --resource $functionAppId --name $functionAppDiagnosticsName --workspace $logAnalyticsWorkspaceName --logs "[{ 'category': 'FunctionAppLogs', 'enabled': true } ]".Replace("'", '\"') --metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')

# Create & Assign WebApp identity to AppService
Invoke-Executable az functionapp identity assign --ids $functionAppId

# Disable private-endpoint-network-policies
Invoke-Executable az network vnet subnet update --ids $functionAppPrivateEndpointSubnetId --disable-private-endpoint-network-policies true

# Create private endpoint for AppService
Invoke-Executable az network private-endpoint create --name $functionAppPrivateEndpointName --resource-group $functionAppResourceGroupName --subnet $functionAppPrivateEndpointSubnetId --connection-name "$($functionAppName)-connection" --private-connection-resource-id $functionAppId --group-id sites

# Add Private DNS zone & set it up (this is the same zone as AppServices)
if ([String]::IsNullOrWhiteSpace($(az network private-dns zone show -g $DNSZoneResourceGroupName -n $privateDnsZoneName))) {
    Invoke-Executable az network private-dns zone create --resource-group $DNSZoneResourceGroupName --name $privateDnsZoneName
}

$dnsZoneId = (Invoke-Executable az network private-dns zone show --resource-group $DNSZoneResourceGroupName --name $privateDnsZoneName | ConvertFrom-Json).id

if ([String]::IsNullOrWhiteSpace($(az network private-dns link vnet show --name "$($vnetName)-appservice" --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName))) {
    Invoke-Executable az network private-dns link vnet create --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName --name "$($vnetName)-appservice" --virtual-network $vnetId --registration-enabled false
}

# Create DNS Zone Group
Invoke-Executable az network private-endpoint dns-zone-group create --resource-group $functionAppResourceGroupName --endpoint-name $functionAppPrivateEndpointName --name "$($functionAppName)-zonegroup" --private-dns-zone $dnsZoneId --zone-name appservice