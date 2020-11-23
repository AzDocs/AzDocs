[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $storageAccountResourceGroupname,

    [Parameter(Mandatory)]
    [String] $storageAccountName,

    [Parameter(Mandatory)]
    [String] $shareName,

    [Parameter()]
    [String] $vnetName,

    [Parameter()]
    [String] $vnetResourceGroupName,

    [Parameter()]
    [String] $subnetToWhitelist,

    [Parameter()]
    [Switch] $storageAccountIsInVnet
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\Set-SubnetServiceEndpoint.ps1"
#endregion ===END IMPORTS===

if($storageAccountIsInVnet)
{
    $subnetToWhitelistId = (Invoke-Executable az network vnet subnet show -g $vnetResourceGroupName -n $subnetToWhitelist --vnet-name $vnetName | ConvertFrom-Json).id

    # Add Service Endpoint to the Subnet to make sure we can connect to the service within the VNET
    Set-SubnetServiceEndpoint -SubnetResourceId $subnetToWhitelistId -ServiceName "Microsoft.Storage"

    # Whitelist our App's subnet in the storage account so we can connect
    Invoke-Executable az storage account network-rule add --resource-group $storageAccountResourceGroupname --account-name $storageAccountName --subnet $subnetToWhitelistId
}

# Somehow we need to use the account key. Managed Identities/integrated security does not seem to work stable over the CLI versions.
$accountKey = Invoke-Executable az storage account keys list --resource-group $storageAccountResourceGroupname --account-name $storageAccountName --query=[0].value | ConvertFrom-Json

Invoke-Executable az storage share create --account-name $storageAccountName --name $shareName --account-key $accountKey