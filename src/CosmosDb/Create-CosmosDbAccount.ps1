[CmdletBinding()]
param (
    # Required Parameters
    [Parameter(Mandatory)][string] $CosmosDbAccountName,
    [Parameter(Mandatory)][string] $CosmosDbAccountResourceGroupName,
    [Parameter(Mandatory)][ValidateSet('Table', 'SQL', 'Gremlin', 'MongoDB', 'Cassandra', 'Parse', 'GlobalDocumentDB')][string] $CosmosDbKind,

    # Optional parameters
    [Parameter()][string[]] $CosmosDbCapabilities,

    [Parameter()][int] $CosmosDbBackupIntervalInMinutes,
    [Parameter()][int] $CosmosDbBackupRetentionInHours,
    [Parameter()][ValidateSet('Geo', 'Zone', 'Local')][string] $CosmosDbBackupStorageRedundancy,
    [Parameter()][ValidateSet('BoundedStaleness', 'ConsistentPrefix', 'Eventual', 'Session', 'Strong')][string] $CosmosDbDefaultConsistencyLevel = 'Eventual',
    [Parameter()][switch] $CosmosDbEnableAutomaticFailover,

    [Parameter()][string] $CosmosDbKeyvaultKeyUri,

    [Parameter()][switch] $CosmosDbEnableMultipleWriteCosmosDbLocations,
    [Parameter()][System.Object[]] $CosmosDbLocations,

    # BOUNDED STALENESS
    [Parameter()][ValidateRange(1, 100)][int] $CosmosDbMaxStalenessInterval,
    [Parameter()][ValidateRange(1, 2147483647)][int] $CosmosDbMaxStalenessPrefix,

    [Parameter()][ValidateSet('3.2', '3.6', '4.0', '4.2')][string] $CosmosMongoDbServerVersion,

    # Private Endpoints
    [Parameter()][string] $CosmosDbPrivateEndpointVnetName,
    [Parameter()][string] $CosmosDbPrivateEndpointVnetResourceGroupName,
    [Parameter()][string] $CosmosDbPrivateEndpointSubnetName,
    [Parameter()][ValidateSet('Sql', 'Cassandra', 'MongoDB', 'Gremlin', 'Table')][string] $CosmosDbPrivateEndpointGroupId,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Parameter()][string] $CosmosDbAccountPrivateDnsZoneName,
    [Parameter()][bool] $SkipDnsZoneConfiguration = $false,

    # VNet Whitelisting
    [Parameter()][string] $ApplicationVnetResourceGroupName,
    [Parameter()][string] $ApplicationVnetName,
    [Parameter()][string] $ApplicationSubnetName,

    # Forcefully agree to this resource to be spun up to be publicly available
    [Parameter()][switch] $ForcePublic,

    [Parameter()][System.Object[]] $ResourceTags,
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    
    # Diagnostic settings
    [Parameter()][System.Object[]] $DiagnosticSettingsLogs,
    [Parameter()][System.Object[]] $DiagnosticSettingsMetrics,

    # Disable diagnostic settings
    [Parameter()][switch] $DiagnosticSettingsDisabled
)

##################################################################################################################
# Azure Cosmos account API type   Supported sub-resources (or group IDs)   Private zone name
# Sql	                          Sql	                                   privatelink.documents.azure.com
# Cassandra	                      Cassandra	                               privatelink.cassandra.cosmos.azure.com
# Mongo	                          MongoDB	                               privatelink.mongo.cosmos.azure.com
# Gremlin	                      Gremlin	                               privatelink.gremlin.cosmos.azure.com
# Gremlin	                      Sql	                                   privatelink.documents.azure.com
# Table	                          Table	                                   privatelink.table.cosmos.azure.com
# Table	                          Sql	                                   privatelink.documents.azure.com
##################################################################################################################

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# CosmosDb account can only take lowercase characters
$CosmosDBAccountName = $CosmosDBAccountName.ToLower()

$optionalParameters = @()
$capabilities = @()

if ((!$ApplicationVnetResourceGroupName -or !$ApplicationVnetName -or !$ApplicationSubnetName) -and (!$CosmosDbPrivateEndpointVnetName -or !$CosmosDbPrivateEndpointVnetResourceGroupName -or !$CosmosDbPrivateEndpointSubnetName -or !$DNSZoneResourceGroupName -or !$CosmosDbAccountPrivateDnsZoneName))
{
    # Check if we are making this resource public intentionally
    Assert-IntentionallyCreatedPublicResource -ForcePublic $ForcePublic
}

####################################### PUBLIC #########################################

if ($ForcePublic)
{
    $optionalParameters += '--enable-public-network', 'true'
}

####################################### CONSISTENCY LEVELS #########################################

