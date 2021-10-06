[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    # Required Parameters
    [Parameter(Mandatory)][string] $CosmosDbAccountName,
    [Parameter(Mandatory)][string] $CosmosDbAccountResourceGroupName,
    [Parameter(Mandatory)][string] $CassandraKeySpaceName,
    [Parameter(Mandatory, ParameterSetName = "Throughput")][string][ValidateSet("Autoscale", "Manual")] $CassandraKeyspaceThroughputType,
    [Parameter(Mandatory, ParameterSetName = "Throughput")][int] $CassandraKeyspaceThroughputAmount
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# CosmosDb account can only take lowercase characters
$CosmosDBAccountName = $CosmosDBAccountName.ToLower()

$optionalParameters = @()
switch ($CassandraKeyspaceThroughputType)
{
    'Autoscale' 
    { 
        if ($CassandraKeyspaceThroughputAmount -and ($CassandraKeyspaceThroughputAmount -gt 1000000 -or $CassandraKeyspaceThroughputAmount -lt 4000))
        {
            throw "For throughput type: $CassandraKeyspaceThroughputType you need to specify a range between 4000 and 1000000 in increments of 1000."
        }

        $optionalParameters += '--max-throughput', $CassandraKeyspaceThroughputAmount 
    }
    'Manual' 
    { 
        if ($cassandraKeyspaceThroughputAmount -and ($CassandraKeyspaceThroughputAmount -gt 1000000 -or $CassandraKeyspaceThroughputAmount -lt 400))
        {
            throw "For throughput type: $CassandraKeyspaceThroughputType you need to specify a range between 400 and 1000000 in increments of 100."
        }
        $optionalParameters += '--throughput', $CassandraKeyspaceThroughputAmount
    }
    Default 
    {
        break
    }
}

$keyspaceExists = Invoke-Executable az cosmosdb cassandra keyspace exists --account-name $CosmosDbAccountName --name $CassandraKeyspaceName --resource-group $CosmosDbAccountResourceGroupName
if ([System.Convert]::ToBoolean($keyspaceExists))
{
    $keyspaceThroughput = Invoke-Executable -AllowToFail az cosmosdb cassandra keyspace throughput show --account-name  $CosmosDbAccountName --name $CassandraKeyspaceName --resource-group $CosmosDbAccountResourceGroupName | ConvertFrom-Json
    if ($keyspaceThroughput -and $CassandraKeyspaceThroughputType)
    {
        $keyspaceCurrentThroughputType = $null -eq $keyspaceThroughput.resource.autoscaleSettings ? "Manual" : "Autoscale"
        if ($keyspaceCurrentThroughputType -ne $CassandraKeyspaceThroughputType)
        {
            Write-Host "Migrating keyspace from $keyspaceCurrentThroughputType to $CassandraKeyspaceThroughputType"
            Invoke-Executable az cosmosdb cassandra keyspace throughput migrate --account-name $CosmosDbAccountName --name $CassandraKeyspaceName --resource-group $CosmosDbAccountResourceGroupName --throughput-type $CassandraKeyspaceThroughputType
        }
        else
        {
            Write-Host "No need to migrate keyspace throughput type. Continueing.."
        }
    }
}

# Create Cassandra Keyspace
Invoke-Executable az cosmosdb cassandra keyspace create --account-name $CosmosDbAccountName --name $CassandraKeySpaceName --resource-group $CosmosDbAccountResourceGroupName @optionalParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet