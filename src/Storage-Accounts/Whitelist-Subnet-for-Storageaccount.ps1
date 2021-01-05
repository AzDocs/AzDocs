[CmdletBinding()]
param (
    [Parameter()]
    [String] $storageResourceGroupName,

    [Parameter()]
    [String] $vnetName,

    [Parameter()]
    [String] $vnetResourceGroupName,

    [Parameter()]
    [String] $subnetToWhitelist,

    [Parameter()]
    [String] $storageAccountName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\Set-SubnetServiceEndpoint.ps1"
#endregion ===END IMPORTS===

Write-Header

$subnetToWhitelistId = (Invoke-Executable az network vnet subnet show -g $vnetResourceGroupName -n $subnetToWhitelist --vnet-name $vnetName | ConvertFrom-Json).id

# Add Service Endpoint to the Subnet to make sure we can connect to the service within the VNET
Set-SubnetServiceEndpoint -SubnetResourceId $subnetToWhitelistId -ServiceName "Microsoft.Storage"

# Whitelist our App's subnet in the storage account so we can connect
Invoke-Executable az storage account network-rule add --resource-group $storageResourceGroupName --account-name $storageAccountName --subnet $subnetToWhitelistId

Write-Footer