[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Parameter(Mandatory)][string] $SqlServerName,
    [Parameter(Mandatory)][string] $SqlDatabaseName,
    [Parameter(Mandatory)][string] $SqlDatabaseSkuName,
    [Parameter(Mandatory)][System.Object[]] $ResourceTags
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az sql db create --name $SqlDatabaseName --resource-group $SqlServerResourceGroupName --server $SqlServerName --service-objective $SqlDatabaseSkuName --tags ${ResourceTags}

Write-Footer -ScopedPSCmdlet $PSCmdlet