[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Parameter(Mandatory)][string] $SqlServerName,
    [Parameter(Mandatory)][string] $SqlDatabaseName,
    [Parameter()][string] $SqlDatabaseSkuName,
    [Parameter()][ValidateSet('', 'Basic', 'Standard', 'Premium', 'GeneralPurpose', 'BusinessCritical', 'Hyperscale')][string] $SqlDatabaseEdition,
    [Parameter()][ValidateSet('', 'Gen4', 'Gen5')][string] $SqlDatabaseFamily,
    [Parameter()][ValidateSet('', 'Provisioned', 'Serverless')][string] $SqlDatabaseComputeModel,
    [Parameter()][int] $SqlDatabaseAutoPauseDelayInMinutes,
    [Parameter()][int] $SqlDatabaseMinCapacity,
    [Parameter()][int] $SqlDatabaseMaxCapacity,
    [Parameter()][ValidateSet('', 'Local', 'Zone', 'Geo')][string] $SqlDatabaseBackupStorageRedundancy,
    [Parameter()][string] $SqlDatabaseMaxStorageSize,
    [Parameter(Mandatory)][System.Object[]] $ResourceTags
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$additionalParameters = @()
if ($SqlDatabaseSkuName) {
    $additionalParameters += '--service-objective', $SqlDatabaseSkuName
}
if ($SqlDatabaseEdition) {
    $additionalParameters += '--edition', $SqlDatabaseEdition
}
if ($SqlDatabaseFamily) {
    $additionalParameters += '--family', $SqlDatabaseFamily
}
if ($SqlDatabaseComputeModel) {
    $additionalParameters += '--compute-model', $SqlDatabaseComputeModel
}
if ($SqlDatabaseAutoPauseDelayInMinutes) {
    $additionalParameters += '--auto-pause-delay', $SqlDatabaseAutoPauseDelayInMinutes
}
if ($SqlDatabaseMinCapacity) {
    $additionalParameters += '--min-capacity', $SqlDatabaseMinCapacity
}
if ($SqlDatabaseMaxCapacity) {
    $additionalParameters += '--capacity', $SqlDatabaseMaxCapacity
}
if ($SqlDatabaseBackupStorageRedundancy) {
    $additionalParameters += '--backup-storage-redundancy', $SqlDatabaseBackupStorageRedundancy
}
if ($SqlDatabaseMaxStorageSize) {
    $additionalParameters += '--max-size', $SqlDatabaseMaxStorageSize
}

Invoke-Executable az sql db create --name $SqlDatabaseName --resource-group $SqlServerResourceGroupName --server $SqlServerName --tags ${ResourceTags} @additionalParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet