[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $RedisInstanceLocation,
    [Parameter(Mandatory)][string] $RedisInstanceName,
    [Parameter(Mandatory)][string] $RedisInstanceResourceGroupName,
    [Parameter(Mandatory)][ValidateSet('Basic', 'Standard', 'Premium')][string] $RedisInstanceSkuName,
    [Parameter(Mandatory)][ValidateSet('C0', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'P1', 'P2', 'P3', 'P4', 'P5')][string] $RedisInstanceVmSize,
    [Parameter()][bool] $RedisInstanceEnableNonSslPort = $false,
    [Parameter()][ValidateSet('1.0', '1.1', '1.2')][string] $RedisInstanceMinimalTlsVersion = '1.2',
    [Parameter()][System.Object[]] $ResourceTags,
    [Parameter()][ValidateSet('4.0', '6.0', 'latest')] $RedisVersion,
    
    # Private Endpoints
    [Parameter()][string] $RedisInstancePrivateEndpointVnetResourceGroupName,
    [Parameter()][string] $RedisInstancePrivateEndpointVnetName,
    [Parameter()][string] $RedisInstancePrivateEndpointSubnetName,
    [Parameter()][string] $RedisInstancePrivateDnsZoneName = 'privatelink.redis.cache.windows.net',
    [Parameter()][string] $DNSZoneResourceGroupName,

    # VNet Integration
    [Parameter()][string] $RedisInstanceVNetIntegrationVnetName,
    [Parameter()][string] $RedisInstanceVNetIntegrationVnetResourceGroupName,
    [Parameter()][string] $RedisInstanceVNetIntegrationSubnetName,

    # Forcefully agree to this resource to be spun up to be publicly available
    [Parameter()][switch] $ForcePublic,

    # Diagnostic Settings
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    [Parameter()][System.Object[]] $DiagnosticSettingsLogs,
    [Parameter()][System.Object[]] $DiagnosticSettingsMetrics,

    # Disable diagnostic settings
    [Parameter()][switch] $DiagnosticSettingsDisabled
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ((!$RedisInstancePrivateEndpointVnetResourceGroupName -or !$RedisInstancePrivateEndpointVnetName -or !$RedisInstancePrivateEndpointSubnetName -or !$DNSZoneResourceGroupName -or !$RedisInstancePrivateDnsZoneName) -and (!$RedisInstanceVNetIntegrationVnetName -and !$RedisInstanceVNetIntegrationSubnetName -and !$RedisInstanceVNetIntegrationVnetResourceGroupName) -or $RedisInstanceEnableNonSslPort)
{
    # Check if we are making this resource public intentionally
    Assert-IntentionallyCreatedPublicResource -ForcePublic $ForcePublic
}

# Assert TLS Version
Assert-TLSVersion -TlsVersion $RedisInstanceMinimalTlsVersion

# Assert if chosen for VNet Whitelisting, the tier is premium
if (($RedisInstanceVNetIntegrationVnetName -and $RedisInstanceVNetIntegrationSubnetName -and $RedisInstanceVNetIntegrationVnetResourceGroupName) -and $RedisInstanceSkuName -ne 'Premium')
{
    throw "The Redis Instance can only be tied to a Virtual Network when using the Premium tier. Please change your RedisInstanceSkuName to Premium or pick a different networking option."
}

$additionalParameters = @()
$updateParameters = @()
if ($RedisInstanceEnableNonSslPort)
{
    $additionalParameters += '--enable-non-ssl-port'
}
if ($RedisVersion)
{
    $additionalParameters += "--redis-version $RedisVersion"
    $updateParameters += "redisVersion=$RedisVersion"
}
if ($RedisInstanceVNetIntegrationVnetName -and $RedisInstanceVNetIntegrationSubnetName -and $RedisInstanceVNetIntegrationVnetResourceGroupName)
{
    # VNet Whitelisting
    $RedisInstanceSubnetId = (Invoke-Executable az network vnet subnet show --name $RedisInstanceVNetIntegrationSubnetName --resource-group $RedisInstanceVNetIntegrationVNetResourceGroupName --vnet-name $RedisInstanceVnetIntegrationVnetName | ConvertFrom-Json).id

    $additionalParameters += '--subnet-id', $RedisInstanceSubnetId
    $updateParameters += "subnetId=$RedisInstanceSubnetId"
}

function WaitForRedisProvisioningToBeDone
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $RedisInstanceName,
        [Parameter(Mandatory)][string] $RedisInstanceResourceGroupName
    )

    # Check if redis instance exists. If not, return.
    $redisInstance = (Invoke-Executable -AllowToFail az redis show --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName)
    if (!$redisInstance)
    {
        return
    }

    while (((Invoke-Executable -AllowToFail az redis show --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName) | ConvertFrom-Json).provisioningState -ne 'Succeeded')
    {
        Write-Host 'Redis still provisioning... waiting for it to complete...'
        Start-Sleep -Seconds 60
    }
}

WaitForRedisProvisioningToBeDone -RedisInstanceName $RedisInstanceName -RedisInstanceResourceGroupName $RedisInstanceResourceGroupName
$redisInstance = Invoke-Executable -AllowToFail az redis show --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName | ConvertFrom-Json
if (!$redisInstance)
{
    $redisInstanceResourceId = (Invoke-Executable az redis create --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName --sku $RedisInstanceSkuName --vm-size $RedisInstanceVmSize --location $RedisInstanceLocation --minimum-tls-version $RedisInstanceMinimalTlsVersion --tags @ResourceTags @additionalParameters | ConvertFrom-Json).id
}
else
{
    Write-Host "Redis cache already exists, updating.."
    # When enabling the NonSslPort, public network access is enabled
    if ($redisInstance.privateEndpointConnections)
    {
        Write-Host "This redis cache has private endpoints, updating.."
        if (($redisInstance.publicNetworkAccess -eq 'Enabled') -and !$RedisInstanceEnableNonSslPort)
        {
            # Disabling NonSslPort and the public network access back to false
            Invoke-Executable az redis update --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName --set "enableNonSslPort=$RedisInstanceEnableNonSslPort"
            WaitForRedisProvisioningToBeDone -RedisInstanceName $RedisInstanceName -RedisInstanceResourceGroupName $RedisInstanceResourceGroupName
            Invoke-Executable az redis update --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName --set "publicNetworkAccess=Disabled"
        }
    }
    else
    {
        if ($RedisInstanceEnableNonSslPort)
        {
            Write-Host "You are enabling the non ssl port for this instance. This is NOT recommended."
        }

        WaitForRedisProvisioningToBeDone -RedisInstanceName $RedisInstanceName -RedisInstanceResourceGroupName $RedisInstanceResourceGroupName
        Invoke-Executable az redis update --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName --set "enableNonSslPort=$RedisInstanceEnableNonSslPort"
    }

    WaitForRedisProvisioningToBeDone -RedisInstanceName $RedisInstanceName -RedisInstanceResourceGroupName $RedisInstanceResourceGroupName
    $redisInstanceResourceId = (Invoke-Executable az redis update --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName --sku $RedisInstanceSkuName --vm-size $RedisInstanceVmSize --set "minimumTlsVersion=$RedisInstanceMinimalTlsVersion" @updateParameters | ConvertFrom-Json).id
}
WaitForRedisProvisioningToBeDone -RedisInstanceName $RedisInstanceName -RedisInstanceResourceGroupName $RedisInstanceResourceGroupName

# Update Tags
if ($ResourceTags)
{
    Set-ResourceTagsForResource -ResourceId $redisInstanceResourceId -ResourceTags ${ResourceTags}
}

# Private Endpoints
if ($RedisInstancePrivateEndpointVnetResourceGroupName -and $RedisInstancePrivateEndpointVnetName -and $RedisInstancePrivateEndpointSubnetName -and $RedisInstancePrivateDnsZoneName -and $DNSZoneResourceGroupName)
{
    Write-Host 'A private endpoint is desired. Adding the needed components.'
    # Fetch needed information
    $vnetId = (Invoke-Executable az network vnet show --resource-group $RedisInstancePrivateEndpointVnetResourceGroupName --name $RedisInstancePrivateEndpointVnetName | ConvertFrom-Json).id
    $redisInstancePrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $RedisInstancePrivateEndpointVnetResourceGroupName --name $RedisInstancePrivateEndpointSubnetName --vnet-name $RedisInstancePrivateEndpointVnetName | ConvertFrom-Json).id
    $redisInstancePrivateEndpointName = "$($RedisInstanceName)-pvtredis"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $redisInstancePrivateEndpointSubnetId -PrivateEndpointName $redisInstancePrivateEndpointName -PrivateEndpointResourceGroupName $RedisInstanceResourceGroupName -TargetResourceId $redisInstanceResourceId -PrivateEndpointGroupId redisCache -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $RedisInstancePrivateDnsZoneName -PrivateDnsLinkName "$($RedisInstancePrivateEndpointVnetName)-redis"
}

# Add diagnostic settings to RedisCache server
if ($DiagnosticSettingsDisabled)
{
    Remove-DiagnosticSetting -ResourceId $redisInstanceResourceId -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $RedisInstanceName
}
else
{
    Set-DiagnosticSettings -ResourceId $redisInstanceResourceId -ResourceName $RedisInstanceName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -DiagnosticSettingsLogs:$DiagnosticSettingsLogs -DiagnosticSettingsMetrics:$DiagnosticSettingsMetrics
}

Write-Footer -ScopedPSCmdlet $PSCmdlet
