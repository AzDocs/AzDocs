[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $StorageResourceGroupName,
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $StorageAccountVnetName,
    [Alias("VnetResourceGroupName")]
    [Parameter(Mandatory)][string] $StorageAccountVnetResourceGroupName,
    [Alias("SubnetToWhitelist")]
    [Parameter(Mandatory)][string] $SubnetToWhiteListOnStorageAccount,
    [Parameter(Mandatory)][string] $StorageAccountName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\PrivateEndpoint-Helper-Functions.ps1"
#endregion ===END IMPORTS===

Write-Header

$subnetToWhitelistId = (Invoke-Executable az network vnet subnet show --resource-group $StorageAccountVnetResourceGroupName --name $SubnetToWhiteListOnStorageAccount --vnet-name $StorageAccountVnetName | ConvertFrom-Json).id

# Add Service Endpoint to the Subnet to make sure we can connect to the service within the VNET
Set-SubnetServiceEndpoint -SubnetResourceId $subnetToWhitelistId -ServiceEndpointServiceIdentifier "Microsoft.Storage"

# Whitelist our App's subnet in the storage account so we can connect
Invoke-Executable az storage account network-rule add --resource-group $StorageResourceGroupName --account-name $StorageAccountName --subnet $subnetToWhitelistId

Write-Footer