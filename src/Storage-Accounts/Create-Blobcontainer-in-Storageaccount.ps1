[CmdletBinding()]
param (
    [Parameter()]
    [String] $storageAccountResourceGroupname,

    [Parameter()]
    [String] $storageAccountName,

    [Parameter()]
    [String] $containerName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Invoke-Executable az storage container create --account-name $storageAccountName --name $containerName --auth-mode login