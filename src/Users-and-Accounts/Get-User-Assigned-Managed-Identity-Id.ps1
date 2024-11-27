[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $UserAssignedManagedIdentityName,
    [Parameter(Mandatory)][string] $UserAssignedManagedIdentityResourceGroupName,
    [Parameter()][string] $OutputPipelineVariableName = 'UserAssignedManagedIdentityId'
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$id = (Invoke-Executable az identity show --name $UserAssignedManagedIdentityName --resource-group $UserAssignedManagedIdentityResourceGroupName | ConvertFrom-Json).id
Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariableName);isOutput=true]$id"

Write-Footer -ScopedPSCmdlet $PSCmdlet