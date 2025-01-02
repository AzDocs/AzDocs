[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppServicePlanName,
    [Parameter(Mandatory)][string] $AppServicePlanResourceGroupName,
    [Parameter(Mandatory)][string] $LogicAppResourceGroupName,
    [Parameter(Mandatory)][string] $LogicAppName,
    [Parameter(Mandatory)][string] $LogicAppStorageAccountName,
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    [Parameter()][System.Object[]] $ResourceTags,
    [Parameter()][bool] $StopLogicAppImmediatelyAfterCreation = $false,
    [Parameter()][bool] $StopLogicAppSlotImmediatelyAfterCreation = $false,
    [Parameter()][string][ValidateSet('1.0', '1.1', '1.2')] $LogicAppMinimalTlsVersion = '1.2',
    [Parameter()][string] $AppInsightsName,
    [Parameter()][string] $AppInsightsResourceGroupName,

    # VNET Whitelisting Parameters
    [Parameter()][string] $GatewayVnetResourceGroupName,
    [Parameter()][string] $GatewayVnetName,
    [Parameter()][string] $GatewaySubnetName,
    [Parameter()][string] $GatewayWhitelistRulePriority = 20,

    # Private Endpoint
    [Parameter()][string] $LogicAppPrivateEndpointVnetResourceGroupName,
    [Parameter()][string] $LogicAppPrivateEndpointVnetName,
    [Parameter()][string] $LogicAppPrivateEndpointSubnetName,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Parameter()][string] $LogicAppPrivateDnsZoneName = 'privatelink.azurewebsites.net',
    [Parameter()][bool] $SkipDnsZoneConfiguration = $false,

    # Forcefully agree to this resource to be spun up to be publicly available
    [Parameter()][switch] $ForcePublic,

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

Invoke-Executable az config set extension.use_dynamic_install=yes_without_prompt
if ((!$GatewayVnetResourceGroupName -or !$GatewayVnetName -or !$GatewaySubnetName -or !$GatewayWhitelistRulePriority) -and (!$LogicAppPrivateEndpointVnetResourceGroupName -or !$LogicAppPrivateEndpointVnetName -or !$LogicAppPrivateEndpointSubnetName -or !$DNSZoneResourceGroupName -or !$LogicAppPrivateDnsZoneName))
{
    # Check if we are making this resource public intentionally
    Assert-IntentionallyCreatedPublicResource -ForcePublic $ForcePublic
}

# Check TLS Version
Assert-TLSVersion -TlsVersion $LogicAppMinimalTlsVersion
 
# Fetch AppService Plan ID
$appServicePlan = (Invoke-Executable az appservice plan show --resource-group $AppServicePlanResourceGroupName --name $AppServicePlanName | ConvertFrom-Json)

$optionalParameters = @() 
if ($AppInsightsName -and $AppInsightsResourceGroupName)
{
    $appInsightsKey = (Invoke-Executable az monitor app-insights component show --app $AppInsightsName --resource-group $AppInsightsResourceGroupName | ConvertFrom-Json).instrumentationKey
    $optionalParameters += '--app-insights-key', $appInsightsKey
}
else
{
    $optionalParameters += '--disable-app-insights'
}

# Create Logic App
$logicAppId = (Invoke-Executable az logicapp create --name $LogicAppName --resource-group $LogicAppResourceGroupName --plan $appServicePlan.id --storage-account $LogicAppStorageAccountName --tags @ResourceTags @optionalParameters | ConvertFrom-Json).id

# Immediately stop logicapp after creation
if ($StopLogicAppImmediatelyAfterCreation)
{
    Invoke-Executable az logicapp stop --name $LogicAppName --resource-group $LogicAppResourceGroupName
}

# Update Tags
if ($ResourceTags)
{
    Set-ResourceTagsForResource -ResourceId $logicAppId -ResourceTags ${ResourceTags}
}

# Create & Assign WebApp identity to AppService
Invoke-Executable az functionapp identity assign --ids $logicAppId

# Enforce HTTPS
Invoke-Executable az functionapp update --name $LogicAppName --resource-group $LogicAppResourceGroupName --set httpsOnly=true

# Set Always On, the number of instances and the ftps-state to disable
Invoke-Executable az functionapp config set --name $LogicAppName --resource-group $LogicAppResourceGroupName --ftps-state Disabled --min-tls-version $LogicAppMinimalTlsVersion

#  Create diagnostics settings
if ($DiagnosticSettingsDisabled)
{
    Remove-DiagnosticSetting -ResourceId $logicAppId -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $LogicAppName
}
else
{
    Set-DiagnosticSettings -ResourceId $logicAppId -ResourceName $LogicAppName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -DiagnosticSettingsLogs:$DiagnosticSettingsLogs -DiagnosticSettingsMetrics:$DiagnosticSettingsMetrics 
}

# VNET Whitelisting
if ($GatewayVnetResourceGroupName -and $GatewayVnetName -and $GatewaySubnetName)
{
    Write-Host 'VNET Whitelisting is desired. Adding the needed components.'

    # Whitelist VNET
    $RootPath = (Get-Item $PSScriptRoot).Parent
    & "$RootPath\Functions\Add-Network-Whitelist-to-Function-App.ps1" -FunctionAppResourceGroupName $LogicAppResourceGroupName -FunctionAppName $LogicAppName -AccessRestrictionRuleDescription:$LogicppName -Priority $GatewayWhitelistRulePriority -ApplyToMainEntrypoint $true -ApplyToScmEntryPoint $true -SubnetToWhitelistSubnetName $GatewaySubnetName -SubnetToWhitelistVnetName $GatewayVnetName -SubnetToWhitelistVnetResourceGroupName $GatewayVnetResourceGroupName
}

# Add private endpoint & Setup Private DNS
if ($LogicAppPrivateEndpointVnetResourceGroupName -and $LogicAppPrivateEndpointVnetName -and $LogicAppPrivateEndpointSubnetName -and $DNSZoneResourceGroupName -and $LogicAppPrivateDnsZoneName)
{
    Write-Host 'A private endpoint is desired. Adding the needed components.'
    # Fetch needed information
    $vnetId = (Invoke-Executable az network vnet show --resource-group $LogicAppPrivateEndpointVnetResourceGroupName --name $LogicAppPrivateEndpointVnetName | ConvertFrom-Json).id
    $functionAppPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $LogicAppPrivateEndpointVnetResourceGroupName --name $LogicAppPrivateEndpointSubnetName --vnet-name $LogicAppPrivateEndpointVnetName | ConvertFrom-Json).id
    $functionAppPrivateEndpointName = "$($LogicAppName)-pvtlapp"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $functionAppPrivateEndpointSubnetId -PrivateEndpointName $functionAppPrivateEndpointName -PrivateEndpointResourceGroupName $LogicAppResourceGroupName -TargetResourceId $logicAppId -PrivateEndpointGroupId sites -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $LogicAppPrivateDnsZoneName -PrivateDnsLinkName "$($LogicAppPrivateEndpointVnetName)-appservice" -SkipDnsZoneConfiguration $SkipDnsZoneConfiguration
}

Write-Footer -ScopedPSCmdlet $PSCmdlet