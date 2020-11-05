[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $serviceUserEmail,

    [Parameter(Mandatory)]
    [String] $serviceUserPassword
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Invoke-Executable az login --username $serviceUserEmail --password $serviceUserPassword --allow-no-subscriptions
(Invoke-Executable az ad user show --id $serviceUserEmail | ConvertFrom-Json).objectId
