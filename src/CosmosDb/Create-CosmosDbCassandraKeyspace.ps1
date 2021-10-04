[CmdletBinding()]
param (
    # Required Parameters
    [Parameter(Mandatory)][string] $CosmosDbAccountName,
    [Parameter(Mandatory)][string] $CosmosDbResourceGroupName,
    [Parameter(Mandatory)][string] $CassandraKeySpaceName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# CosmosDb account can only take lowercase characters
$CosmosDBAccountName = $CosmosDBAccountName.ToLower()

# Create Cassandra KeySpace
Invoke-Executable az cosmosdb cassandra keyspace create --account-name $CosmosDbAccountName --name $CassandraKeySpaceName --resource-group $CosmosDbResourceGroupName

Write-Footer -ScopedPSCmdlet $PSCmdlet