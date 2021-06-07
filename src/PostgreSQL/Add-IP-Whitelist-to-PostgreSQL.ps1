[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $PostgreSqlServerName,
    [Parameter(Mandatory)][string] $PostgreSqlServerResourceGroupName,
    [Parameter()][string] $AccessRuleName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist,
    [Parameter()][string] $SubnetName,
    [Parameter()][string] $VnetName,
    [Parameter()][string] $VnetResourceGroupName
)

# TODO > AANPASSEN GEEN DUBBELE CIDR EN/OF SUBNETS MET EEN ANDERE NAAM ALLOWEN

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Confirm if the correct parameters are passed
Confirm-ParametersForWhitelist -CIDR:$CIDRToWhitelist -SubnetName:$SubnetName -VnetName:$VnetName -VnetResourceGroupName:$VnetResourceGroupName

# Autogenerate CIDR if no CIDR or Subnet is passed
$CIDRToWhiteList = New-CIDR -CIDR:$CIDRToWhitelist -CIDRSuffix '/32' -SubnetName:$SubnetName -VnetName:$VnetName -VnetResourceGroupName:$VnetResourceGroupName 

# Autogenerate name if no name is given
$AccessRuleName = New-AccessRestrictionRuleName -AccessRestrictionRuleName:$AccessRuleName -CIDR:$CIDRToWhitelist -SubnetName:$SubnetName -VnetName:$VnetName -VnetResourceGroupName:$VnetResourceGroupName

# Fetch Subnet ID when subnet option is given.
if ($SubnetName -and $VnetName -and $VnetResourceGroupName)
{
    $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $VnetResourceGroupName --name $SubnetName --vnet-name $VnetName | ConvertFrom-Json).id
}

if (!$subnetResourceId)
{
    # Preparation
    $startIpAddress = Get-StartIpInIpv4Network -SubnetCidr $CIDRToWhitelist
    $endIpAddress = Get-EndIpInIpv4Network -SubnetCidr $CIDRToWhitelist

    $firewallRules = ((Invoke-Executable az postgres server firewall-rule list --server-name $PostgreSqlServerName --resource-group $PostgreSqlServerResourceGroupName) | ConvertFrom-Json) | Where-Object { $_.startIp -eq $startIpAddress -and $_.endIp -eq $endIpAddress -and $_.name -notlike "*/$AccessRuleName" }
    if ($firewallRules.Length -gt 0)
    {
        throw "This CIDR already exists with a different name. Please correct this."
    }

    # Execute whitelist
    Invoke-Executable az postgres server firewall-rule create --resource-group $PostgreSqlServerResourceGroupName --server-name $PostgreSqlServerName --name $AccessRuleName --start-ip-address $startIpAddress --end-ip-address $endIpAddress
}
else
{
    $vnetRules = ((Invoke-Executable az postgres server vnet-rule list --server-name $PostgreSqlServerName --resource-group $PostgreSqlServerResourceGroupName) | ConvertFrom-Json) | Where-Object { $_.virtualNetworkSubnetId -eq $subnetResourceId -and $_.name -notlike "*/$AccessRuleName" }
    if ($vnetRules.Length -gt 0)
    {
        throw "This subnet already exists with a different name. Please correct this."
    }

    # Add subnet rule
    Invoke-Executable az postgres server vnet-rule create --resource-group $PostgreSqlServerResourceGroupName --server-name $PostgreSqlServerName --name $AccessRuleName --subnet $subnetResourceId
}

Write-Footer -ScopedPSCmdlet $PSCmdlet