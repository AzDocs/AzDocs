[CmdletBinding( DefaultParameterSetName = 'default' )]
param (
    [Parameter(Mandatory)][string] $StaticWebAppName,
    [Parameter(Mandatory)][string] $StaticWebAppResourceGroupName,
    [Parameter()][string] $StaticWebAppLocation,
    # see for the difference https://docs.microsoft.com/en-us/azure/static-web-apps/plans#features    
    [Parameter()][ValidateSet('Standard', 'Free')][string] $StaticWebAppSkuName = 'Standard',

    # Private Endpoint
    [Parameter(ParameterSetName = 'PrivateEndpoint', Mandatory)][string] $StaticWebAppPrivateEndpointVnetResourceGroupName,
    [Parameter(ParameterSetName = 'PrivateEndpoint', Mandatory)][string] $StaticWebAppPrivateEndpointVnetName,
    [Parameter(ParameterSetName = 'PrivateEndpoint', Mandatory)][string] $StaticWebAppPrivateEndpointSubnetName,
    [Parameter(ParameterSetName = 'PrivateEndpoint', Mandatory)][string] $DNSZoneResourceGroupName,
    [Parameter()][bool] $SkipDnsZoneConfiguration = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet
if ($null -eq $StaticWebAppLocation -or $StaticWebAppLocation -eq '')
{
    Write-Host "Fetching location from Resource Group $StaticWebAppResourceGroupName"
    $resourceGroup = Get-AzResourceGroup -Name $StaticWebAppResourceGroupName
    $StaticWebAppLocation = $resourceGroup.Location
    Write-Host "Setting Location to $StaticWebAppLocation"
}
$staticWebApp = Invoke-Executable az staticwebapp list --resource-group $StaticWebAppResourceGroupName | ConvertFrom-Json | Where-Object name -EQ $StaticWebAppName
if ($staticWebApp)
{
    $hostname = $staticWebApp.defaultHostname
    Write-Host "Static web app $StaticWebAppName already exists"
}
else
{
    Write-Host "Creating static web app $StaticWebAppName"

    $subscriptionId = (Invoke-Executable az account show | ConvertFrom-Json).id
    $connectionString = 'https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Web/staticSites/{name}?api-version=2021-02-01'

    $connectionString = $connectionString.Replace('{subscriptionId}', $subscriptionId).Replace('{resourceGroupName}', $StaticWebAppResourceGroupName).Replace('{name}', $StaticWebAppName)
    $body = ([PSCustomObject]@{
            location   = $StaticWebAppLocation
            properties = [PSCustomObject]@{
            }
            sku        = [PSCustomObject]@{
                Name = $StaticWebAppSkuName
                tier = $StaticWebAppSkuName
            }
        } | ConvertTo-Json -Compress -Depth 100).Replace('"', '\"')

    $staticWebApp = Invoke-Executable az rest --uri $connectionString --body $body --method 'PUT' | ConvertFrom-Json
    if (!$staticWebApp)
    {
        Get-Error
        throw 'Could not create static webapp'
    }
    $hostname = $staticWebApp.properties.defaultHostname
}

# Add private endpoint & Setup Private DNS
if ($StaticWebAppPrivateEndpointVnetResourceGroupName -and $StaticWebAppPrivateEndpointVnetName -and $StaticWebAppPrivateEndpointSubnetName -and $DNSZoneResourceGroupName)
{
    Write-Host 'A private endpoint is desired. Adding the needed components.'
    
    $regexString = '^(?<host>[^.]+)\.(?<address>.+)$'
    if ($hostname -match $regexString )
    {
        $staticWebAppPrivateDnsZoneName = "privatelink.$($Matches.address)"
        Write-Host "Private DNS name: $staticWebAppPrivateDnsZoneName"
    }
    else
    {
        throw "Could not resolve url '$hostname' with regex '$regexString'"
    }


    $abbrStaticWebApp = 'swa'
    # Fetch needed information
    $VnetSubnetIdentifiers = Get-VnetSubnetIdentifiers -VnetName $StaticWebAppPrivateEndpointVnetName -SubnetName $StaticWebAppPrivateEndpointSubnetName
    $StaticWebAppPrivateEndpointName = "$StaticWebAppName-pvt$abbrStaticWebApp"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $VnetSubnetIdentifiers.VnetIdentifier -PrivateEndpointSubnetId $VnetSubnetIdentifiers.SubnetIdentifier -PrivateEndpointName $StaticWebAppPrivateEndpointName -PrivateEndpointResourceGroupName $StaticWebAppResourceGroupName -TargetResourceId $staticWebApp.id -PrivateEndpointGroupId 'staticSites' -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $staticWebAppPrivateDnsZoneName -PrivateDnsLinkName "$StaticWebAppPrivateEndpointVnetName-$abbrStaticWebApp" -SkipDnsZoneConfiguration $SkipDnsZoneConfiguration
}

Write-Footer -ScopedPSCmdlet $PSCmdlet