if ($CosmosDbDefaultConsistencyLevel -eq 'BoundedStaleness')
{
    # Bounded staleness > time amount
    if ($CosmosDbMaxStalenessInterval)
    {
        $optionalParameters += '--max-interval', "$CosmosDbMaxStalenessInterval"
    }

    # Bounded staleness > stale requests tolerated
    if ($CosmosDbMaxStalenessPrefix)
    {
        $optionalParameters += '--max-staleness-prefix', "$CosmosDbMaxStalenessPrefix"
    }
}

####################################### KIND #########################################
switch ($CosmosDbKind)
{
    'SQL'
    {
        $CosmosDbKind = 'GlobalDocumentDB'
    }
    'MongoDB'
    {
        if ($CosmosMongoDbServerVersion)
        {
            $optionalParameters += '--server-version', "$CosmosMongoDbServerVersion"
        }
    }
    'Cassandra'
    {
        $CosmosDbKind = 'GlobalDocumentDB'
        $capabilities += 'EnableCassandra'
        $optionalParameters += '--capabilities', 'EnableCassandra'
    }
    'Table'
    {
        $CosmosDbKind = 'GlobalDocumentDB'
        $capabilities += 'EnableTable'
        $optionalParameters += '--capabilities', 'EnableTable'
    }
    'Gremlin'
    {
        $CosmosDbKind = 'GlobalDocumentDB'
        $capabilities += 'EnableGremlin'
        $optionalParameters += '--capabilities', 'EnableGremlin'
    }
}

####################################### BACKUP #########################################

if ($CosmosDbBackupInterval)
{
    $optionalParameters += '--backup-interval', "$CosmosDbBackupIntervalInMinutes"
}

if ($CosmosDbBackupRetention)
{
    $optionalParameters += '--backup-retention', "$CosmosDbBackupRetentionInHours"
}

if ($CosmosDbEnableAutomaticFailover)
{
    $optionalParameters += '--enable-automatic-failover', 'true'
}

####################################### KEYVAULT #########################################

if ($CosmosDbKeyvaultKeyUri)
{
    $optionalParameters += '--key-uri', "$CosmosDbKeyvaultKeyUri"
}

####################################### LOCATION #########################################

if ($CosmosDbEnableMultipleWriteCosmosDbLocations)
{
    $optionalParameters += '--enable-multiple-write-locations', 'true'
}

if ($CosmosDbLocations)
{
    foreach ($cosmosDbLocation in $CosmosDbLocations)
    {
        Write-Host "regionName=$($cosmosDbLocation.regionName) failoverPriority=$($cosmosDbLocation.failoverPriority) isZoneRedundant=$($cosmosDbLocation.isZoneRedundant)"
        if (!$cosmosDbLocation.regionName -or $null -eq $cosmosDbLocation.failoverPriority -or $null -eq $cosmosDbLocation.failoverPriority)
        {
            Write-Warning 'Malformed region found. Please make sure regionName, failoverPriority & isZoneRedundant parameters are present. Please review the documentation on the Wiki.'
            continue
        }
        Write-Host "regionName=$($cosmosDbLocation.regionName) failoverPriority=$($cosmosDbLocation.failoverPriority) isZoneRedundant=$($cosmosDbLocation.isZoneRedundant)"
        $optionalParameters += '--locations', "regionName=$($cosmosDbLocation.regionName)", "failoverPriority=$($cosmosDbLocation.failoverPriority)", "isZoneRedundant=$($cosmosDbLocation.isZoneRedundant)"
    }
}

####################################### CUSTOM CAPABILITIES #########################################
if ($CosmosDbCapabilities)
{
    # Set custom capabilities on the Cosmos DB database account.Set custom capabilities on the Cosmos DB database account.
    $capabilities += $CosmosDbCapabilities
    $optionalParameters += '--capabilities', $capabilities
}

####################################### VNET WHITELISTING #########################################

if ($ApplicationVnetResourceGroupName -and $ApplicationVnetName -and $ApplicationSubnetName)
{
    $optionalParameters += '--enable-virtual-network', 'true'
}

####################################### CREATION #########################################

if (Invoke-Executable -AllowToFail az cosmosdb show --name $CosmosDbAccountName --resource-group $CosmosDbAccountResourceGroupName)
{
    Write-Host 'CosmosDB already found. Updating...'
    Invoke-Executable az cosmosdb update --name $CosmosDbAccountName --resource-group $CosmosDbAccountResourceGroupName --default-consistency-level $CosmosDbDefaultConsistencyLevel @optionalParameters
}
else
{
    Write-Host 'CosmosDB not found. Creating...'
    Invoke-Executable az cosmosdb create --name $CosmosDbAccountName --resource-group $CosmosDbAccountResourceGroupName --kind $CosmosDbKind --default-consistency-level $CosmosDbDefaultConsistencyLevel @optionalParameters
}

