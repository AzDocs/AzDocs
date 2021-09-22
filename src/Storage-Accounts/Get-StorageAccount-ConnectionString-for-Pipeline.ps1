[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupName,
    [Parameter()][string] $OutputPipelineVariableName = "StorageAccountConnectionString"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$storageAccountConnectionString = (Invoke-Executable az storage account show-connection-string --resource-group $StorageAccountResourceGroupName --name $StorageAccountName | ConvertFrom-Json).connectionString
Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariableName);isOutput=true]$storageAccountConnectionString"

Write-Footer -ScopedPSCmdlet $PSCmdlet