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
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az storage container create --account-name $storageAccountName --name $containerName --auth-mode login

Write-Footer