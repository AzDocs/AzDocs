[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ServiceBusNamespaceName,
    [Parameter(Mandatory)][string] $ServiceBusNamespaceResourceGroupName,
    [Parameter(Mandatory)][ValidateSet("Basic", "Standard", "Premium")][string] $ServiceBusNamespaceSku,
    [Parameter()][System.Object[]] $ResourceTags,
    
    # VNET Whitelisting
    [Parameter()][string] $ApplicationVnetResourceGroupName,
    [Parameter()][string] $ApplicationVnetName,
    [Parameter()][string] $ApplicationSubnetName,

    # Private Endpoint
    [Parameter()][string] $ServiceBusNamespacePrivateEndpointVnetName,
    [Parameter()][string] $ServiceBusNamespacePrivateEndpointVnetResourceGroupName,
    [Parameter()][string] $ServiceBusNamespacePrivateEndpointSubnetName,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Parameter()][string] $ServiceBusNamespacePrivateDnsZoneName = "privatelink.servicebus.windows.net",

    # Diagnostic Settings
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId, 

    # Forcefully agree to this resource to be spun up to be publicly available
    [Parameter()][switch] $ForcePublic
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ((!$ApplicationVnetResourceGroupName -or !$ApplicationVnetName -or !$ApplicationSubnetName) -and (!$ServiceBusNamespacePrivateEndpointVnetName -or !$ServiceBusNamespacePrivateEndpointVnetResourceGroupName -or !$ServiceBusNamespacePrivateEndpointSubnetName -or !$DNSZoneResourceGroupName -or !$ServiceBusNamespacePrivateDnsZoneName))
{
    # Check if we are making this resource public intentionally
    Assert-IntentionallyCreatedPublicResource -ForcePublic $ForcePublic
}

$serviceBusNamespaceId = (Invoke-Executable az servicebus namespace create --resource-group $ServiceBusNamespaceResourceGroupName --name $ServiceBusNamespaceName --sku $ServiceBusNamespaceSku --tags $ResourceTags | ConvertFrom-Json).id

# Update Tags
Set-ResourceTagsForResource -ResourceId $serviceBusNamespaceId -ResourceTags ${ResourceTags}

# VNET Whitelisting (only supported in SKU Premium)
if ($ApplicationVnetResourceGroupName -and $ApplicationVnetName -and $ApplicationSubnetName)
{
    if ($ServiceBusNamespaceSku -ne "Premium")
    {
        throw "VNET Whitelisting only supported on Premium SKU. Current SKU: $ServiceBusNamespaceSku"
    }
    Write-Host "VNET Whitelisting is desired. Adding the needed components."
    
    # Whitelist VNET
    & "$PSScriptRoot\Add-Network-Whitelist-to-ServiceBus-Namespace.ps1" -ServiceBusNamespaceName $ServiceBusNamespaceName -ServiceBusNamespaceResourceGroupName $ServiceBusNamespaceResourceGroupName -SubnetToWhitelistSubnetName $ApplicationSubnetName -SubnetToWhitelistVnetName $ApplicationVnetName -SubnetToWhitelistVnetResourceGroupName $ApplicationVnetResourceGroupName
}

# Private Endpoint
if ($ServiceBusNamespacePrivateEndpointVnetName -and $ServiceBusNamespacePrivateEndpointVnetResourceGroupName -and $ServiceBusNamespacePrivateEndpointSubnetName -and $DNSZoneResourceGroupName -and $ServiceBusNamespacePrivateDnsZoneName)
{
    if ($ServiceBusNamespaceSku -ne "Premium")
    {
        throw "Private endpoint only supported on Premium SKU. Current SKU: $ServiceBusNamespaceSku"
    }

    Write-Host "A private endpoint is desired. Adding the needed components."
    # Fetch the basic information for creating the Private Endpoint
    $vnetId = (Invoke-Executable az network vnet show --resource-group $ServiceBusNamespacePrivateEndpointVnetResourceGroupName --name $ServiceBusNamespacePrivateEndpointVnetName | ConvertFrom-Json).id
    $serviceBusNamespacePrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ServiceBusNamespacePrivateEndpointVnetResourceGroupName --name $ServiceBusNamespacePrivateEndpointSubnetName --vnet-name $ServiceBusNamespacePrivateEndpointVnetName | ConvertFrom-Json).id
    $serviceBusNamespacePrivateEndpointName = "$($ServiceBusNamespaceName)-pvtsbns"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $serviceBusNamespacePrivateEndpointSubnetId -PrivateEndpointName $serviceBusNamespacePrivateEndpointName -PrivateEndpointResourceGroupName $ServiceBusNamespaceResourceGroupName -TargetResourceId $serviceBusNamespaceId -PrivateEndpointGroupId namespace -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $ServiceBusNamespacePrivateDnsZoneName -PrivateDnsLinkName "$($ServiceBusNamespacePrivateEndpointVnetName)-servicebusnamespace"
}

# Enable diagnostic settings for servicebus namespace
Set-DiagnosticSettings -ResourceId $serviceBusNamespaceId -ResourceName $ServiceBusNamespaceName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -Metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"') 

Write-Footer -ScopedPSCmdlet $PSCmdlet