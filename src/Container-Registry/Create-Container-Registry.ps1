[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ContainerRegistryName,
    [Parameter(Mandatory)][string] $ContainerRegistryResourceGroupName,
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $ContainerRegistryPrivateEndpointVnetName,
    [Alias("VnetResourceGroupName")]
    [Parameter(Mandatory)][string] $ContainerRegistryPrivateEndpointVnetResourceGroupName,
    [Parameter(Mandatory)][string] $ContainerRegistryPrivateEndpointSubnetName,
    [Parameter(Mandatory)][string] $ApplicationVnetResourceGroupName,
    [Parameter(Mandatory)][string] $ApplicationVnetName,
    [Parameter(Mandatory)][string] $ApplicationSubnetName,
    [Parameter(Mandatory)][string] $PrivateEndpointGroupId,
    [Parameter(Mandatory)][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter(Mandatory)][string] $ContainerRegistryPrivateDnsZoneName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$vnetId = (Invoke-Executable az network vnet show --resource-group $ContainerRegistryPrivateEndpointVnetResourceGroupName --name $ContainerRegistryPrivateEndpointVnetName | ConvertFrom-Json).id
$containerRegistryPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ContainerRegistryPrivateEndpointVnetResourceGroupName --name $ContainerRegistryPrivateEndpointSubnetName --vnet-name $ContainerRegistryPrivateEndpointVnetName | ConvertFrom-Json).id
$applicationSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ApplicationVnetResourceGroupName --name $ApplicationSubnetName --vnet-name $ApplicationVnetName | ConvertFrom-Json).id
$containerRegistryPrivateEndpointName = "$($ContainerRegistryName)-pvtacr-$($PrivateEndpointGroupId)"

Invoke-Executable az acr create --resource-group $ContainerRegistryResourceGroupName --name $ContainerRegistryName --sku Premium

# Fetch the ContainerRegistry ID to use while creating the Private Endpoint in the next step
$containerRegistryId = (Invoke-Executable az acr show --name $ContainerRegistryName --resource-group $ContainerRegistryResourceGroupName | ConvertFrom-Json).id

# Add private endpoint & Setup Private DNS
Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $containerRegistryPrivateEndpointSubnetId -PrivateEndpointName $containerRegistryPrivateEndpointName -PrivateEndpointResourceGroupName $ContainerRegistryResourceGroupName -TargetResourceId $containerRegistryId -PrivateEndpointGroupId $PrivateEndpointGroupId -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $ContainerRegistryPrivateDnsZoneName -PrivateDnsLinkName "$($ContainerRegistryPrivateEndpointVnetName)-acr"

# Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
Set-SubnetServiceEndpoint -SubnetResourceId $applicationSubnetId -ServiceEndpointServiceIdentifier 'Microsoft.ContainerRegistry'

# Whitelist our App's subnet in the Azure Container Registry so we can connect
Invoke-Executable az acr network-rule add --resource-group $ContainerRegistryResourceGroupName --name $ContainerRegistryName --subnet $applicationSubnetId

# Make sure the default action is "deny" which causes public traffic to be dropped (like is defined in the KSP)
Invoke-Executable az acr update --resource-group $ContainerRegistryResourceGroupName --name $ContainerRegistryName --default-action Deny

Write-Footer -ScopedPSCmdlet $PSCmdlet