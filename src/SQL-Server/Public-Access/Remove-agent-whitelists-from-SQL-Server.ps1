[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Parameter(Mandatory)][string] $SqlServerName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az sql server firewall-rule delete --resource-group $SqlServerResourceGroupName --server $SqlServerName --name 'TMPAGENT'

Write-Footer -ScopedPSCmdlet $PSCmdlet