[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SqlServerName,
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Parameter()][string] $AccessRuleName,
    [Parameter()][string] $CIDRToWhitelist
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if(!$CIDRToWhitelist)
{
    $response  = Invoke-WebRequest 'https://ipinfo.io/ip'
    $CIDRToWhitelist = $response.Content.Trim()
    $CIDRToWhitelist += '/32'
}

# Preparation
$sqlServerLowerCase = $SqlServerName.ToLower()
$startIpAddress = Get-StartIpInIpv4Network -SubnetCidr $CIDRToWhitelist
$endIpAddress = Get-EndIpInIpv4Network -SubnetCidr $CIDRToWhitelist

if(!$AccessRuleName)
{
    $AccessRuleName = ($CIDRToWhitelist -replace "\.", "-") -replace "/", "-"
}

# Execute whitelist
Invoke-Executable az sql server firewall-rule create --resource-group $SqlServerResourceGroupName --server $sqlServerLowerCase --name $AccessRuleName --start-ip-address $startIpAddress --end-ip-address $endIpAddress

Write-Footer -ScopedPSCmdlet $PSCmdlet