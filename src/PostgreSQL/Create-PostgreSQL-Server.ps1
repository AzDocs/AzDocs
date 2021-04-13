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
    [Parameter()][string] $PostgreSqlServerPrivateDnsZoneName = "privatelink.postgres.database.azure.com"
    
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$resourceGroupLocation = (az group show --name $PostgreSqlServerResourceGroupName | ConvertFrom-Json).location

Write-Host "Found location $($resourceGroupLocation)"
# Create PSQL Server if it does not exist
if(!$((Invoke-Executable -AllowToFail az postgres server show --name $PostgreSqlServerName --resource-group $PostgreSqlServerResourceGroupName | ConvertFrom-Json).Id))
{
    Write-Host "Creating Postgres server"
    Invoke-Executable az postgres server create --admin-password $PostgreSqlServerPassword --admin-user $PostgreSqlServerUsername --name $PostgreSqlServerName --resource-group $PostgreSqlServerResourceGroupName --location $resourceGroupLocation --sku-name $PostgreSqlServerSku --backup-retention $BackupRetentionInDays --assign-identity --public-network-access Disabled --version $PostgreSqlServerVersion
}

# VNET Whitelisting
if($ApplicationVnetResourceGroupName -and $ApplicationVnetName -and $ApplicationSubnetName)
{
    # Fetch the Application's Subnet ID
    $applicationSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ApplicationVnetResourceGroupName --name $ApplicationSubnetName --vnet-name $ApplicationVnetName | ConvertFrom-Json).id

    # Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
    Set-SubnetServiceEndpoint -SubnetResourceId $applicationSubnetId -ServiceEndpointServiceIdentifier "Microsoft.Sql"

    # Create VNET Whitelist rule
    $firewallRuleName = ToMd5Hash -InputString "$($ApplicationVnetName)_$($ApplicationSubnetName)_allow"
    az postgres server vnet-rule create --resource-group $PostgreSqlServerResourceGroupName --server-name $PostgreSqlServerName --name $firewallRuleName --subnet $applicationSubnetId
}

# Private Endpoint
if($PostgreSqlServerPrivateEndpointVnetResourceGroupName -and $PostgreSqlServerPrivateEndpointVnetName -and $PostgreSqlServerPrivateEndpointSubnetName -and $DNSZoneResourceGroupName -and $PostgreSqlServerPrivateDnsZoneName)
{
    $vnetId = (Invoke-Executable az network vnet show --resource-group $PostgreSqlServerPrivateEndpointVnetResourceGroupName --name $PostgreSqlServerPrivateEndpointVnetName | ConvertFrom-Json).id
    $sqlServerPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $PostgreSqlServerPrivateEndpointVnetResourceGroupName --name $PostgreSqlServerPrivateEndpointSubnetName --vnet-name $PostgreSqlServerPrivateEndpointVnetName | ConvertFrom-Json).id
    $sqlServerPrivateEndpointName = "$($PostgreSqlServerName)-pvtpsql"

    # Fetch the resource id for the just created SQL Server
    $postgreSqlServerId = (Invoke-Executable az postgres server show --name $PostgreSqlServerName --resource-group $PostgreSqlServerResourceGroupName | ConvertFrom-Json).id

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $sqlServerPrivateEndpointSubnetId -PrivateEndpointName $sqlServerPrivateEndpointName -PrivateEndpointResourceGroupName $PostgreSqlServerResourceGroupName -TargetResourceId $postgreSqlServerId -PrivateEndpointGroupId postgresqlServer -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $PostgreSqlServerPrivateDnsZoneName -PrivateDnsLinkName "$($PostgreSqlServerPrivateEndpointVnetName)-psql"
}

Write-Footer -ScopedPSCmdlet $PSCmdlet