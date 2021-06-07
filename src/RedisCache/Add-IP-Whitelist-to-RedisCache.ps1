[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $RedisInstanceName,
    [Parameter(Mandatory)][string] $RedisInstanceResourceGroupName,
    [Parameter()][string] $AccessRuleName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Autogenerate CIDR if no CIDR is passed
if (!$CIDRToWhitelist)
{
    $response = Invoke-WebRequest 'https://ipinfo.io/ip'
    $CIDRToWhitelist = $response.Content.Trim() + '/32'
}

# Autogenerate name if no name is given
if (!$AccessRuleName)
{
    $AccessRuleName = ($CIDRToWhitelist -replace "\.", "_") -replace "/", "_"
}

$startIpAddress = Get-StartIpInIpv4Network -SubnetCidr $CIDRToWhitelist
$endIpAddress = Get-EndIpInIpv4Network -SubnetCidr $CIDRToWhitelist

$firewallRules = ((Invoke-Executable az redis firewall-rules list --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName) | ConvertFrom-Json) | Where-Object { $_.startIp -eq $startIpAddress -and $_.endIp -eq $endIpAddress -and $_.name -notlike "*/$AccessRuleName" }
if($firewallRules.Length -gt 0)
{
    throw "This CIDR already exists with a different name. Please correct this."
}

Invoke-Executable az redis firewall-rules create --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName --rule-name $AccessRuleName --start-ip $startIpAddress --end-ip $endIpAddress

Write-Footer -ScopedPSCmdlet $PSCmdlet