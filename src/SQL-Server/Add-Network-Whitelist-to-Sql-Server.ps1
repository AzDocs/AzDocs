[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SqlServerName,
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Parameter()][string] $AccessRuleName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist,
    [Parameter()][string] $SubnetToWhitelistSubnetName,
    [Parameter()][string] $SubnetToWhitelistVnetName,
    [Parameter()][string] $SubnetToWhitelistVnetResourceGroupName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$sqlServerLowerCase = $SqlServerName.ToLower()

# Confirm if the correct parameters are passed
Confirm-ParametersForWhitelist -CIDR:$CIDRToWhitelist -SubnetName:$SubnetToWhitelistSubnetName -VnetName:$SubnetToWhitelistVnetName -VnetResourceGroupName:$SubnetToWhitelistVnetResourceGroupName

# Autogenerate CIDR if no CIDR or Subnet is passed
$CIDRToWhiteList = Get-CIDRForWhitelist -CIDR:$CIDRToWhitelist -CIDRSuffix '/32' -SubnetName:$SubnetToWhitelistSubnetName -VnetName:$SubnetToWhitelistVnetName -VnetResourceGroupName:$SubnetToWhitelistVnetResourceGroupName 
$CIDRToWhitelist = Confirm-CIDRForWhitelist -ServiceType 'sql' -CIDR:$CIDRToWhitelist

# Autogenerate name if no name is given
$AccessRuleName = Get-AccessRestrictionRuleName -AccessRestrictionRuleName:$AccessRuleName -CIDR:$CIDRToWhitelist -SubnetName:$SubnetToWhitelistSubnetName -VnetName:$SubnetToWhitelistVnetName -VnetResourceGroupName:$SubnetToWhitelistVnetResourceGroupName

# Fetch Subnet ID when subnet option is given.
if ($SubnetToWhitelistSubnetName -and $SubnetToWhitelistVnetName -and $SubnetToWhitelistVnetResourceGroupName)
{
    $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $SubnetToWhitelistVnetResourceGroupName --name $SubnetToWhitelistSubnetName --vnet-name $SubnetToWhitelistVnetName | ConvertFrom-Json).id

    # Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
    Set-SubnetServiceEndpoint -SubnetResourceId $subnetResourceId -ServiceEndpointServiceIdentifier "Microsoft.Sql"
}

if (!$subnetResourceId)
{
    # Preparation
    $startIpAddress = Get-StartIpInIpv4Network -SubnetCidr $CIDRToWhitelist
    $endIpAddress = Get-EndIpInIpv4Network -SubnetCidr $CIDRToWhitelist

    $firewallRules = ((Invoke-Executable az sql server firewall-rule list --server $sqlServerLowerCase --resource-group $SqlServerResourceGroupName) | ConvertFrom-Json) | Where-Object { $_.startIp -eq $startIpAddress -and $_.endIp -eq $endIpAddress -and $_.name -notlike "*$AccessRuleName" }
    if ($firewallRules.Length -gt 0)
    {
        Write-Warning "This CIDR already exists with a different name. Please correct this."
        return
    }

    # Execute whitelist
    Invoke-Executable az sql server firewall-rule create --resource-group $SqlServerResourceGroupName --server $sqlServerLowerCase --name $AccessRuleName --start-ip-address $startIpAddress --end-ip-address $endIpAddress
}
else
{
    $vnetRules = ((Invoke-Executable az sql server vnet-rule list --resource-group $SqlServerResourceGroupName --server $sqlServerLowerCase ) | ConvertFrom-Json) | Where-Object { $_.virtualNetworkSubnetId -eq $subnetResourceId -and $_.name -notlike "*$AccessRuleName" }
    if ($vnetRules.Length -gt 0)
    {
        Write-Warning "This subnet already exists with a different name. Please correct this."
        return
    }

    # Add subnet rule
    Invoke-Executable az sql server vnet-rule create --resource-group $SqlServerResourceGroupName --server $sqlServerLowerCase --name $AccessRuleName --subnet $subnetResourceId
}

Write-Footer -ScopedPSCmdlet $PSCmdlet