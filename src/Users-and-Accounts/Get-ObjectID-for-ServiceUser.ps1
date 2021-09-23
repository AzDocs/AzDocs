[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ServiceUserEmail,
    [Parameter(Mandatory)][string] $ServiceUserPassword,
    [Parameter()][string] $OutputPipelineVariableName = "ServiceUserObjectId"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az login --username $ServiceUserEmail --password $ServiceUserPassword --allow-no-subscriptions
$objectId = (Invoke-Executable az ad user show --id $ServiceUserEmail | ConvertFrom-Json).objectId

Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariableName);isOutput=true]$objectId"

Write-Output $objectId

Write-Footer -ScopedPSCmdlet $PSCmdlet