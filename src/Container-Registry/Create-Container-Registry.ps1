[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ContainerRegistryName,
    [Parameter(Mandatory)][string] $ContainerRegistryResourceGroupName,
    [Parameter()][ValidateSet('', 'Basic', 'Standard', 'Premium')][string] $ContainerRegistrySku = 'Premium',
    [Parameter()][bool] $ContainerRegistryEnableAdminUser = $false,
    
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
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Parameter()][string] $PrivateEndpointGroupId = "registry",
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $ContainerRegistryPrivateDnsZoneName = "privatelink.azurecr.io",

    # Forcefully agree to this resource to be spun up to be publicly available
    [Parameter()][switch] $ForcePublic,

    # Diagnostic Settings
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ((!$ApplicationVnetResourceGroupName -or !$ApplicationVnetName -or !$ApplicationSubnetName) -and (!$ContainerRegistryPrivateEndpointVnetResourceGroupName -or !$ContainerRegistryPrivateEndpointVnetName -or !$ContainerRegistryPrivateEndpointSubnetName -or !$PrivateEndpointGroupId -or !$DNSZoneResourceGroupName -or !$ContainerRegistryPrivateDnsZoneName)) {
    # Check if we are making this resource public intentionally
    Assert-IntentionallyCreatedPublicResource -ForcePublic $ForcePublic
}


$scriptArguments = @()
if ($ContainerRegistryEnableAdminUser) {
    $scriptArguments += "--admin-enabled", "true"
}

$containerRegistryId = (Invoke-Executable az acr create --resource-group $ContainerRegistryResourceGroupName --name $ContainerRegistryName --sku $ContainerRegistrySku @scriptArguments | ConvertFrom-Json).id

# Private Endpoint
if ($ContainerRegistryPrivateEndpointVnetName -and $ContainerRegistryPrivateEndpointVnetResourceGroupName -and $ContainerRegistryPrivateEndpointSubnetName -and $PrivateEndpointGroupId -and $DNSZoneResourceGroupName -and $ContainerRegistryPrivateDnsZoneName) {
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
if ($ApplicationVnetName -and $ApplicationSubnetName -and $ApplicationVnetResourceGroupName) {
    # Whitelist VNET
    & "$PSScriptRoot\Add-Network-Whitelist-to-Container-Registry.ps1" -ContainerRegistryName $ContainerRegistryName -ContainerRegistryResourceGroupName $ContainerRegistryResourceGroupName -SubnetToWhitelistSubnetName $ApplicationSubnetName -SubnetToWhitelistVnetName $ApplicationVnetName -SubnetToWhitelistVnetResourceGroupName $ApplicationVnetResourceGroupName

    # Make sure the default action is "deny" which causes public traffic to be dropped.
    Invoke-Executable az acr update --resource-group $ContainerRegistryResourceGroupName --name $ContainerRegistryName --default-action Deny
}

# Add diagnostic settings to container registry
Set-DiagnosticSettings -ResourceId $containerRegistryId -ResourceName $ContainerRegistryName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -Logs "[{ 'category': 'ContainerRegistryRepositoryEvents', 'enabled': true }, { 'category': 'ContainerRegistryLoginEvents', 'enabled': true }]".Replace("'", '\"') -Metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')

Write-Footer -ScopedPSCmdlet $PSCmdlet