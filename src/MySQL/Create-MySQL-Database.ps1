[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $MySqlServerResourceGroupName,
    [Parameter(Mandatory)][string] $MySqlServerName,
    [Parameter(Mandatory)][string] $MySqlDatabaseName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az mysql db create --name $MySqlDatabaseName --resource-group $MySqlServerResourceGroupName --server $MySqlServerName

Write-Footer -ScopedPSCmdlet $PSCmdlet