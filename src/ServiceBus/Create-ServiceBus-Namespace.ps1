[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ServiceBusNamespaceName,
    [Parameter(Mandatory)][string] $ServiceBusNamespaceResourceGroupName,
    [Parameter(Mandatory)][ValidateSet("Basic", "Standard", "Premium")][string] $ServiceBusNamespaceSku,
    [Parameter(Mandatory)][System.Object[]] $ResourceTags,
    
    # VNET Whitelisting
    [Parameter()][string] $ApplicationVnetResourceGroupName,
    [Parameter()][string] $ApplicationVnetName,
    [Parameter()][string] $ApplicationSubnetName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az servicebus namespace create --resource-group $ServiceBusNamespaceResourceGroupName --name $ServiceBusNamespaceName --sku $ServiceBusNamespaceSku --tags $ResourceTags

# Private endpoints are not supported

# VNET Whitelisting (only supported in SKU Premium)
if ($ServiceBusNamespaceSku -eq "Premium" -and $ApplicationVnetResourceGroupName -and $ApplicationVnetName -and $ApplicationSubnetName)
{
    Write-Host "VNET Whitelisting is desired. Adding the needed components."
    
    # Whitelist VNET
    & "$PSScriptRoot\Add-Network-Whitelist-to-ServiceBus-Namespace.ps1" -ServiceBusNamespaceName $ServiceBusNamespaceName -ServiceBusNamespaceResourceGroupName $ServiceBusNamespaceResourceGroupName -SubnetToWhitelistSubnetName $ApplicationSubnetName -SubnetToWhitelistVnetName $ApplicationVnetName -SubnetToWhitelistVnetResourceGroupName $ApplicationVnetResourceGroupName
}

Write-Footer -ScopedPSCmdlet $PSCmdlet