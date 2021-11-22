[CmdletBinding()]
param (
    [Alias("SqlServerPassword")]
    [Parameter(Mandatory)][string] $PostgreSqlServerPassword,
    [Alias("SqlServerUsername")]
    [Parameter(Mandatory)][string] $PostgreSqlServerUsername,
    [Alias("SqlServerName")]
    [Parameter(Mandatory)][string] $PostgreSqlServerName,
    [Alias("SqlServerResourceGroupName")]
    [Parameter(Mandatory)][string] $PostgreSqlServerResourceGroupName,
    [Alias("SqlServerSku")]
    [Parameter(Mandatory)][string] $PostgreSqlServerSku,
    [Parameter()][int] $BackupRetentionInDays = 7,
    [Alias("SqlServerVersion")]
    [Parameter()][string] $PostgreSqlServerVersion = "11",
    [Parameter()][ValidateSet('Enabled', 'Disabled')][string] $PostgreSqlServerPublicNetworkAccess = 'Disabled',
    [Parameter()][ValidateSet('TLS1_0', 'TLS1_1', 'TLS1_2', 'TLSEnforcementDisabled')][string] $PostgreSqlServerMinimalTlsVersion = "TLS1_2",

    # VNET Whitelisting
    [Parameter()][string] $ApplicationVnetName,
    [Parameter()][string] $ApplicationVnetResourceGroupName,
    [Parameter()][string] $ApplicationSubnetName,

    # Private Endpoint
    [Alias("VnetResourceGroupName")]
    [Parameter()][string] $PostgreSqlServerPrivateEndpointVnetResourceGroupName,
    [Alias("VnetName")]
    [Parameter()][string] $PostgreSqlServerPrivateEndpointVnetName,
    [Alias("SqlServerPrivateEndpointSubnetName")]
    [Parameter()][string] $PostgreSqlServerPrivateEndpointSubnetName,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $PostgreSqlServerPrivateDnsZoneName = "privatelink.postgres.database.azure.com", 

    [Parameter()][System.Object[]] $ResourceTags,

    # Forcefully agree to this resource to be spun up to be publicly available
    [Parameter()][switch] $ForcePublic,

    # Forcefully agree to spin up this resource with TLS disabled
    [Parameter()][switch] $ForceDisableTLS,

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

if ((!$ApplicationVnetResourceGroupName -or !$ApplicationVnetName -or !$ApplicationSubnetName) -and (!$PostgreSqlServerPrivateEndpointVnetResourceGroupName -or !$PostgreSqlServerPrivateEndpointVnetName -or !$PostgreSqlServerPrivateEndpointSubnetName -or !$DNSZoneResourceGroupName -or !$PostgreSqlServerPrivateDnsZoneName))
{
    # Check if we are making this resource public intentionally
    Assert-IntentionallyCreatedPublicResource -ForcePublic $ForcePublic
}

# Check TLS version
Assert-TLSVersion -TlsVersion $PostgreSqlServerMinimalTlsVersion -ForceDisableTLS $ForceDisableTLS

$resourceGroupLocation = (az group show --name $PostgreSqlServerResourceGroupName | ConvertFrom-Json).location
Write-Host "Found location $($resourceGroupLocation)"

#endregion Make sure to enable public network access when we are using VNet Whitelisting
if ($ApplicationVnetResourceGroupName -and $ApplicationVnetName -and $ApplicationSubnetName -and $PostgreSqlServerPublicNetworkAccess -eq 'Disabled')
{
    $PostgreSqlServerPublicNetworkAccess = 'Enabled'
    Write-Warning "You are trying to use VNet whitelisting with public access disabled. This is impossible. The public endpoint will be forcefully enabled."
}

# Create PostgreSQL Server if it does not exist
$postgreSqlServerId = (Invoke-Executable -AllowToFail az postgres server show --name $PostgreSqlServerName --resource-group $PostgreSqlServerResourceGroupName | ConvertFrom-Json).Id
if (!$postgreSqlServerId)
{
    $postgreSqlServerId = (Invoke-Executable az postgres server create --admin-password $PostgreSqlServerPassword --admin-user $PostgreSqlServerUsername --name $PostgreSqlServerName --resource-group $PostgreSqlServerResourceGroupName --location $resourceGroupLocation --sku-name $PostgreSqlServerSku --backup-retention $BackupRetentionInDays --assign-identity --public-network-access $PostgreSqlServerPublicNetworkAccess --version $PostgreSqlServerVersion --minimal-tls-version $PostgreSqlServerMinimalTlsVersion | ConvertFrom-Json).id
}
else
{
    Invoke-Executable az postgres server update --admin-password $PostgreSqlServerPassword --name $PostgreSqlServerName --resource-group $PostgreSqlServerResourceGroupName --sku-name $PostgreSqlServerSku --backup-retention $BackupRetentionInDays --assign-identity --public-network-access $PostgreSqlServerPublicNetworkAccess --minimal-tls-version $PostgreSqlServerMinimalTlsVersion
}

# Update Tags
if ($ResourceTags)
{
    Set-ResourceTagsForResource -ResourceId $postgreSqlServerId -ResourceTags ${ResourceTags}
}

# VNet Whitelisting
if ($ApplicationVnetResourceGroupName -and $ApplicationVnetName -and $ApplicationSubnetName)
{
    # REMOVE OLD NAMES
    $oldAccessRuleName = ToMd5Hash -InputString "$($ApplicationVnetName)_$($ApplicationSubnetName)_allow"
    Remove-VnetRulesIfExists -ServiceType 'postgres' -ResourceGroupName $PostgreSqlServerResourceGroupName -ResourceName $PostgreSqlServerName -AccessRuleName $oldAccessRuleName
    # END REMOVE OLD NAMES

    Write-Host "VNET Whitelisting is desired. Adding the needed components."
    
    # Whitelist VNET
    & "$PSScriptRoot\Add-Network-Whitelist-to-PostgreSQL.ps1" -PostgreSqlServerName $PostgreSqlServerName -PostgreSqlServerResourceGroupName $PostgreSqlServerResourceGroupName -SubnetToWhitelistSubnetName $ApplicationSubnetName -SubnetToWhitelistVnetName $ApplicationVnetName -SubnetToWhitelistVnetResourceGroupName $ApplicationVnetResourceGroupName
}

# Private Endpoint
if ($PostgreSqlServerPrivateEndpointVnetResourceGroupName -and $PostgreSqlServerPrivateEndpointVnetName -and $PostgreSqlServerPrivateEndpointSubnetName -and $DNSZoneResourceGroupName -and $PostgreSqlServerPrivateDnsZoneName)
{
    Write-Host "A private endpoint is desired. Adding the needed components."
    $vnetId = (Invoke-Executable az network vnet show --resource-group $PostgreSqlServerPrivateEndpointVnetResourceGroupName --name $PostgreSqlServerPrivateEndpointVnetName | ConvertFrom-Json).id
    $sqlServerPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $PostgreSqlServerPrivateEndpointVnetResourceGroupName --name $PostgreSqlServerPrivateEndpointSubnetName --vnet-name $PostgreSqlServerPrivateEndpointVnetName | ConvertFrom-Json).id
    $sqlServerPrivateEndpointName = "$($PostgreSqlServerName)-pvtpsql"
    
    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $sqlServerPrivateEndpointSubnetId -PrivateEndpointName $sqlServerPrivateEndpointName -PrivateEndpointResourceGroupName $PostgreSqlServerResourceGroupName -TargetResourceId $postgreSqlServerId -PrivateEndpointGroupId postgresqlServer -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $PostgreSqlServerPrivateDnsZoneName -PrivateDnsLinkName "$($PostgreSqlServerPrivateEndpointVnetName)-psql"
}

# Add diagnostic settings to PostgreSQL server
if ($DiagnosticSettingsDisabled)
{
    Remove-DiagnosticSetting -ResourceId $postgreSqlServerId -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $PostgreSqlServerName
}
else
{
    Set-DiagnosticSettings -ResourceId $postgreSqlServerId -ResourceName $PostgreSqlServerName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -DiagnosticSettingsLogs:$DiagnosticSettingsLogs -DiagnosticSettingsMetrics:$DiagnosticSettingsMetrics 
}

Write-Footer -ScopedPSCmdlet $PSCmdlet