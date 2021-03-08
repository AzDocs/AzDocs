[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ServiceUserEmail,
    [Parameter(Mandatory)][string] $ServiceUserPassword
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az login --username $ServiceUserEmail --password $ServiceUserPassword --allow-no-subscriptions
Write-Output (Invoke-Executable az ad user show --id $ServiceUserEmail | ConvertFrom-Json).objectId

Write-Footer -ScopedPSCmdlet $PSCmdlet