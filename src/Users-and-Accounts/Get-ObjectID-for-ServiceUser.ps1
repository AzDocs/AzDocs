[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $serviceUserEmail,

    [Parameter(Mandatory)]
    [String] $serviceUserPassword
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az login --username $serviceUserEmail --password $serviceUserPassword --allow-no-subscriptions
Write-Output (Invoke-Executable az ad user show --id $serviceUserEmail | ConvertFrom-Json).objectId

Write-Footer