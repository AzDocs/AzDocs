[CmdletBinding()]
param (
    [Alias("StorageResourceGroupName")]
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupName,
    [Parameter(Mandatory)][System.Object[]] $ResourceTags,
    [Parameter(Mandatory)][string] $StorageAccountName,

    # VNET Whitelisting
    [Parameter()][string] $ApplicationVnetResourceGroupName,
    [Parameter()][string] $ApplicationVnetName,
    [Parameter()][string] $ApplicationSubnetName,

    # Private Endpoint
    [Alias("VnetName")]
    [Parameter()][string] $StorageAccountPrivateEndpointVnetName,
    [Alias("VnetResourceGroupName")]
    [Parameter()][string] $StorageAccountPrivateEndpointVnetResourceGroupName,
    [Parameter()][string] $StorageAccountPrivateEndpointSubnetName,
    [Parameter()][string] $PrivateEndpointGroupId,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $StorageAccountPrivateDnsZoneName = "privatelink.blob.core.windows.net"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Create StorageAccount with the appropriate tags
Invoke-Executable az storage account create --name $StorageAccountName --resource-group $StorageAccountResourceGroupName --kind StorageV2 --sku Standard_LRS --allow-blob-public-access false --tags ${ResourceTags}

# VNET Whitelisting
if ($ApplicationVnetResourceGroupName -and $ApplicationVnetName -and $ApplicationSubnetName)
{
    Write-Host "VNET Whitelisting is desired. Adding the needed components."

    # Whitelist VNET
    & "$PSScriptRoot\Add-Network-Whitelist-to-StorageAccount.ps1" -StorageAccountName $StorageAccountName -StorageAccountResourceGroupName $StorageAccountResourceGroupName -SubnetToWhitelistSubnetName $ApplicationSubnetName -SubnetToWhitelistVnetName $ApplicationVnetName -SubnetToWhitelistVnetResourceGroupName $ApplicationVnetResourceGroupName

    # Make sure the default action is "deny" which causes public traffic to be dropped (like is defined in the KSP)
    Invoke-Executable az storage account update --resource-group $StorageAccountResourceGroupName --name $StorageAccountName --default-action Deny
}

# Private Endpoint
if ($StorageAccountPrivateEndpointVnetName -and $StorageAccountPrivateEndpointVnetResourceGroupName -and $StorageAccountPrivateEndpointSubnetName -and $PrivateEndpointGroupId -and $DNSZoneResourceGroupName -and $StorageAccountPrivateDnsZoneName)
{
    Write-Host "A private endpoint is desired. Adding the needed components."
    # Fetch the basic information for creating the Private Endpoint
    $storageAccountId = (Invoke-Executable az storage account show --name $StorageAccountName --resource-group $StorageAccountResourceGroupName | ConvertFrom-Json).id
    $vnetId = (Invoke-Executable az network vnet show --resource-group $StorageAccountPrivateEndpointVnetResourceGroupName --name $StorageAccountPrivateEndpointVnetName | ConvertFrom-Json).id
    $storageAccountPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $StorageAccountPrivateEndpointVnetResourceGroupName --name $StorageAccountPrivateEndpointSubnetName --vnet-name $StorageAccountPrivateEndpointVnetName | ConvertFrom-Json).id
    $storageAccountPrivateEndpointName = "$($StorageAccountName)-pvtstg-$($PrivateEndpointGroupId)"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $storageAccountPrivateEndpointSubnetId -PrivateEndpointName $storageAccountPrivateEndpointName -PrivateEndpointResourceGroupName $StorageAccountResourceGroupName -TargetResourceId $storageAccountId -PrivateEndpointGroupId $PrivateEndpointGroupId -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $StorageAccountPrivateDnsZoneName -PrivateDnsLinkName "$($StorageAccountPrivateEndpointVnetName)-storage"

    # Make sure the default action is "deny" which causes public traffic to be dropped (like is defined in the KSP)
    Invoke-Executable az storage account update --resource-group $StorageAccountResourceGroupName --name $StorageAccountName --default-action Deny
}

Write-Footer -ScopedPSCmdlet $PSCmdlet