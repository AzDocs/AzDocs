[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ContainerRegistryName,
    [Parameter(Mandatory)][string] $ContainerRegistryResourceGroupName,
    [Parameter(Mandatory)][ValidateSet('', 'Basic', 'Standard', 'Premium')][string] $ContainerRegistrySku = 'Premium',
    [Parameter(Mandatory)][bool] $ContainerRegistryEnableAdminUser = $false,
    
    # VNET Whitelisting
    [Parameter()][string] $ApplicationVnetResourceGroupName,
    [Parameter()][string] $ApplicationVnetName,
    [Parameter()][string] $ApplicationSubnetName,

    # Private Endpoint
    [Alias("VnetName")]
    [Parameter()][string] $ContainerRegistryPrivateEndpointVnetName,
    [Alias("VnetResourceGroupName")]
    [Parameter()][string] $ContainerRegistryPrivateEndpointVnetResourceGroupName,
    [Parameter()][string] $ContainerRegistryPrivateEndpointSubnetName,
    [Parameter()][string] $PrivateEndpointGroupId,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $ContainerRegistryPrivateDnsZoneName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$scriptArguments = ""
if ($ContainerRegistryEnableAdminUser)
{
    $scriptArguments += "--admin-enabled", "true"
}

Invoke-Executable az acr create --resource-group $ContainerRegistryResourceGroupName --name $ContainerRegistryName --sku $ContainerRegistrySku @scriptArguments

# Private Endpoint
if($ContainerRegistryPrivateEndpointVnetName -and $ContainerRegistryPrivateEndpointVnetResourceGroupName -and $ContainerRegistryPrivateEndpointSubnetName -and $PrivateEndpointGroupId -and $DNSZoneResourceGroupName -and $ContainerRegistryPrivateDnsZoneName)
{
    Write-Host "A private endpoint is desired. Adding the needed components."
    # Fetch basic info for pvt endpoint
    $vnetId = (Invoke-Executable az network vnet show --resource-group $ContainerRegistryPrivateEndpointVnetResourceGroupName --name $ContainerRegistryPrivateEndpointVnetName | ConvertFrom-Json).id
    $containerRegistryPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ContainerRegistryPrivateEndpointVnetResourceGroupName --name $ContainerRegistryPrivateEndpointSubnetName --vnet-name $ContainerRegistryPrivateEndpointVnetName | ConvertFrom-Json).id
    $containerRegistryPrivateEndpointName = "$($ContainerRegistryName)-pvtacr-$($PrivateEndpointGroupId)"

    # Fetch the ContainerRegistry ID to use while creating the Private Endpoint in the next step
    $containerRegistryId = (Invoke-Executable az acr show --name $ContainerRegistryName --resource-group $ContainerRegistryResourceGroupName | ConvertFrom-Json).id

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $containerRegistryPrivateEndpointSubnetId -PrivateEndpointName $containerRegistryPrivateEndpointName -PrivateEndpointResourceGroupName $ContainerRegistryResourceGroupName -TargetResourceId $containerRegistryId -PrivateEndpointGroupId $PrivateEndpointGroupId -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $ContainerRegistryPrivateDnsZoneName -PrivateDnsLinkName "$($ContainerRegistryPrivateEndpointVnetName)-acr"
}

# VNET Whitelisting
if($ApplicationVnetName -and $ApplicationSubnetName -and $ApplicationVnetResourceGroupName)
{
    Write-Host "VNET Whitelisting is desired. Adding the needed components."
    # Fetch Subnet ID for the application
    $applicationSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ApplicationVnetResourceGroupName --name $ApplicationSubnetName --vnet-name $ApplicationVnetName | ConvertFrom-Json).id

    # Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
    Set-SubnetServiceEndpoint -SubnetResourceId $applicationSubnetId -ServiceEndpointServiceIdentifier 'Microsoft.ContainerRegistry'

    # Whitelist our App's subnet in the Azure Container Registry so we can connect
    Invoke-Executable az acr network-rule add --resource-group $ContainerRegistryResourceGroupName --name $ContainerRegistryName --subnet $applicationSubnetId

    # Make sure the default action is "deny" which causes public traffic to be dropped (like is defined in the KSP)
    Invoke-Executable az acr update --resource-group $ContainerRegistryResourceGroupName --name $ContainerRegistryName --default-action Deny
}

Write-Footer -ScopedPSCmdlet $PSCmdlet