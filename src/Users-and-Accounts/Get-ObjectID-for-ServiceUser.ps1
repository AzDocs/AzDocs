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

Write-Host "get token for Service Principal from service connection for this pipeline, prerequisite is having User.Read Permission on Microsoft Graph for this Service Principal"
Invoke-Executable az account get-access-token --resource https://graph.microsoft.com

$objectId = (Invoke-Executable az ad user show --id $ServiceUserEmail | ConvertFrom-Json).Id

Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariableName);isOutput=true]$objectId"

Write-Output $objectId

Write-Footer -ScopedPSCmdlet $PSCmdlet