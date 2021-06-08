[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $MySqlServerLocation,
    [Parameter(Mandatory)][string] $MySqlServerName,
    [Parameter(Mandatory)][string] $MySqlServerUsername,
    [Parameter(Mandatory)][string] $MySqlServerPassword,
    [Parameter(Mandatory)][string] $MySqlServerResourceGroupName,
    [Parameter(Mandatory)][string] $MySqlServerSkuName,
    [Parameter(Mandatory)][string] $MySqlServerStorageSizeInMB,
    [Parameter(Mandatory)][System.Object[]] $ResourceTags,
    [Parameter()][ValidateSet('', 'TLS1_0', 'TLS1_1', 'TLS1_2', 'TLSEnforcementDisabled')][string] $MySqlServerMinimalTlsVersion = 'TLS1_2',
    # YES I KNOW. BUT THE CLI DOES NOT UNDERSTAND $FALSE & $TRUE :(
    [Parameter()][ValidateSet('Enabled', 'Disabled')][string] $MySqlServerSslEnforcement = 'Enabled',

    # VNET Whitelisting Parameters
    [Parameter()][string] $ApplicationVnetResourceGroupName,
    [Parameter()][string] $ApplicationVnetName,
    [Parameter()][string] $ApplicationSubnetName,

    # Private Endpoints
    [Parameter()][string] $MySqlServerPrivateEndpointVnetResourceGroupName,
    [Parameter()][string] $MySqlServerPrivateEndpointVnetName,
    [Parameter()][string] $MySqlServerPrivateEndpointSubnetName,
    [Parameter()][string] $MySqlServerPrivateDnsZoneName = 'privatelink.mysql.database.azure.com',
    [Parameter()][string] $DNSZoneResourceGroupName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Create MySQL Server.
if (!(Invoke-Executable -AllowToFail az mysql server show --name $MySqlServerName --resource-group $MySqlServerResourceGroupName))
{
    $additionalParameters = @()
    if ($MySqlServerMinimalTlsVersion)
    {
        $additionalParameters += '--minimal-tls-version', $MySqlServerMinimalTlsVersion
    }
    Invoke-Executable az mysql server create --admin-password $MySqlServerPassword --admin-user $MySqlServerUsername --name $MySqlServerName --resource-group $MySqlServerResourceGroupName --sku-name $MySqlServerSkuName --storage-size $MySqlServerStorageSizeInMB --ssl-enforcement $MySqlServerSslEnforcement --location $MySqlServerLocation --tags ${ResourceTags} @additionalParameters
}

if ($MySqlServerPrivateEndpointVnetResourceGroupName -and $MySqlServerPrivateEndpointVnetName -and $MySqlServerPrivateEndpointSubnetName -and $MySqlServerPrivateDnsZoneName -and $DNSZoneResourceGroupName)
{
    Write-Host "A private endpoint is desired. Adding the needed components."
    # Fetch needed information
    $mySqlServerResourceId = (Invoke-Executable az mysql server show --name $MySqlServerName --resource-group $MySqlServerResourceGroupName | ConvertFrom-Json).id
    $vnetId = (Invoke-Executable az network vnet show --resource-group $MySqlServerPrivateEndpointVnetResourceGroupName --name $MySqlServerPrivateEndpointVnetName | ConvertFrom-Json).id
    $sqlServerPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $MySqlServerPrivateEndpointVnetResourceGroupName --name $MySqlServerPrivateEndpointSubnetName --vnet-name $MySqlServerPrivateEndpointVnetName | ConvertFrom-Json).id
    $sqlServerPrivateEndpointName = "$($MySqlServerName)-pvtmysql"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $sqlServerPrivateEndpointSubnetId -PrivateEndpointName $sqlServerPrivateEndpointName -PrivateEndpointResourceGroupName $MySqlServerResourceGroupName -TargetResourceId $mySqlServerResourceId -PrivateEndpointGroupId mysqlServer -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $MySqlServerPrivateDnsZoneName -PrivateDnsLinkName "$($MySqlServerPrivateEndpointVnetName)-mysql"
}

if ($ApplicationVnetResourceGroupName -and $ApplicationVnetName -and $ApplicationSubnetName)
{
    # REMOVE OLD NAMES
    $oldAccessRuleName = "$($ApplicationVnetName)_$($ApplicationSubnetName)_allow"
    Remove-VnetRulesIfExists -ServiceType 'mysql' -ResourceGroupName $MySqlServerResourceGroupName -ResourceName $MySqlServerName -AccessRuleName $oldAccessRuleName
    # END REMOVE OLD NAMES

    Write-Host "VNET Whitelisting is desired. Adding the needed components."
    
    # Whitelist VNET
    & "$PSScriptRoot\Add-Network-Whitelist-to-MySQL.ps1" -MySqlServerName $MySqlServerName -MySqlServerResourceGroupName $MySqlServerResourceGroupName -SubnetToWhitelistSubnetName $ApplicationSubnetName -SubnetToWhitelistVnetName $ApplicationVnetName -SubnetToWhitelistVnetResourceGroupName $ApplicationVnetResourceGroupName

    # Write-Host "VNET Whitelisting is desired. Adding the needed components."
    # # Fetch the Subnet ID where the Application Resides in
    # $applicationSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ApplicationVnetResourceGroupName --name $ApplicationSubnetName --vnet-name $ApplicationVnetName | ConvertFrom-Json).id

    # # Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET (I think we need Microsoft.Sql? Microsoft.DBforMySQL doesnt seem to be a valid option)
    # #Set-SubnetServiceEndpoint -SubnetResourceId $applicationSubnetId -ServiceEndpointServiceIdentifier "Microsoft.DBforMySQL"
    # Set-SubnetServiceEndpoint -SubnetResourceId $applicationSubnetId -ServiceEndpointServiceIdentifier "Microsoft.Sql"

    # # Allow the Application Subnet to this MySQL Server through a vnet-rule
    # Invoke-Executable az mysql server vnet-rule create --server-name $MySqlServerName --name "$($ApplicationVnetName)_$($ApplicationSubnetName)_allow" --resource-group $MySqlServerResourceGroupName --subnet $applicationSubnetId
}

Write-Footer -ScopedPSCmdlet $PSCmdlet