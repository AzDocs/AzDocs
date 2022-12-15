[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $CosmosDBAccountName,
    [Parameter(Mandatory)][string] $CosmosDBAccountResourceGroupName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToRemoveFromWhitelist,
    [Parameter()][string] $SubnetToRemoveSubnetName,
    [Parameter()][string] $SubnetToRemoveVnetName,
    [Parameter()][string] $SubnetToRemoveVnetResourceGroupName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Confirm if the correct parameters are passed
Confirm-ParametersForWhitelist -CIDR:$CIDRToRemoveFromWhitelist -SubnetName:$SubnetToRemoveSubnetName -VnetName:$SubnetToRemoveVnetName -VnetResourceGroupName:$SubnetToRemoveVnetResourceGroupName

# Autogenerate CIDR if no CIDR or Subnet is passed
$CIDRToRemoveFromWhitelist = Get-CIDRForWhitelist -CIDR:$CIDRToRemoveFromWhitelist -SubnetName:$SubnetToRemoveSubnetName -VnetName:$SubnetToRemoveVnetName -VnetResourceGroupName:$SubnetToRemoveVnetResourceGroupName 
$CIDRToRemoveFromWhitelist = Confirm-CIDRForWhitelist -ServiceType 'cosmosdb' -CIDR:$CIDRToRemoveFromWhitelist

# Fetch Subnet ID when subnet option is given.
if ($SubnetToRemoveSubnetName -and $SubnetToRemoveVnetName -and $SubnetToRemoveVnetResourceGroupName)
{
    Write-Host 'Subnet dewhitelisting is desired. Dewhitelisting subnet...'
    $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $SubnetToRemoveVnetResourceGroupName --name $SubnetToRemoveSubnetName --vnet-name $SubnetToRemoveVnetName | ConvertFrom-Json).id

    # Make sure we dont talk to an updating cluster
    Wait-ForClusterToBeReady -CosmosDBAccountName $CosmosDBAccountName -CosmosDBAccountResourceGroupName $CosmosDBAccountResourceGroupName

    # Remove subnet
    Invoke-Executable az cosmosdb network-rule remove --subnet $subnetResourceId --name $CosmosDBAccountName --resource-group $CosmosDBAccountResourceGroupName
    Write-Host "Subnet $subnetResourceId dewhitelisted."
}
else
{
    # Check if CIDR is passed, it adheres to restrictions
    Assert-CIDR -CIDR:$CIDRToRemoveFromWhitelist

    # Autogenerate CIDR if no CIDR is passed
    $CIDRToRemoveFromWhitelist = Get-CIDRForWhitelist -CIDR:$CIDRToRemoveFromWhitelist

    # Confirm we have a valid CIDR to be whitelisted
    $CIDRToRemoveFromWhitelist = Confirm-CIDRForWhitelist -ServiceType 'cosmosdb' -CIDR $CIDRToRemoveFromWhitelist

    # Only remove if CIDR exists
    $ipAddressAlreadyPresent = $false
    $foundCidrMatch = $null
    $currentIpRules = ((Invoke-Executable az cosmosdb show --name $CosmosDBAccountName --resource-group $CosmosDBAccountResourceGroupName | ConvertFrom-Json).ipRules) | Select-Object -ExpandProperty ipAddressOrRange
    
    if ($currentIpRules -and ($currentIpRules -contains $CIDRToRemoveFromWhitelist))
    {
        $newIpRules = $currentIpRules | Where-Object { $_ –ne $CIDRToRemoveFromWhitelist }

        # Make sure we dont talk to an updating cluster
        Wait-ForClusterToBeReady -CosmosDBAccountName $CosmosDBAccountName -CosmosDBAccountResourceGroupName $CosmosDBAccountResourceGroupName

        if ($newIpRules)
        {
            $ipSet = [String]::Join(',', $newIpRules)
        }
        else
        {
            $ipSet = '""' # Hack for empty string. No [string]::Empty doesn't work.
        }

        Invoke-Executable az cosmosdb update --name $CosmosDBAccountName --resource-group $CosmosDBAccountResourceGroupName --ip-range-filter $ipSet
        Write-Host "CIDR $CIDRToRemoveFromWhitelist removed from whitelist"
    }
    else
    {
        Write-Host "CIDR $CIDRToRemoveFromWhitelist not found in current rules."
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet