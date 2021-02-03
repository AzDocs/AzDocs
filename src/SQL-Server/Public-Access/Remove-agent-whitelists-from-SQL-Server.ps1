[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Parameter(Mandatory)][string] $SqlServerName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az sql server firewall-rule delete --resource-group $SqlServerResourceGroupName --server $SqlServerName --name 'TMPAGENT'

Write-Footer