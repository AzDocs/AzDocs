[CmdletBinding()]
param (
    # Required Parameters
    [Parameter(Mandatory)][string] $CosmosDbAccountName,
    [Parameter(Mandatory)][string] $CosmosDbResourceGroupName,
    [Parameter(Mandatory)][string] $CassandraKeySpaceName,
    [Parameter(Mandatory)][string] $CassandraTableName,
    [Parameter(Mandatory)][string] $CassandraTableSchema
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Test if valid JSON
if (!($CassandraTableSchema | Test-Json))
{
    throw "Entered CassandraTableSchema isn't valid JSON. Please correct this."
}

# CosmosDb account can only take lowercase characters
$CosmosDBAccountName = $CosmosDBAccountName.ToLower()
$CassandraTableSchema = $CassandraTableSchema.Replace("'", '\"')

# Create Cassandra Table
Invoke-Executable az cosmosdb cassandra table create --account-name $CosmosDbAccountName --keyspace-name $CassandraKeySpaceName --resource-group $CosmosDbResourceGroupName --name $CassandraTableName --schema $CassandraTableSchema

Write-Footer -ScopedPSCmdlet $PSCmdlet