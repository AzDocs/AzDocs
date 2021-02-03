[CmdletBinding()]
param (
    [Alias("SqlServerResourceGroupName")]
    [Parameter(Mandatory)][string] $PostgreSqlServerResourceGroupName,
    [Alias("SqlServerName")]
    [Parameter(Mandatory)][string] $PostgreSqlServerName,
    [Alias("SqlDatabaseName")]
    [Parameter(Mandatory)][string] $PostgreSqlDatabaseName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az postgres db create --name $PostgreSqlDatabaseName --resource-group $PostgreSqlServerResourceGroupName --server $PostgreSqlServerName

Write-Footer