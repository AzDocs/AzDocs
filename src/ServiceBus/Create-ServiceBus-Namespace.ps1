[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ServiceBusNamespaceName,
    [Parameter(Mandatory)][string] $ServiceBusNamespaceResourceGroupName,
    [Parameter(Mandatory)][ValidateSet('Basic', 'Standard', 'Premium')][string] $ServiceBusNamespaceSku,
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
    [Parameter()][string] $ServiceBusNamespacePrivateDnsZoneName = 'privatelink.servicebus.windows.net',

    [Parameter()][bool] $ServiceBusNamespaceZoneRedundancy = $false,
    [Parameter()][ValidateSet(1, 2, 4, 8)][int] $ServiceBusNamespaceCapacityInMessageUnits = 1,

    # Forcefully agree to this resource to be spun up to be publicly available
    [Parameter()][switch] $ForcePublic, 

    # Diagnostic settings
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId, 
    [Parameter()][System.Object[]] $DiagnosticSettingsLogs,
    [Parameter()][System.Object[]] $DiagnosticSettingsMetrics,
    
    # Disable diagnostic settings
    [Parameter()][switch] $DiagnosticSettingsDisabled
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

$optionalParameters = @()
if ($ServiceBusNamespaceCapacityInMessageUnits -and $ServiceBusNamespaceSku -eq 'Premium')
{
    $optionalParameters += '--capacity', $ServiceBusNamespaceCapacityInMessageUnits
}

# There is no support for zone redundancy in the az cli or azure powershell modules.
# This can only be used with premium sku and since the api version is in preview, we'll only use it in this situation
if ($ServiceBusNamespaceSku -eq 'Premium' -and $ServicebusNamespaceZoneRedundancy -eq $true)
{
    $resourceGroupLocation = (Invoke-Executable az group show --resource-group $ServiceBusNamespaceResourceGroupName | ConvertFrom-Json).location
    
    $body = @{ 
        name       = $ServiceBusNamespaceName
        location   = $resourceGroupLocation
        sku        = @{
            capacity = $ServiceBusNamespaceCapacityInMessageUnits
            name     = $ServiceBusNamespaceSku
            tier     = $ServiceBusNamespaceSku
        }
        properties = @{
            zoneRedundant = $ServiceBusNamespaceZoneRedundancy
        }
    }

    # The create call is a PUT instead of a POST ¯\_(ツ)_/¯
    $subscriptionId = (Invoke-Executable az account show | ConvertFrom-Json).id
    $url = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$ServiceBusNamespaceResourceGroupName/providers/Microsoft.ServiceBus/namespaces/$ServiceBusNamespaceName"
    Invoke-AzRestCall -Method PUT -ResourceUrl $url -ApiVersion '2021-01-01-preview' -Body $body

    $serviceBusNamespace = Invoke-Executable az servicebus namespace show --resource-group $ServiceBusNamespaceResourceGroupName --name $ServiceBusNamespaceName | ConvertFrom-Json
}
else
{
    Invoke-Executable az servicebus namespace create --resource-group $ServiceBusNamespaceResourceGroupName --name $ServiceBusNamespaceName --sku $ServiceBusNamespaceSku --tags @ResourceTags @optionalParameters | ConvertFrom-Json
    $serviceBusNamespace = Invoke-Executable az servicebus namespace show --resource-group $ServiceBusNamespaceResourceGroupName --name $ServiceBusNamespaceName | ConvertFrom-Json
}

# Need to wait for the provisioning to succeed, so we can update the tags
while ($serviceBusNamespace.provisioningState -ne 'Succeeded')
{
    Write-Host 'Waiting for 30 seconds till the servicebus is provisioned'
    Start-Sleep -Seconds 30
    $serviceBusNamespace = Invoke-Executable az servicebus namespace show --resource-group $ServiceBusNamespaceResourceGroupName --name $ServiceBusNamespaceName | ConvertFrom-Json
}

# Update Tags
if ($ResourceTags)
{
    Set-ResourceTagsForResource -ResourceId $serviceBusNamespace.id -ResourceTags ${ResourceTags}
}

# VNET Whitelisting (only supported in SKU Premium)
if ($ApplicationVnetResourceGroupName -and $ApplicationVnetName -and $ApplicationSubnetName)
{
    if ($ServiceBusNamespaceSku -ne 'Premium')
    {
        throw "VNET Whitelisting only supported on Premium SKU. Current SKU: $ServiceBusNamespaceSku"
    }

    Write-Host 'VNET Whitelisting is desired. Adding the needed components.'
    
    # Whitelist VNET
    & "$PSScriptRoot\Add-Network-Whitelist-to-ServiceBus-Namespace.ps1" -ServiceBusNamespaceName $ServiceBusNamespaceName -ServiceBusNamespaceResourceGroupName $ServiceBusNamespaceResourceGroupName -SubnetToWhitelistSubnetName $ApplicationSubnetName -SubnetToWhitelistVnetName $ApplicationVnetName -SubnetToWhitelistVnetResourceGroupName $ApplicationVnetResourceGroupName
}

# Private Endpoint
if ($ServiceBusNamespacePrivateEndpointVnetName -and $ServiceBusNamespacePrivateEndpointVnetResourceGroupName -and $ServiceBusNamespacePrivateEndpointSubnetName -and $DNSZoneResourceGroupName -and $ServiceBusNamespacePrivateDnsZoneName)
{
    if ($ServiceBusNamespaceSku -ne 'Premium')
    {
        throw "Private endpoint only supported on Premium SKU. Current SKU: $ServiceBusNamespaceSku"
    }

    Write-Host 'A private endpoint is desired. Adding the needed components.'
    # Fetch the basic information for creating the Private Endpoint
    $vnetId = (Invoke-Executable az network vnet show --resource-group $ServiceBusNamespacePrivateEndpointVnetResourceGroupName --name $ServiceBusNamespacePrivateEndpointVnetName | ConvertFrom-Json).id
    $serviceBusNamespacePrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ServiceBusNamespacePrivateEndpointVnetResourceGroupName --name $ServiceBusNamespacePrivateEndpointSubnetName --vnet-name $ServiceBusNamespacePrivateEndpointVnetName | ConvertFrom-Json).id
    $serviceBusNamespacePrivateEndpointName = "$($ServiceBusNamespaceName)-pvtsbns"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $serviceBusNamespacePrivateEndpointSubnetId -PrivateEndpointName $serviceBusNamespacePrivateEndpointName -PrivateEndpointResourceGroupName $ServiceBusNamespaceResourceGroupName -TargetResourceId $serviceBusNamespace.id -PrivateEndpointGroupId namespace -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $ServiceBusNamespacePrivateDnsZoneName -PrivateDnsLinkName "$($ServiceBusNamespacePrivateEndpointVnetName)-servicebusnamespace"
}

# Enable diagnostic settings for servicebus namespace
if ($DiagnosticSettingsDisabled)
{
    Remove-DiagnosticSetting -ResourceId $serviceBusNamespace.id -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $ServiceBusNamespaceName
}
else
{
    Set-DiagnosticSettings -ResourceId $serviceBusNamespace.id -ResourceName $ServiceBusNamespaceName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -DiagnosticSettingsLogs:$DiagnosticSettingsLogs -DiagnosticSettingsMetrics:$DiagnosticSettingsMetrics 
}

Write-Footer -ScopedPSCmdlet $PSCmdlet