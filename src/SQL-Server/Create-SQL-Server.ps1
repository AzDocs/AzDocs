[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SqlServerPassword,
    [Parameter(Mandatory)][string] $SqlServerUsername,
    [Parameter(Mandatory)][string] $SqlServerName,
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Alias("LogAnalyticsWorkspaceId")]
    [Parameter()][string] $LogAnalyticsWorkspaceResourceId,
    [Parameter()][ValidateSet('1.0', '1.1', '1.2')][string] $SqlServerMinimalTlsVersion = '1.2',
    [Parameter()][bool] $SqlServerEnablePublicNetwork = $true,

    # VNET Whitelisting Parameters
    [Parameter()][string] $ApplicationVnetResourceGroupName,
    [Parameter()][string] $ApplicationVnetName,
    [Parameter()][string] $ApplicationSubnetName,

    # Private Endpoints
    [Alias("VnetResourceGroupName")]
    [Parameter()][string] $SqlServerPrivateEndpointVnetResourceGroupName,
    [Alias("VnetName")]
    [Parameter()][string] $SqlServerPrivateEndpointVnetName,
    [Parameter()][string] $SqlServerPrivateEndpointSubnetName,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $SqlServerPrivateDnsZoneName = "privatelink.database.windows.net",

    # Forcefully agree to this resource to be spun up to be publicly available
    [Parameter()][switch] $ForcePublic
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ((!$ApplicationVnetResourceGroupName -or !$ApplicationVnetName -or !$ApplicationSubnetName) -and (!$SqlServerPrivateEndpointVnetResourceGroupName -or !$SqlServerPrivateEndpointVnetName -or !$SqlServerPrivateEndpointSubnetName -or !$DNSZoneResourceGroupName -or !$SqlServerPrivateDnsZoneName)) {
    # Check if we are making this resource public intentionally
    Assert-IntentionallyCreatedPublicResource -ForcePublic $ForcePublic
}

# Create SQL Server
if (!(Invoke-Executable -AllowToFail az sql server show --name $SqlServerName --resource-group $SqlServerResourceGroupName)) {
    Invoke-Executable az sql server create --admin-password $SqlServerPassword --admin-user $SqlServerUsername --name $SqlServerName --resource-group $SqlServerResourceGroupName --enable-public-network $SqlServerEnablePublicNetwork --minimal-tls-version $SqlServerMinimalTlsVersion
}

# Fetch the resource id for the just created SQL Server
$sqlServerId = (Invoke-Executable az sql server show --name $SqlServerName --resource-group $SqlServerResourceGroupName | ConvertFrom-Json).id

if ($SqlServerPrivateEndpointVnetResourceGroupName -and $SqlServerPrivateEndpointVnetName -and $SqlServerPrivateEndpointSubnetName -and $DNSZoneResourceGroupName -and $SqlServerPrivateDnsZoneName) {
    Write-Host "A private endpoint is desired. Adding the needed components."
    # Fetch needed information
    $vnetId = (Invoke-Executable az network vnet show --resource-group $SqlServerPrivateEndpointVnetResourceGroupName --name $SqlServerPrivateEndpointVnetName | ConvertFrom-Json).id
    $sqlServerPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $SqlServerPrivateEndpointVnetResourceGroupName --name $SqlServerPrivateEndpointSubnetName --vnet-name $SqlServerPrivateEndpointVnetName | ConvertFrom-Json).id
    $sqlServerPrivateEndpointName = "$($SqlServerName)-pvtsql"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $sqlServerPrivateEndpointSubnetId -PrivateEndpointName $sqlServerPrivateEndpointName -PrivateEndpointResourceGroupName $SqlServerResourceGroupName -TargetResourceId $sqlServerId -PrivateEndpointGroupId sqlServer -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $SqlServerPrivateDnsZoneName -PrivateDnsLinkName "$($SqlServerPrivateEndpointVnetName)-sql"
}


if ($ApplicationVnetResourceGroupName -and $ApplicationVnetName -and $ApplicationSubnetName) {
    #REMOVE OLD NAMES
    $oldAccessRuleName = "$($ApplicationVnetName)_$($ApplicationSubnetName)_allow"
    Remove-VnetRulesIfExists -ServiceType 'sql' -ResourceGroupName $SqlServerResourceGroupName -ResourceName $SqlServerName -AccessRuleName $oldAccessRuleName
    # END REMOVE OLD NAMES

    Write-Host "VNET Whitelisting is desired. Adding the needed components."
    
    # Whitelist VNET
    & "$PSScriptRoot\Add-Network-Whitelist-to-Sql-Server.ps1" -SqlServerName $SqlServerName -SqlServerResourceGroupName $SqlServerResourceGroupName -SubnetToWhitelistSubnetName $ApplicationSubnetName -SubnetToWhitelistVnetName $ApplicationVnetName -SubnetToWhitelistVnetResourceGroupName $ApplicationVnetResourceGroupName
}

if ($LogAnalyticsWorkspaceResourceId) {
    # Fetch subscription name
    $subscriptionName = (az account show | ConvertFrom-Json).name

    # Set auditing policy on SQL server
    Install-Module PowerShellGet -Force
    Install-Module -Name Az.Sql -Force
    $encryptedPassword = ConvertTo-SecureString -String $env:servicePrincipalKey -AsPlainText
    $pscredential = [PSCredential]::new($env:servicePrincipalId, $encryptedPassword)
    Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $env:tenantId -Subscription $subscriptionName
    Set-AzSqlServerAudit -ResourceGroupName $SqlServerResourceGroupName -ServerName $SqlServerName -LogAnalyticsTargetState Enabled -WorkspaceResourceId $LogAnalyticsWorkspaceResourceId
}

Write-Footer -ScopedPSCmdlet $PSCmdlet