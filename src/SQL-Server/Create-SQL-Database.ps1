[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Parameter(Mandatory)][string] $SqlServerName,
    [Parameter(Mandatory)][string] $SqlDatabaseName,
    [Parameter(Mandatory)][string] $SqlDatabaseSkuName,
    [Parameter(Mandatory)][System.Object[]] $ResourceTags
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az sql db create --name $SqlDatabaseName --resource-group $SqlServerResourceGroupName --server $SqlServerName --service-objective $SqlDatabaseSkuName --tags ${ResourceTags}

Write-Footer