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

$response  = Invoke-WebRequest 'https://ipinfo.io/ip'
$ip = $response.Content.Trim()

$sqlServerLowerCase = $SqlServerName.ToLower()
Write-Output $sqlServerLowerCase

Invoke-Executable az sql server firewall-rule create --resource-group $SqlServerResourceGroupName --server $sqlServerLowerCase --name 'TMPAGENT' --start-ip-address $ip --end-ip-address $ip

Write-Footer