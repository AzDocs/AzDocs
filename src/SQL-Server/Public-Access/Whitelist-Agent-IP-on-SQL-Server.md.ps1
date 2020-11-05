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

$response  = Invoke-WebRequest 'https://ipinfo.io/ip'
$ip = $response.Content.Trim()

$sqlserverlowercase = $sqlServerName.ToLower()
Write-Output $sqlserverlowercase

Invoke-Executable az sql server firewall-rule create --resource-group $sqlServerResourceGroupName --server $sqlserverlowercase --name 'TMPAGENT' --start-ip-address $ip --end-ip-address $ip