# Fetch the resource id for the just created CosmosDB Account
$cosmosResource = ((Invoke-Executable az cosmosdb show --name $CosmosDbAccountName --resource-group $CosmosDbAccountResourceGroupName) | ConvertFrom-Json)

####################################### TAGS #########################################

if ($ResourceTags)
{
    Set-ResourceTagsForResource -ResourceId $cosmosResource.id -ResourceTags ${ResourceTags}
}

####################################### BACKUP STORAGE REDUNDANCY #######################################
if ($CosmosDbBackupStorageRedundancy)
{
    Wait-ForClusterToBeReady -CosmosDBAccountName $CosmosDBAccountName -CosmosDBAccountResourceGroupName $CosmosDBAccountResourceGroupName

    $body = @{
        properties = @{
            backupPolicy = @{
                periodicModeProperties = @{
                    backupStorageRedundancy = $CosmosDbBackupStorageRedundancy
                }
            }
        }
    }

    Invoke-AzRestCall -Method PATCH -ResourceId $cosmosResource.id -ApiVersion '2021-04-15' -Body $body
}
####################################### NETWORKING #########################################

if ($ApplicationVnetResourceGroupName -and $ApplicationVnetName -and $ApplicationSubnetName)
{
    Write-Host 'VNET Whitelisting is desired. Adding the needed components.'

    # Whitelist VNET
    & "$PSScriptRoot\Add-Network-Whitelist-to-CosmosDb-Account.ps1" -CosmosDBAccountResourceGroupName $CosmosDBAccountResourceGroupName -CosmosDBAccountName $CosmosDBAccountName -SubnetToWhitelistSubnetName $ApplicationSubnetName -SubnetToWhitelistVnetName $ApplicationVnetName -SubnetToWhitelistVnetResourceGroupName $ApplicationVnetResourceGroupName
}

if ($CosmosDbPrivateEndpointVnetResourceGroupName -and $CosmosDbPrivateEndpointVnetName -and $CosmosDbPrivateEndpointSubnetName -and $DNSZoneResourceGroupName -and $CosmosDbAccountPrivateDnsZoneName -and $CosmosDbPrivateEndpointGroupId)
{
    Write-Host 'A private endpoint is desired. Adding the needed components.'
    # Fetch needed information
    $vnetId = (Invoke-Executable az network vnet show --resource-group $CosmosDbPrivateEndpointVnetResourceGroupName --name $CosmosDbPrivateEndpointVnetName | ConvertFrom-Json).id
    $cosmosDbPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $CosmosDbPrivateEndpointVnetResourceGroupName --name $CosmosDbPrivateEndpointSubnetName --vnet-name $CosmosDbPrivateEndpointVnetName | ConvertFrom-Json).id
    $CosmosDbPrivateEndpointName = "$($CosmosDbAccountName)-pvtcms"

    # Add Private endpoint
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $cosmosDbPrivateEndpointSubnetId -PrivateEndpointName $CosmosDbPrivateEndpointName -PrivateEndpointResourceGroupName $CosmosDbAccountResourceGroupName -TargetResourceId $cosmosResource.id -PrivateEndpointGroupId $CosmosDbPrivateEndpointGroupId -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $CosmosDbAccountPrivateDnsZoneName -PrivateDnsLinkName "$($CosmosDbPrivateEndpointVnetName)-cms" -SkipDnsZoneConfiguration $SkipDnsZoneConfiguration
}

####################################### DIAGNOSTIC SETTINGS #########################################
if ($DiagnosticSettingsDisabled)
{
    Remove-DiagnosticSetting -ResourceId $cosmosResource.id -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $CosmosDbAccountName
}
else
{
    Set-DiagnosticSettings -ResourceId $cosmosResource.id -ResourceName $CosmosDbAccountName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -DiagnosticSettingsLogs:$DiagnosticSettingsLogs -DiagnosticSettingsMetrics:$DiagnosticSettingsMetrics 
}

####################################### CAPABILITIES #########################################
if ($CosmosDbCapabilities)
{
    Write-Host 'Adding extra capabilities to the CosmosDb account'
    
    Wait-ForClusterToBeReady -CosmosDBAccountName $CosmosDBAccountName -CosmosDBAccountResourceGroupName $CosmosDBAccountResourceGroupName

    Invoke-Executable az cosmosdb update --name $CosmosDbAccountName --resource-group $CosmosDBAccountResourceGroupName --capabilities @capabilities
}

Write-Footer -ScopedPSCmdlet $PSCmdlet