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

az storage share create --account-name $storageAccountName --name $shareName --auth-mode login