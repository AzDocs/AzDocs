[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $RedisInstanceName,
    [Parameter(Mandatory)][string] $RedisInstanceResourceGroupName,
    [Parameter()][string] $AccessRuleName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToRemoveFromWhitelist
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if($AccessRuleName)
{
    Invoke-Executable az redis firewall-rules delete --rule-name $AccessRuleName --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName
}
else
{
    # Autogenerate CIDR if no CIDR or Subnet is passed
    if (!$CIDRToRemoveFromWhitelist)
    {
        $response = Invoke-WebRequest 'https://ipinfo.io/ip'
        $CIDRToRemoveFromWhitelist = $response.Content.Trim() + '/32'
    }

    $startIpAddress = Get-StartIpInIpv4Network -SubnetCidr $CIDRToRemoveFromWhitelist
    $endIpAddress = Get-EndIpInIpv4Network -SubnetCidr $CIDRToRemoveFromWhitelist

    $firewallRules = ((Invoke-Executable az redis firewall-rules list --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName) | ConvertFrom-Json) | Where-Object { $_.startIp -eq $startIpAddress -and $_.endIp -eq $endIpAddress }
    foreach($firewallRule in $firewallRules)
    {
        Invoke-Executable az redis firewall-rules delete --rule-name ($firewallRule.name -split '/')[1] --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet