[CmdletBinding()]
param (
    [Parameter()]
    [String] $storageAccountResourceGroupname,

    [Parameter()]
    [String] $storageAccountName,

    [Parameter()]
    [String] $shareName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

# Somehow we need to use the account key. Managed Identities/integrated security does not seem to work stable over the CLI versions.
$accountKey = az storage account keys list --resource-group $storageAccountResourceGroupname --account-name $storageAccountName --query=[0].value | ConvertFrom-Json

az storage share create --account-name $storageAccountName --name $shareName --account-key $accountKey