[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $PostgreSqlServerName,
    [Parameter(Mandatory)][string] $PostgreSqlServerResourceGroupName,
    [Parameter()][string] $AccessRuleName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})\/(?:\d{1,2})$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if(!$CIDRToWhitelist)
{
    $response  = Invoke-WebRequest 'https://ipinfo.io/ip'
    $CIDRToWhitelist = $response.Content.Trim() + '/32'
}

# Preparation
$startIpAddress = Get-StartIpInIpv4Network -SubnetCidr $CIDRToWhitelist
$endIpAddress = Get-EndIpInIpv4Network -SubnetCidr $CIDRToWhitelist

if(!$AccessRuleName)
{
    $AccessRuleName = ($CIDRToWhitelist -replace "\.", "-") -replace "/", "-"
}

# Execute whitelist
Invoke-Executable az postgres server firewall-rule create --resource-group $PostgreSqlServerResourceGroupName --server-name $PostgreSqlServerName --name $AccessRuleName --start-ip-address $startIpAddress --end-ip-address $endIpAddress

Write-Footer -ScopedPSCmdlet $PSCmdlet