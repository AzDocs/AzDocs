[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ServiceBusNamespaceName,
    [Parameter(Mandatory)][string] $ServiceBusNamespaceResourceGroupName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToRemove,
    [Parameter()][string] $SubnetToRemoveSubnetName,
    [Parameter()][string] $SubnetToRemoveVnetName,
    [Parameter()][string] $SubnetToRemoveVnetResourceGroupName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Get ServiceBus SKU. Can only be set for Premium tier.
$serviceBusSku = (Invoke-Executable az servicebus namespace show --name $ServiceBusNamespaceName --resource-group $ServiceBusNamespaceResourceGroupName | ConvertFrom-Json).sku.tier

if ($serviceBusSku -ne 'Premium')
{
    throw "Network Whitelist only possible for Premium ServiceBus SKU. Current SKU: $serviceBusSku"
}

# Confirm if the correct parameters are passed
Confirm-ParametersForWhitelist -CIDR:$CIDRToRemove -SubnetName:$SubnetToRemoveSubnetName -VnetName:$SubnetToRemoveVnetName -VnetResourceGroupName:$SubnetToRemoveVnetResourceGroupName
    
# Fetch Subnet ID when subnet option is given.
if ($SubnetToRemoveSubnetName -and $SubnetToRemoveVnetName -and $SubnetToRemoveVnetResourceGroupName)
{
    $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $SubnetToRemoveVnetResourceGroupName --name $SubnetToRemoveSubnetName --vnet-name $SubnetToRemoveVnetName | ConvertFrom-Json).id
}
else
{
    # Autogenerate CIDR if no CIDR is passed
    $CIDRToRemove = Get-CIDRForWhitelist -CIDR:$CIDRToRemove
}
    
$optionalParameters = @()
if ($CIDRToRemove)
{
    $optionalParameters += "--ip-address", "$CIDRToRemove"
}
elseif ($subnetResourceId)
{
    $optionalParameters += "--subnet", "$subnetResourceId"
}
    
# Add network rule to the ServiceBus Namespace
Invoke-Executable az servicebus namespace network-rule remove --name $ServiceBusNamespaceName --resource-group $ServiceBusNamespaceResourceGroupName @optionalParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet