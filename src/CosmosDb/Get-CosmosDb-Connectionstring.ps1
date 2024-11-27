[CmdletBinding()]
param (
    # Required Parameters
    [Parameter(Mandatory)][string] $CosmosDbAccountName,
    [Parameter(Mandatory)][string] $CosmosDbAccountResourceGroupName,
    [Parameter()][string] $OutputPipelineVariableName = 'CosmosDbConnectionString'
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# CosmosDb account can only take lowercase characters
$CosmosDBAccountName = $CosmosDBAccountName.ToLower()

# Will for now only return the primary (first) connectionString that will be returned
$keys = Invoke-Executable az cosmosdb keys list --name $CosmosDbAccountName --resource-group $CosmosDbAccountResourceGroupName --type 'connection-strings' | ConvertFrom-Json
$primaryConnectionString = $keys.ConnectionStrings[0].connectionString
Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariableName);isOutput=true]$primaryConnectionString"

Write-Footer -ScopedPSCmdlet $PSCmdlet