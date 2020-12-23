[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $sqlServerResourceGroupName,

    [Parameter(Mandatory)]
    [String] $sqlServerName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az sql server firewall-rule delete --resource-group $sqlServerResourceGroupName --server $sqlServerName --name 'TMPAGENT'

Write-Footer