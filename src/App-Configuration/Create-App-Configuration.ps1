[CmdletBinding()]
param (
    [Alias("VnetResourceGroupName")]
    [Parameter(Mandatory)][string] $AppConfigPrivateEndpointVnetResourceGroupName,
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $AppConfigPrivateEndpointVnetName,
    [Parameter(Mandatory)][string] $AppConfigPrivateEndpointSubnetName,
    [Parameter(Mandatory)][string] $ApplicationSubnetName,
    [Parameter(Mandatory)][string] $AppConfigName,
    [Parameter()][string] $AppConfigLocation = "westeurope",
    [Parameter(Mandatory)][string] $AppConfigResourceGroupName,
    [Parameter()][string] $AppConfigDiagnosticsName,
    [Parameter()][string] $LogAnalyticsWorkspaceName,
    [Parameter(Mandatory)][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $AppConfigPrivateDnsZoneName = "privatelink.azconfig.io"
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\PrivateEndpoint-Helper-Functions.ps1"
#endregion ===END IMPORTS===

Write-Header

$appConfigPrivateEndpointVnetId = (Invoke-Executable az network vnet show --resource-group $AppConfigPrivateEndpointVnetResourceGroupName --name $AppConfigPrivateEndpointVnetName | ConvertFrom-Json).id
$appConfigPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $AppConfigPrivateEndpointVnetResourceGroupName --name $AppConfigPrivateEndpointSubnetName --vnet-name $AppConfigPrivateEndpointVnetName | ConvertFrom-Json).id
$appConfigPrivateEndpointName = "$($AppConfigName)-pvtappcfg"

# Create AppConfig with the appropriate tags
Invoke-Executable az appconfig create --resource-group $AppConfigResourceGroupName --name $AppConfigName --location $AppConfigLocation --sku Standard

# Fetch the App Config ID to use while creating the Diagnostics settings in the next step
$appConfigId = (Invoke-Executable az appconfig show --name $AppConfigName --resource-group $AppConfigResourceGroupName | ConvertFrom-Json).id

# Create diagnostics settings for the App Config resource
Invoke-Executable az monitor diagnostic-settings create --resource $appConfigId --name $AppConfigDiagnosticsName --workspace $LogAnalyticsWorkspaceName --metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')

# Add private endpoint & Setup Private DNS
Add-PrivateEndpoint -PrivateEndpointVnetId $appConfigPrivateEndpointVnetId -PrivateEndpointSubnetId $appConfigPrivateEndpointSubnetId -PrivateEndpointName $appConfigPrivateEndpointName -PrivateEndpointResourceGroupName $AppConfigResourceGroupName -TargetResourceId $appConfigId -PrivateEndpointGroupId configurationStores -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $AppConfigPrivateDnsZoneName -PrivateDnsLinkName "$($AppConfigPrivateEndpointVnetName)-appcfg"

# Assign Identity to App Configuration store
Invoke-Executable az appconfig identity assign --resource-group $AppConfigResourceGroupName --name $AppConfigName

# Disable public access on the App Configuration store
Invoke-Executable az appconfig update --resource-group $AppConfigResourceGroupName --name $AppConfigName --enable-public-network false

Write-Footer