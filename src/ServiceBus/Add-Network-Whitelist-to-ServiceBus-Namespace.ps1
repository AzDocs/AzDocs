[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ServiceBusNamespaceName,
    [Parameter(Mandatory)][string] $ServiceBusNamespaceResourceGroupName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist,
    [Parameter()][string] $SubnetToWhitelistSubnetName,
    [Parameter()][string] $SubnetToWhitelistVnetName,
    [Parameter()][string] $SubnetToWhitelistVnetResourceGroupName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Get ServiceBus SKU. Can only be set for Premium tier.
$ServiceBusSku = (Invoke-Executable az servicebus namespace show --name $ServiceBusNamespaceName --resource-group $ServiceBusNamespaceResourceGroupName | ConvertFrom-Json).sku.tier

if ($ServiceBusSku -eq 'Premium')
{
    # Confirm if the correct parameters are passed
    Confirm-ParametersForWhitelist -CIDR:$CIDRToWhitelist -SubnetName:$SubnetToWhitelistSubnetName -VnetName:$SubnetToWhitelistVnetName -VnetResourceGroupName:$SubnetToWhitelistVnetResourceGroupName
    
    # Autogenerate CIDR if no CIDR or Subnet is passed
    
    $CIDRToWhitelist = Get-CIDRForWhitelist -CIDR:$CIDRToWhitelist -CIDRSuffix '/32' -SubnetName:$SubnetToWhitelistSubnetName -VnetName:$SubnetToWhitelistVnetName -VnetResourceGroupName:$SubnetToWhitelistVnetResourceGroupName
    
    # Github issue for being able to add the same ip-addressess: https://github.com/Azure/azure-cli/issues/18479
    # Have to add suffix because of bug: 
    $CIDRToWhitelist = Confirm-CIDRForWhitelist -ServiceType 'servicebus' -CIDR:$CIDRToWhitelist
    
    # Fetch Subnet ID when subnet option is given.
    if ($SubnetToWhitelistSubnetName -and $SubnetToWhitelistVnetName -and $SubnetToWhitelistVnetResourceGroupName)
    {
        $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $SubnetToWhitelistVnetResourceGroupName --name $SubnetToWhitelistSubnetName --vnet-name $SubnetToWhitelistVnetName | ConvertFrom-Json).id
        
        # Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
        Set-SubnetServiceEndpoint -SubnetResourceId $subnetResourceId -ServiceEndpointServiceIdentifier "Microsoft.ServiceBus"
    }
    
    $optionalParameters = @()
    if ($CIDRToWhitelist)
    {
        $optionalParameters += "--ip-address", "$CIDRToWhitelist"
    }
    elseif ($subnetResourceId)
    {
        $optionalParameters += "--subnet", "$subnetResourceId"
    }
    
    Invoke-Executable az servicebus namespace network-rule add --name $ServiceBusNamespaceName --resource-group $ServiceBusNamespaceResourceGroupName @optionalParameters
}
else
{
    Write-Warning "Network Whitelist only possible for Premium ServiceBus SKU. Current SKU: $ServiceBusSku"
}

Write-Footer -ScopedPSCmdlet $PSCmdlet