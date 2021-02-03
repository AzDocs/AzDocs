#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Common-Helper-Functions.ps1"
#endregion ===END IMPORTS===


<#
.SYNOPSIS
    Ensure the given servicename is set to the given subnet resource identifier
.DESCRIPTION
    Ensure the given servicename is set to the given subnet resource identifier
#>
function Set-SubnetServiceEndpoint
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $SubnetResourceId,
        [Parameter(Mandatory)][string][ValidateSet("Microsoft.Storage", "Microsoft.Sql", "Microsoft.AzureActiveDirectory", "Microsoft.AzureCosmosDB", "Microsoft.Web", "Microsoft.KeyVault", "Microsoft.EventHub", "Microsoft.ServiceBus", "Microsoft.ContainerRegistry", "Microsoft.CognitiveServices")] $ServiceEndpointServiceIdentifier
    )

    #region ===BEGIN IMPORTS===
    . "$PSScriptRoot\Write-HeaderFooter.ps1"
    . "$PSScriptRoot\Invoke-Executable.ps1"
    #endregion ===END IMPORTS===

    Write-Header

    $subnetInformation = Invoke-Executable az network vnet subnet show --ids $SubnetResourceId | ConvertFrom-Json
    [string[]]$endpoints = $subnetInformation.ServiceEndpoints.service

    if (!$endpoints)
    {
        $endpoints = @()
    }
    
    if (!($endpoints -contains $ServiceEndpointServiceIdentifier))
    {
        Write-Host "$ServiceEndpointServiceIdentifier Service Endpoint isnt defined yet. Adding it to the list."
        $endpoints += $ServiceEndpointServiceIdentifier
        Invoke-Executable az network vnet subnet update --ids $SubnetResourceId --service-endpoints @endpoints
    }
    else
    {
        Write-Host "$ServiceEndpointServiceIdentifier Service Endpoint is already defined. No action needed."
    }

    Write-Footer
}

