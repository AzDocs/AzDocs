[CmdletBinding()]
param (
    [Parameter()]
    [String] $sqlServerResourceGroupName,

    [Parameter()]
    [String] $sqlServerName,

    [Parameter()]
    [String] $sqlDatabaseName,

    [Parameter()]
    [String] $sqlDatabaseSkuName,

    [Parameter()]
    [System.Object[]] $resourceTags
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az sql db create --name $sqlDatabaseName --resource-group $sqlServerResourceGroupName --server $sqlServerName --service-objective $sqlDatabaseSkuName --tags ${resourceTags}

Write-Footer