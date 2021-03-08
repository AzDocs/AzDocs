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
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az postgres db create --name $PostgreSqlDatabaseName --resource-group $PostgreSqlServerResourceGroupName --server $PostgreSqlServerName

Write-Footer -ScopedPSCmdlet $PSCmdlet