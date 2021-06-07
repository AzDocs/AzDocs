[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $MySqlServerName,
    [Parameter(Mandatory)][string] $MySqlServerResourceGroupName,
    [Parameter()][string] $AccessRuleName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToRemoveFromWhitelist,
    [Parameter()][string] $SubnetName,
    [Parameter()][string] $VnetName,
    [Parameter()][string] $VnetResourceGroupName
)

# TODO: REMOVE => MySQL klapt op het moment dat de rules niet existen maar wel worden gedelete.
# TODO: REMOVE => Sinds MySQL op AccessRuleName als identifier werkt, kan het zo zijn dat er op CIDR / Subnet meerdere firewallrules/vnet rules teruggegeven worden.

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Confirm if the correct parameters are passed
Confirm-ParametersForWhitelist -CIDR:$CIDRToRemoveFromWhitelist -SubnetName:$SubnetName -VnetName:$VnetName -VnetResourceGroupName:$VnetResourceGroupName

# Autogenerate CIDR if no CIDR or Subnet is passed
if (!$AccessRuleName)
{
    $CIDRToRemoveFromWhitelist = New-CIDR -CIDR:$CIDRToRemoveFromWhitelist -CIDRSuffix '/32' -SubnetName:$SubnetName -VnetName:$VnetName -VnetResourceGroupName:$VnetResourceGroupName 
}

# Fetch Subnet ID when subnet option is given.
if ($SubnetName -and $VnetName -and $VnetResourceGroupName)
{
    $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $VnetResourceGroupName --name $SubnetName --vnet-name $VnetName | ConvertFrom-Json).id
}

if (!$subnetResourceId)
{
    Remove-FirewallRulesIfExists -ServiceType 'mysql' -ResourceGroupName $MySqlServerResourceGroupName -ResourceName $MySqlServerName -AccessRuleName:$AccessRuleName -CIDR:$CIDRToRemoveFromWhitelist
}
else
{
    Remove-VnetRulesIfExists -ServiceType 'mysql' -ResourceGroupName $MySqlServerResourceGroupName -ResourceName $MySqlServerName -AccessRuleName:$AccessRuleName -SubnetResourceId:$subnetResourceId
}

Write-Footer -ScopedPSCmdlet $PSCmdlet