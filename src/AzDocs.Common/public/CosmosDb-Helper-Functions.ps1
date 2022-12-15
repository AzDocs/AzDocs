function Wait-ForClusterToBeReady
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $CosmosDBAccountName,
        [Parameter(Mandatory)][string] $CosmosDBAccountResourceGroupName
    )

    # Make sure we dont talk to an updating cluster
    while ((Invoke-Executable az cosmosdb show --name $CosmosDBAccountName --resource-group $CosmosDBAccountResourceGroupName | ConvertFrom-Json).provisioningState -ne 'Succeeded')
    {
        Write-Host 'Cluster not ready yet... Waiting for cluster to be ready...'
        Start-Sleep -s 30
    }
}