function Add-PrivateEndpoint
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $PrivateEndpointVnetId,
        [Parameter(Mandatory)][string] $PrivateEndpointSubnetId,
        [Parameter(Mandatory)][string] $PrivateEndpointName,
        [Parameter(Mandatory)][string] $PrivateEndpointResourceGroupName,
        [Parameter(Mandatory)][string] $TargetResourceId,
        [Parameter(Mandatory)][string] $PrivateEndpointGroupId,
        [Parameter(Mandatory)][string] $DNSZoneResourceGroupName,
        [Parameter(Mandatory)][string] $PrivateDnsZoneName,
        [Parameter(Mandatory)][string] $PrivateDnsLinkName
    )

    # Disable private-endpoint-network-policies
    Invoke-Executable az network vnet subnet update --ids $PrivateEndpointSubnetId --disable-private-endpoint-network-policies true

    # === BEGIN Removal of the old deprecated setup. ===
    $privateEndpointResourceId = ((Invoke-Executable -AllowToFail az resource show --ids $TargetResourceId | ConvertFrom-Json).properties.privateEndpointConnections.properties.privateEndpoint.id) | Select-Object -first 1
    $privateLinkServiceConnection = (Invoke-Executable -AllowToFail az network private-endpoint show --id $privateEndpointResourceId | ConvertFrom-Json).privateLinkServiceConnections | Select-Object -first 1
    Write-Host "privateEndpointResourceId: $privateEndpointResourceId"
    Write-Host "privateLinkServiceConnection: $privateLinkServiceConnection"
    if ($privateLinkServiceConnection)
    {
        Write-Host "privateLinkServiceConnection.name: $($privateLinkServiceConnection.name)"
        if ($privateLinkServiceConnection.name -like "*-connection")
        {
            Write-Host "Found old private endpoint. Deleting before recreation."
            Write-Host "privateLinkServiceConnection.name: $($privateLinkServiceConnection.id)"
            Invoke-Executable az network private-endpoint delete --id $privateLinkServiceConnection.id
        }
    }
    # === END Removal of the old deprecated setup. ===

    # Create private endpoint for resource
    $vnetName = (Invoke-Executable az network vnet show --ids $PrivateEndpointVnetId | ConvertFrom-Json).name
    $privateEndpointSubnetName = (Invoke-Executable az network vnet subnet show --ids $PrivateEndpointSubnetId | ConvertFrom-Json).name
    Invoke-Executable az network private-endpoint create --name $PrivateEndpointName --resource-group $PrivateEndpointResourceGroupName --subnet $PrivateEndpointSubnetId --connection-name "$($PrivateEndpointName)-$($vnetName)-$($privateEndpointSubnetName)" --private-connection-resource-id $TargetResourceId --group-id $PrivateEndpointGroupId

    # Create Private DNS zone & set it up
    if (!$(Invoke-Executable -AllowToFail az network private-dns zone show --resource-group $DNSZoneResourceGroupName --name $PrivateDnsZoneName))
    {
        Invoke-Executable az network private-dns zone create --resource-group $DNSZoneResourceGroupName --name $PrivateDnsZoneName
    }

    # Link the newly created DNS Zone to the VNET (to make sure our VNET can resolve this private DNS zone)
    if (!$(Invoke-Executable -AllowToFail az network private-dns link vnet show --name $PrivateDnsLinkName --resource-group $DNSZoneResourceGroupName --zone-name $PrivateDnsZoneName))
    {
        Invoke-Executable az network private-dns link vnet create --resource-group $DNSZoneResourceGroupName --zone-name $PrivateDnsZoneName --name $PrivateDnsLinkName --virtual-network $PrivateEndpointVnetId --registration-enabled false
    }

    # === BEGIN Removal of the old deprecated setup. ===
    $dashedPrivateDnsZoneName = Get-DashedDomainname -DomainName $PrivateDnsZoneName
    $dnsZoneGroups = Invoke-Executable -AllowToFail az network private-endpoint dns-zone-group list --resource-group $PrivateEndpointResourceGroupName --endpoint-name $PrivateEndpointName
    if ($dnsZoneGroups)
    {
        Write-Host "DnsZoneGroups found"
        $dnsZoneGroups = $dnsZoneGroups | ConvertFrom-Json
        foreach ($dnsZoneGroup in $dnsZoneGroups)
        {
            if (!($dnsZoneGroup.name -like "*-zonegroup"))
            {
                Write-Host "No dnsZoneGroup found with deprecated setup name. Continue;"
                # Nothing to do. Continue to the next entry.
                continue;
            }

            Write-Host "Deleting private-endpoint dns-zone-group with $($dnsZoneGroup.name)"
            Invoke-Executable az network private-endpoint dns-zone-group delete --resource-group $PrivateEndpointResourceGroupName --endpoint-name $PrivateEndpointName --name $dnsZoneGroup.name
            Write-Host "Deleted private-endpoint dns-zone-group with $($dnsZoneGroup.name)"
        }
    }
    # === END Removal of the old deprecated setup. ===

    # Connect the DNS Zone to the Private Endpoint to be able to resolve this endpoint within the VNET
    $dnsZoneId = (Invoke-Executable az network private-dns zone show --resource-group $DNSZoneResourceGroupName --name $PrivateDnsZoneName | ConvertFrom-Json).id
    
    Write-Host "Creating private-endpoint dns-zone-group with dnsZoneId: $dnsZoneId"
    Invoke-Executable az network private-endpoint dns-zone-group create --resource-group $PrivateEndpointResourceGroupName --endpoint-name $PrivateEndpointName --name "dnsgroupname" --private-dns-zone $dnsZoneId --zone-name $dashedPrivateDnsZoneName
    Write-Host "Created private-endpoint dns-zone-group with dnsZoneId: $dnsZoneId"
}