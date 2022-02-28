[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $KeyvaultName,
    [Parameter(Mandatory)][string] $KeyvaultResourceGroupName,
    [Parameter()][System.Object[]] $ResourceTags,
    [Alias('LogAnalyticsWorkspaceName')]
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,

    # VNET Whitelisting
    [Parameter()][string] $ApplicationVnetResourceGroupName,
    [Parameter()][string] $ApplicationVnetName,
    [Parameter()][string] $ApplicationSubnetName,

    # Private Endpoint
    [Alias('VnetResourceGroupName')]
    [Parameter()][string] $KeyvaultPrivateEndpointVnetResourceGroupName,
    [Alias('VnetName')]
    [Parameter()][string] $KeyvaultPrivateEndpointVnetName,
    [Parameter()][string] $KeyvaultPrivateEndpointSubnetName,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Alias('PrivateDnsZoneName')]
    [Parameter()][string] $KeyvaultPrivateDnsZoneName = 'privatelink.vaultcore.azure.net',
    [Parameter()][bool] $KeyvaultPurgeProtectionEnabled = $true,
    [Parameter()][string][ValidateSet('Premium', 'Standard')] $KeyvaultSku = 'Standard',
    [Parameter()][int][ValidateRange(7, 90)] $KeyvaultRetentionInDays = 90,

    # Forcefully agree to this resource to be spun up to be publicly available
    [Parameter()][switch] $ForcePublic,
    
    # Forcefully agree to this resource to be spun up without purge protection
    [Parameter()][switch] $ForceDisablePurgeProtection,

    # Diagnostic settings
    [Parameter()][System.Object[]] $DiagnosticSettingsLogs,
    [Parameter()][System.Object[]] $DiagnosticSettingsMetrics,
    
    # Disable diagnostic settings
    [Parameter()][switch] $DiagnosticSettingsDisabled
    
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ((!$ApplicationVnetResourceGroupName -or !$ApplicationVnetName -or !$ApplicationSubnetName) -and (!$KeyvaultPrivateEndpointVnetResourceGroupName -or !$KeyvaultPrivateEndpointVnetName -or !$KeyvaultPrivateEndpointSubnetName -or !$DNSZoneResourceGroupName -or !$KeyvaultPrivateDnsZoneName))
{
    # Check if we are making this resource public intentionally
    Assert-IntentionallyCreatedPublicResource -ForcePublic $ForcePublic
}

$optionalParameters = @()
if (!$KeyvaultPurgeProtectionEnabled)
{
    # Check if we are agreeing that this resource is being spinned up without purge protection enabled
    Assert-ForceDisableKeyvaultPurgeProtection -ForceDisablePurgeProtection $ForceDisablePurgeProtection -KeyvaultPurgeProtectionEnabled $KeyvaultPurgeProtectionEnabled
}
else
{
    $optionalParameters += '--enable-purge-protection', $KeyvaultPurgeProtectionEnabled    
}

$optionalParameters += '--retention-days', $KeyvaultRetentionInDays

# Warning: az keyvault create is not idempotent: https://github.com/Azure/azure-cli/pull/18520
$subscriptionId = (Invoke-Executable az account show | ConvertFrom-Json).id
$keyvaultExists = (Invoke-Executable az keyvault list --resource-group $KeyvaultResourceGroupName --resource-type 'vault' --subscription $subscriptionId | ConvertFrom-Json) | Where-Object { $_.name -eq $KeyvaultName }

if (!$keyvaultExists)
{
    # check if keyvault exists soft-deleted
    $softDeletedKeyvault = Invoke-Executable -AllowToFail az keyvault show-deleted --name $KeyvaultName | ConvertFrom-Json
    if ($softDeletedKeyvault)
    {
        # Check if the keyvault is in the same resource-group 
        if ($softDeletedKeyvault.properties.vaultId -Match $KeyvaultResourceGroupName)
        {
            Write-Host 'Found soft-deleted keyvault. Recovering..'
            Invoke-Executable az keyvault recover --name $KeyvaultName
        }
        else
        {
            throw 'The vaultname is globally unique and already exists in a soft-deleted state. Purge the keyvault that is in a soft-deleted state, or pick a different name.'
        }
    }
    else
    {
        $keyvaultParameters = @()
        if ($ForcePublic)
        {
            $keyvaultParameters += '--default-action', 'Allow'
        }
        else
        {
            $keyvaultParameters += '--default-action', 'Deny'
        }
        Invoke-Executable az keyvault create --name $KeyvaultName --resource-group $KeyvaultResourceGroupName --sku $KeyvaultSku --bypass None @keyvaultParameters --tags @ResourceTags @optionalParameters
    }
}

# Fetch the Keyvault ID to use while creating the Diagnostics settings in the next step
$keyvaultId = (Invoke-Executable az keyvault show --name $KeyvaultName --resource-group $KeyvaultResourceGroupName | ConvertFrom-Json).id

# Update Tags
if ($ResourceTags)
{
    Set-ResourceTagsForResource -ResourceId $keyvaultId -ResourceTags ${ResourceTags}
}

# Create diagnostics settings for the Keyvault resource
if ($DiagnosticSettingsDisabled)
{
    Remove-DiagnosticSetting -ResourceId $keyvaultId -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $KeyvaultName
}
else
{
    Set-DiagnosticSettings -ResourceId $keyvaultId -ResourceName $KeyvaultName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -DiagnosticSettingsLogs:$DiagnosticSettingsLogs -DiagnosticSettingsMetrics:$DiagnosticSettingsMetrics 
}

# Private Endpoint
if ($KeyvaultPrivateEndpointVnetResourceGroupName -and $KeyvaultPrivateEndpointVnetName -and $KeyvaultPrivateEndpointSubnetName -and $DNSZoneResourceGroupName -and $KeyvaultPrivateDnsZoneName)
{
    Write-Host 'A private endpoint is desired. Adding the needed components.'
    # Fetch information
    $vnetId = (Invoke-Executable az network vnet show --resource-group $KeyvaultPrivateEndpointVnetResourceGroupName --name $KeyvaultPrivateEndpointVnetName | ConvertFrom-Json).id
    $keyvaultPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $KeyvaultPrivateEndpointVnetResourceGroupName --name $KeyvaultPrivateEndpointSubnetName --vnet-name $KeyvaultPrivateEndpointVnetName | ConvertFrom-Json).id
    $keyVaultPrivateEndpointName = "$($KeyvaultName)-pvtkv"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $keyvaultPrivateEndpointSubnetId -PrivateEndpointName $keyVaultPrivateEndpointName -PrivateEndpointResourceGroupName $KeyvaultResourceGroupName -TargetResourceId $keyvaultId -PrivateEndpointGroupId vault -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $KeyvaultPrivateDnsZoneName -PrivateDnsLinkName "$($KeyvaultPrivateEndpointVnetName)-keyvault"
}

# VNET Whitelisting
if ($ApplicationVnetResourceGroupName -and $ApplicationVnetName -and $ApplicationSubnetName)
{
    Write-Host 'VNET Whitelisting is desired. Adding the needed components.'
    
    # Whitelist VNET
    & "$PSScriptRoot\Add-Network-Whitelist-to-Keyvault.ps1" -KeyvaultName $KeyvaultName -KeyvaultResourceGroupName $KeyvaultResourceGroupName -SubnetToWhitelistSubnetName $ApplicationSubnetName -SubnetToWhitelistVnetName $ApplicationVnetName -SubnetToWhitelistVnetResourceGroupName $ApplicationVnetResourceGroupName
}

Write-Footer -ScopedPSCmdlet $PSCmdlet