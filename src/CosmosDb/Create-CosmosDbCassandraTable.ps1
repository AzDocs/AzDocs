[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    # Required Parameters
    [Parameter(Mandatory)][string] $CosmosDbAccountName,
    [Parameter(Mandatory)][string] $CosmosDbAccountResourceGroupName,
    [Parameter(Mandatory)][string] $CassandraKeySpaceName,
    [Parameter(Mandatory)][string] $CassandraTableName,
    [Parameter(Mandatory)][string] $CassandraTableSchema,
    [Parameter(Mandatory, ParameterSetName = 'Throughput')][string][ValidateSet('Autoscale', 'Manual')] $CassandraTableThroughputType,
    [Parameter(Mandatory, ParameterSetName = 'Throughput')][int] $CassandraTableThroughputAmount
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

$optionalParameters = @()
switch ($CassandraTableThroughputType)
{
    'Autoscale' 
    { 
        if ($CassandraTableThroughputAmount -and ($CassandraTableThroughputAmount -gt 1000000 -or $CassandraTableThroughputAmount -lt 4000))
        {
            throw "For throughput type: $CassandraTableThroughputType you need to specify a range between 4000 and 1000000 in increments of 1000."
        }
    
        $optionalParameters += '--max-throughput', $CassandraTableThroughputAmount 
    }
    'Manual' 
    { 
        if ($CassandraTableThroughputType -and ($CassandraTableThroughputAmount -gt 1000000 -or $CassandraTableThroughputAmount -lt 400))
        {
            throw "For throughput type: $CassandraTableThroughputType you need to specify a range between 400 and 1000000 in increments of 100."
        }
        $optionalParameters += '--throughput', $CassandraTableThroughputAmount
    }
    Default
    {
        break
    }
}

# CosmosDb account can only take lowercase characters
$CosmosDBAccountName = $CosmosDBAccountName.ToLower()
$CassandraTableSchema = $CassandraTableSchema.Replace('"', '\"')

$tableExists = Invoke-Executable az cosmosdb cassandra table exists --account-name $CosmosDbAccountName --name $CassandraTableName --resource-group $CosmosDbAccountResourceGroupName --keyspace-name $CassandraKeySpaceName
if ([System.Convert]::ToBoolean($tableExists))
{
    $tableThroughput = Invoke-Executable -AllowToFail az cosmosdb cassandra table throughput show --account-name $CosmosDbAccountName --name $CassandraTableName --keyspace-name $CassandraKeySpaceName --resource-group $CosmosDbAccountResourceGroupName | ConvertFrom-Json
    if ($tableThroughput -and $CassandraTableThroughputType)
    {
        $tableCurrentThroughputType = $null -eq $tableThroughput.resource.autoscaleSettings ? 'Manual' : 'Autoscale'
        if ($tableCurrentThroughputType -ne $CassandraTableThroughputType)
        {
            Write-Host "Migrating table from $tableCurrentThroughputType to $CassandraTableThroughputType"
            Invoke-Executable az cosmosdb cassandra table throughput migrate --account-name $CosmosDbAccountName --name $CassandraTableName --keyspace-name $CassandraKeyspaceName --resource-group $CosmosDbAccountResourceGroupName --throughput-type $CassandraTableThroughputType
        }
        else
        {
            Write-Host 'No need to migrate table throughput type. Continueing..'
        }
    }
}

# Create Cassandra Table
Invoke-Executable az cosmosdb cassandra table create --account-name $CosmosDbAccountName --keyspace-name $CassandraKeySpaceName --resource-group $CosmosDbAccountResourceGroupName --name $CassandraTableName --schema $CassandraTableSchema @optionalParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet