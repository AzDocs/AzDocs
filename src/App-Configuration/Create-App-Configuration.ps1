[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppConfigResourceGroupName,
    [Parameter(Mandatory)][string] $AppConfigName,
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    [Parameter()][string] $AppConfigLocation = "westeurope",
    [Alias("LogAnalyticsWorkspaceName")]
    [Parameter()][ValidateSet("Free", "Standard")][string] $AppConfigSku = 'Standard',
    [Parameter()][bool] $AppConfigAllowPublicAccess = $false,

    # Private Endpoint
    [Alias("VnetResourceGroupName")]
    [Parameter()][string] $AppConfigPrivateEndpointVnetResourceGroupName,
    [Alias("VnetName")]
    [Parameter()][string] $AppConfigPrivateEndpointVnetName,
    [Parameter()][string] $AppConfigPrivateEndpointSubnetName,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $AppConfigPrivateDnsZoneName = "privatelink.azconfig.io",

    # Forcefully agree to this resource to be spun up to be publicly available
    [Parameter()][switch] $ForcePublic
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if (!$AppConfigPrivateEndpointVnetResourceGroupName -or !$AppConfigPrivateEndpointVnetName -or !$AppConfigPrivateEndpointSubnetName -or !$PrivateEndpointGroupId -or !$DNSZoneResourceGroupName -or !$AppConfigPrivateDnsZoneName)
{
    # Check if we are making this resource public intentionally
    Assert-IntentionallyCreatedPublicResource -ForcePublic $ForcePublic
}


# Create AppConfig with the appropriate tags
Invoke-Executable az appconfig create --resource-group $AppConfigResourceGroupName --name $AppConfigName --location $AppConfigLocation --sku $AppConfigSku

# Fetch the App Config ID to use while creating the Diagnostics settings in the next step
$appConfigId = (Invoke-Executable az appconfig show --name $AppConfigName --resource-group $AppConfigResourceGroupName | ConvertFrom-Json).id

# Create diagnostics settings for the App Config resource
Set-DiagnosticSettings -ResourceId $appConfigId -ResourceName $AppConfigName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -Metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')

if ($AppConfigPrivateEndpointVnetResourceGroupName -and $AppConfigPrivateEndpointVnetName -and $AppConfigPrivateEndpointSubnetName -and $AppConfigPrivateDnsZoneName)
{
    $appConfigPrivateEndpointVnetId = (Invoke-Executable az network vnet show --resource-group $AppConfigPrivateEndpointVnetResourceGroupName --name $AppConfigPrivateEndpointVnetName | ConvertFrom-Json).id
    $appConfigPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $AppConfigPrivateEndpointVnetResourceGroupName --name $AppConfigPrivateEndpointSubnetName --vnet-name $AppConfigPrivateEndpointVnetName | ConvertFrom-Json).id
    $appConfigPrivateEndpointName = "$($AppConfigName)-pvtappcfg"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $appConfigPrivateEndpointVnetId -PrivateEndpointSubnetId $appConfigPrivateEndpointSubnetId -PrivateEndpointName $appConfigPrivateEndpointName -PrivateEndpointResourceGroupName $AppConfigResourceGroupName -TargetResourceId $appConfigId -PrivateEndpointGroupId configurationStores -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $AppConfigPrivateDnsZoneName -PrivateDnsLinkName "$($AppConfigPrivateEndpointVnetName)-appcfg"
}

# Assign Identity to App Configuration store
Invoke-Executable az appconfig identity assign --resource-group $AppConfigResourceGroupName --name $AppConfigName

# Set public access on the App Configuration store
Invoke-Executable az appconfig update --resource-group $AppConfigResourceGroupName --name $AppConfigName --enable-public-network $AppConfigAllowPublicAccess

Write-Footer -ScopedPSCmdlet $PSCmdlet