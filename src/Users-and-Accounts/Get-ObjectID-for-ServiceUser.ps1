[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ServiceUserEmail,
    [Parameter(Mandatory)][string] $ServiceUserPassword
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az login --username $ServiceUserEmail --password $ServiceUserPassword --allow-no-subscriptions
Write-Output (Invoke-Executable az ad user show --id $ServiceUserEmail | ConvertFrom-Json).objectId

Write-Footer