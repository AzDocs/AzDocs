[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $sqlServerResourceGroupName,

    [Parameter(Mandatory)]
    [String] $sqlServerName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Invoke-Executable az sql server firewall-rule delete --resource-group $sqlServerResourceGroupName --server $sqlServerName --name 'TMPAGENT'