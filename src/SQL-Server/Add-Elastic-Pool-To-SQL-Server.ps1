[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ElasticPoolName,
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Parameter(Mandatory)][string] $SqlServerName,
    [Parameter()][ValidateSet('', 'Basic', 'Standard', 'Premium', 'GeneralPurpose', 'BusinessCritical')][string] $ElasticPoolEdition,
    [Parameter()][string] $ElasticPoolCapacity,
    [Parameter()][string] $ElasticPoolMaxCapacityPerDatabase,
    [Parameter()][string] $ElasticPoolMinCapacityPerDatabase,
    [Parameter()][string][ValidateSet('', 'Gen4', 'Gen5')] $ElasticPoolVCoreFamily,
    [Parameter()][string] $ElasticPoolMaxStorageSize,
    [Parameter()][string][ValidateSet('', 'false', 'true')] $ElasticPoolZoneRedundancy,
    [Parameter()][System.Object[]] $ResourceTags, 
    
    # Diagnostic Settings
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    [Parameter()][System.Object[]] $DiagnosticSettingsLogs,
    [Parameter()][System.Object[]] $DiagnosticSettingsMetrics,
    
    # Disable diagnostic settings
    [Parameter()][switch] $DiagnosticSettingsDisabled
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$additionalParameters = @()
if ($ElasticPoolCapacity)
{
    $additionalParameters += '--capacity', $ElasticPoolCapacity
}
if ($ElasticPoolMaxCapacityPerDatabase)
{
    $additionalParameters += '--db-max-capacity', $ElasticPoolMaxCapacityPerDatabase
}
if ($ElasticPoolMinCapacityPerDatabase)
{
    $additionalParameters += '--db-min-capacity', $ElasticPoolMinCapacityPerDatabase
}
if ($ElasticPoolEdition)
{
    $additionalParameters += '--edition', $ElasticPoolEdition
}
if ($ElasticPoolVCoreFamily)
{
    $additionalParameters += '--family', $ElasticPoolVCoreFamily
}
if ($ElasitcPoolMaxStorageSize)
{
    $additionalParameters += '--max-size', $ElasticPoolMaxStorageSize
}
if ($ElasticPoolZoneRedundancy)
{
    $additionalParameters += '--zone-redundant', $ElasticPoolZoneRedundancy
}

# Create Elastic Pool
$elasticPoolId = (Invoke-Executable az sql elastic-pool create --name $ElasticPoolName --resource-group $SqlServerResourceGroupName --server $SqlServerName @additionalParameters | ConvertFrom-Json).id

# Add ResourceTags
if ($ResourceTags)
{
    Set-ResourceTagsForResource -ResourceId $elasticPoolId -ResourceTags ${ResourceTags}
}

# Add diagnostic settings to Elastic Pool
if ($DiagnosticSettingsDisabled)
{
    Remove-DiagnosticSetting -ResourceId $elasticPoolId -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $ElasticPoolName
}
else
{
    Set-DiagnosticSettings -ResourceId $elasticPoolId -ResourceName $ElasticPoolName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -DiagnosticSettingsLogs:$DiagnosticSettingsLogs -DiagnosticSettingsMetrics:$DiagnosticSettingsMetrics 
}

Write-Footer -ScopedPSCmdlet $PSCmdlet