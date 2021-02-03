[CmdletBinding()]
param (
    [Alias("StorageAccountResourceGroupname")]
    [Parameter(Mandatory)][string] $FileshareStorageAccountResourceGroupname,
    [Alias("StorageAccountName")]
    [Parameter(Mandatory)][string] $FileshareStorageAccountName,
    [Alias("ShareName")]
    [Parameter(Mandatory)][string] $FileshareName,
    [Alias("VnetName")]
    [Parameter()][string] $FileshareVnetName,
    [Alias("VnetResourceGroupName")]
    [Parameter()][string] $FileshareVnetResourceGroupName,
    [Alias("SubnetToWhitelist")]
    [Parameter()][string] $SubnetToWhitelistOnStorageAccount,
    [Alias("StorageAccountIsInVnet")]
    [Parameter()][switch] $FileshareStorageAccountIsInVnet
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\PrivateEndpoint-Helper-Functions.ps1"
#endregion ===END IMPORTS===

Write-Header

if($FileshareStorageAccountIsInVnet)
{
    $subnetToWhitelistId = (Invoke-Executable az network vnet subnet show --resource-group $FileshareVnetResourceGroupName --name $SubnetToWhitelistOnStorageAccount --vnet-name $FileshareVnetName | ConvertFrom-Json).id

    # Add Service Endpoint to the Subnet to make sure we can connect to the service within the VNET
    Set-SubnetServiceEndpoint -SubnetResourceId $subnetToWhitelistId -ServiceEndpointServiceIdentifier "Microsoft.Storage"

    # Whitelist our App's subnet in the storage account so we can connect
    Invoke-Executable az storage account network-rule add --resource-group $FileshareStorageAccountResourceGroupname --account-name $FileshareStorageAccountName --subnet $subnetToWhitelistId
}

Invoke-Executable az storage share-rm create --storage-account $FileshareStorageAccountName --name $FileshareName

Write-Footer