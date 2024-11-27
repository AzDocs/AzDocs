[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $MySqlServerResourceGroupName,
    [Parameter(Mandatory)][string] $MySqlServerName,
    [Parameter(Mandatory)][string] $MySqlServerConfigName,
    [Parameter()][string] $MySqlServerConfigValue
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$optionalParameters = @()
if ($MySqlServerConfigValue)
{
    $optionalParameters += '--value', "$MySqlServerConfigValue"
}

Invoke-Executable az mysql server configuration set --resource-group $MySqlServerResourceGroupName --server $MySqlServerName --name $MySqlServerConfigName @optionalParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet