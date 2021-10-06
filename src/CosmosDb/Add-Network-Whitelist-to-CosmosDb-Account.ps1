[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $CosmosDBAccountName,
    [Parameter(Mandatory)][string] $CosmosDBAccountResourceGroupName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist,
    [Parameter()][string] $SubnetToWhitelistSubnetName,
    [Parameter()][string] $SubnetToWhitelistVnetName,
    [Parameter()][string] $SubnetToWhitelistVnetResourceGroupName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# CosmosDb account can only take lowercase characters
$CosmosDBAccountName = $CosmosDBAccountName.ToLower()

# Confirm if the correct parameters are passed
Confirm-ParametersForWhitelist -CIDR:$CIDRToWhitelist -SubnetName:$SubnetToWhitelistSubnetName -VnetName:$SubnetToWhitelistVnetName -VnetResourceGroupName:$SubnetToWhitelistVnetResourceGroupName

# Fetch Subnet ID when subnet option is given.
if ($SubnetToWhitelistSubnetName -and $SubnetToWhitelistVnetName -and $SubnetToWhitelistVnetResourceGroupName)
{
    Write-Host 'Subnet whitelisting is desired. Whitelisting subnet...'
    $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $SubnetToWhitelistVnetResourceGroupName --name $SubnetToWhitelistSubnetName --vnet-name $SubnetToWhitelistVnetName | ConvertFrom-Json).id

    # Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
    Set-SubnetServiceEndpoint -SubnetResourceId $subnetResourceId -ServiceEndpointServiceIdentifier 'Microsoft.AzureCosmosDB'

    # Make sure we dont talk to an updating cluster
    Wait-ForClusterToBeReady -CosmosDBAccountName $CosmosDBAccountName -CosmosDBAccountResourceGroupName $CosmosDBAccountResourceGroupName

    # Add subnet
    Invoke-Executable az cosmosdb network-rule add --subnet $subnetResourceId --name $CosmosDBAccountName --resource-group $CosmosDBAccountResourceGroupName
    Write-Host "Subnet $subnetResourceId whitelisted."
}
else
{
    # Check if CIDR is passed, it adheres to restrictions
    Assert-CIDR -CIDR:$CIDRToWhitelist

    # Autogenerate CIDR if no CIDR is passed
    $CIDRToWhitelist = Get-CIDRForWhitelist -CIDR:$CIDRToWhitelist

    # Confirm we have a valid CIDR to be whitelisted
    $CIDRToWhitelist = Confirm-CIDRForWhitelist -ServiceType 'cosmosdb' -CIDR $CIDRToWhitelist

    # Only add if CIDR doesn't exist
    $ipAddressAlreadyPresent = $false
    $foundCidrMatch = $null
    $currentIpRules = ((Invoke-Executable az cosmosdb show --name $CosmosDBAccountName --resource-group $CosmosDBAccountResourceGroupName | ConvertFrom-Json).ipRules) | Select-Object -ExpandProperty ipAddressOrRange
    
    if ($currentIpRules)
    {
        $startIpInCidr = Get-StartIpInIpv4Network -SubnetCidr $CIDRToWhitelist
        $endIpInCidr = Get-EndIpInIpv4Network -SubnetCidr $CIDRToWhitelist

        foreach ($currentIpRule in $currentIpRules)
        {
            $startIpInIpv4Network = Get-StartIpInIpv4Network -SubnetCidr $currentIpRule
            $endIpInIpv4Network = Get-EndIpInIpv4Network -SubnetCidr $currentIpRule
            if ((Test-IpAddressInCidrRange -IpAddress $startIpInCidr -StartIpInIpv4Network $startIpInIpv4Network -EndIpInIpv4Network $endIpInIpv4Network) -and
            (Test-IpAddressInCidrRange -IpAddress $endIpInCidr -StartIpInIpv4Network $startIpInIpv4Network -EndIpInIpv4Network $endIpInIpv4Network))
            {
                $ipAddressAlreadyPresent = $true
                $foundCidrMatch = $currentIpRule
                break
            }
        }
    }

    if (!$ipAddressAlreadyPresent)
    {
        # If one, make sure to convert to array
        if ($currentIpRules.GetType().Name -eq 'String')
        {
            $currentIpRules = @($currentIpRules)
        }
        $currentIpRules += $CIDRToWhitelist

        # Make sure we dont talk to an updating cluster
        Wait-ForClusterToBeReady -CosmosDBAccountName $CosmosDBAccountName -CosmosDBAccountResourceGroupName $CosmosDBAccountResourceGroupName

        $ipSet = [String]::Join(',', $currentIpRules)
        Write-Host "ipSet: $ipSet"
        Invoke-Executable az cosmosdb update --name $CosmosDBAccountName --resource-group $CosmosDBAccountResourceGroupName --ip-range-filter $ipSet
        Write-Host "CIDR $CIDRToWhitelist added"
    }
    else
    {
        Write-Host "CIDR $CIDRToWhitelist already present in $foundCidrMatch"
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet