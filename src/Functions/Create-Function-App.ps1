[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    [Parameter(Mandatory)][string] $AppServicePlanName,
    [Parameter(Mandatory)][string] $AppServicePlanResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Parameter(Mandatory)][string] $FunctionAppStorageAccountName,
    [Alias('LogAnalyticsWorkspaceName')]
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    [Alias('AlwaysOn')]
    [Parameter()][bool] $FunctionAppAlwaysOn = $true,
    [Parameter(Mandatory)][string] $FUNCTIONS_EXTENSION_VERSION,
    [Parameter(Mandatory)][string] $ASPNETCORE_ENVIRONMENT,
    [Parameter()][string] $FunctionAppNumberOfInstances = 2,
    [Parameter()][ValidateSet('dotnet-isolated', 'dotnet', 'node', 'python', 'custom', 'java', 'powershell')][string] $FunctionAppRuntime = 'dotnet',
    [Parameter()][System.Object[]] $ResourceTags,
    [Parameter(Mandatory)][ValidateSet('Linux', 'Windows')][string] $FunctionAppOSType,
    [Parameter()][string][ValidateSet('1.0', '1.1', '1.2')] $FunctionAppMinimalTlsVersion = '1.2',
    [Parameter()][bool] $StopFunctionAppImmediatelyAfterCreation = $false,
    [Parameter()][bool] $StopFunctionAppSlotImmediatelyAfterCreation = $false,

    # Deployment Slots
    [Parameter(ParameterSetName = 'DeploymentSlot')][switch] $EnableFunctionAppDeploymentSlot,
    [Parameter(ParameterSetName = 'DeploymentSlot')][string] $FunctionAppDeploymentSlotName = 'staging',
    [Parameter(ParameterSetName = 'DeploymentSlot')][bool] $DisablePublicAccessForFunctionAppDeploymentSlot = $true,
    [Parameter(ParameterSetName = 'DeploymentSlot')][switch] $DisableVNetWhitelistForDeploymentSlot,
    [Parameter(ParameterSetName = 'DeploymentSlot')][switch] $DisablePrivateEndpointForDeploymentSlot,

    # VNET Whitelisting Parameters
    [Parameter()][string] $GatewayVnetResourceGroupName,
    [Parameter()][string] $GatewayVnetName,
    [Parameter()][string] $GatewaySubnetName,
    [Parameter()][string] $GatewayWhitelistRulePriority = 20,

    # Private Endpoint
    [Alias('VnetResourceGroupName')]
    [Parameter()][string] $FunctionAppPrivateEndpointVnetResourceGroupName,
    [Alias('VnetName')]
    [Parameter()][string] $FunctionAppPrivateEndpointVnetName,
    [Parameter()][string] $FunctionAppPrivateEndpointSubnetName,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Alias('PrivateDnsZoneName')]
    [Parameter()][string] $FunctionAppPrivateDnsZoneName = 'privatelink.azurewebsites.net',

    # Forcefully agree to this resource to be spun up to be publicly available
    [Parameter()][switch] $ForcePublic,

    # Diagnostic settings
    [Parameter()][System.Object[]] $DiagnosticSettingsLogs,
    [Parameter()][System.Object[]] $DiagnosticSettingsMetrics,
    
    # Disable diagnostic settings
    [Parameter()][switch] $DiagnosticSettingsDisabled,

    # Acknowledge that the website for additional slots are truncated
    [Parameter()][switch] $SuppressTruncatedSiteName,

    # CORS urls to set, please note that the default portal urls are added by default, to disable them use the -DisableCORSPortalTestUrls switch
    [Parameter()][string[]] $CORSUrls = @(),

    # By default the portal urls are added to the cors settings. Use this switch to remove the azure portal test urls so you cannot run a function from the portal anymore.
    [Parameter()][switch] $DisableCORSPortalTestUrls,

    # Optional remaining arguments. This is a fix for being able to pass down parameters in an easy way using @PSBoundParameters in Create-Function-App-with-App-Service-Plan-Linux.ps1
    [Parameter(ValueFromRemainingArguments)][string[]] $Remaining
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($FunctionAppName.Length -gt 40)
{
    Write-Warning 'Please note that the App Service name is longer than 40 characters. This can give some unexpected urls for additional slots.'
    Write-Warning 'See last paragraph of https://docs.microsoft.com/en-us/azure/app-service/deploy-staging-slots#add-a-slot.'
    if (!$SuppressTruncatedSiteName)
    {
        Write-Host '##vso[task.complete result=SucceededWithIssues;]'
    } 
}

if ((!$GatewayVnetResourceGroupName -or !$GatewayVnetName -or !$GatewaySubnetName -or !$GatewayWhitelistRulePriority) -and (!$FunctionAppPrivateEndpointVnetResourceGroupName -or !$FunctionAppPrivateEndpointVnetName -or !$FunctionAppPrivateEndpointSubnetName -or !$DNSZoneResourceGroupName -or !$FunctionAppPrivateDnsZoneName))
{
    # Check if we are making this resource public intentionally
    Assert-IntentionallyCreatedPublicResource -ForcePublic $ForcePublic
}

# Check TLS Version
Assert-TLSVersion -TlsVersion $FunctionAppMinimalTlsVersion

# Fetch AppService Plan ID
$appServicePlan = (Invoke-Executable az appservice plan show --resource-group $AppServicePlanResourceGroupName --name $AppServicePlanName | ConvertFrom-Json)

# Fetch the ID from the FunctionApp
$functionAppId = (Invoke-Executable -AllowToFail az functionapp show --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json).id

#TODO: az functionapp create is not idempotent, therefore the following fix. For more information, see https://github.com/Azure/azure-cli/issues/11863
if (!$functionAppId)
{
    # Create FunctionApp
    Invoke-Executable az functionapp create --name $FunctionAppName --plan $appServicePlan.id --os-type $FunctionAppOSType --resource-group $FunctionAppResourceGroupName --storage-account $FunctionAppStorageAccountName --runtime $FunctionAppRuntime --functions-version 3 --disable-app-insights --tags @ResourceTags
    $functionAppId = (Invoke-Executable az functionapp show --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json).id
}

# Immediately stop functionapp after creation
if ($StopFunctionAppImmediatelyAfterCreation)
{
    Invoke-Executable az functionapp stop --name $FunctionAppName --resource-group $FunctionAppResourceGroupName
}

# Update Tags
if ($ResourceTags)
{
    Set-ResourceTagsForResource -ResourceId $functionAppId -ResourceTags ${ResourceTags}
}

# Enforce HTTPS
Invoke-Executable az functionapp update --ids $functionAppId --set httpsOnly=true

# Set Always On, the number of instances and the ftps-state to disable
Invoke-Executable az functionapp config set --ids $functionAppId --always-on $FunctionAppAlwaysOn --number-of-workers $FunctionAppNumberOfInstances --ftps-state Disabled --min-tls-version $FunctionAppMinimalTlsVersion

# Set some basic configs (including vnet route all)
Invoke-Executable az functionapp config appsettings set --ids $functionAppId --settings "ASPNETCORE_ENVIRONMENT=$($ASPNETCORE_ENVIRONMENT)" "FUNCTIONS_EXTENSION_VERSION=$($FUNCTIONS_EXTENSION_VERSION)"

#  Create diagnostics settings
if ($DiagnosticSettingsDisabled)
{
    Remove-DiagnosticSetting -ResourceId $functionAppId -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $FunctionAppName
}
else
{
    Set-DiagnosticSettings -ResourceId $functionAppId -ResourceName $FunctionAppName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -DiagnosticSettingsLogs:$DiagnosticSettingsLogs -DiagnosticSettingsMetrics:$DiagnosticSettingsMetrics 
}

# Create & Assign WebApp identity to AppService
Invoke-Executable az functionapp identity assign --ids $functionAppId

# set CORS settings, Does not work with deployment slots https://github.com/Azure/azure-cli/issues/20385
if (!$DisableCORSPortalTestUrls)
{
    $CORSUrls += 'https://functions.azure.com'
    $CORSUrls += 'https://functions-staging.azure.com'
    $CORSUrls += 'https://functions-next.azure.com'
}

$currentCorsSettings = Invoke-Executable az functionapp cors show --ids $functionAppId | ConvertFrom-Json

[string[]]$currentCorsOrigins = @()
if ($currentCorsSettings -and $currentCorsSettings.allowedOrigins)
{
    $currentCorsOrigins = $currentCorsSettings.allowedOrigins
}

Compare-Object -ReferenceObject $currentCorsOrigins -DifferenceObject $CORSUrls | ForEach-Object {
    $value = $_.InputObject
    $sideIndicator = $_.SideIndicator
    switch ($sideIndicator)
    {
        '=>'
        { 
            
            Write-Host "Adding CORS URL $value"
            Invoke-Executable az functionapp cors add --ids $functionAppId --allowed-origins $value
        }
        '<='
        {
            Write-Host "Removing CORS URL $value"
            Invoke-Executable az functionapp cors remove --ids $functionAppId --allowed-origins $value
        }
    }
}

# Create Deployment Slot
if ($EnableFunctionAppDeploymentSlot)
{
    $parametersForDeploymentSlot = @{ 
        AppType                                      = 'functionapp'; 
        ResourceResourceGroupName                    = $FunctionAppResourceGroupName;    
        ResourceName                                 = $FunctionAppName; 
        ResourceDeploymentSlotName                   = $FunctionAppDeploymentSlotName;
        LogAnalyticsWorkspaceResourceId              = $LogAnalyticsWorkspaceResourceId;
        StopResourceSlotImmediatelyAfterCreation     = $StopFunctionAppSlotImmediatelyAfterCreation;
        ResourceTags                                 = ${ResourceTags};
        ResourceAlwaysOn                             = $FunctionAppAlwaysOn;
        ResourceMinimalTlsVersion                    = $FunctionAppMinimalTlsVersion;
        DisablePublicAccessForResourceDeploymentSlot = $DisablePublicAccessForFunctionAppDeploymentSlot;
        ForcePublic                                  = $ForcePublic;
        GatewayVnetResourceGroupName                 = $GatewayVnetResourceGroupName;
        GatewayVnetName                              = $GatewayVnetName;
        GatewaySubnetName                            = $GatewaySubnetName;
        GatewayWhitelistRulePriority                 = $GatewayWhitelistRulePriority;
        ResourcePrivateEndpointVnetResourceGroupName = $FunctionAppPrivateEndpointVnetResourceGroupName;
        ResourcePrivateEndpointVnetName              = $FunctionAppPrivateEndpointVnetName;
        ResourcePrivateEndpointSubnetName            = $FunctionAppPrivateEndpointSubnetName;
        DNSZoneResourceGroupName                     = $DNSZoneResourceGroupName;
        ResourcePrivateDnsZoneName                   = $FunctionAppPrivateDnsZoneName;
        ResourceDisableVNetWhitelisting              = $DisableVNetWhitelistForDeploymentSlot;
        ResourceDisablePrivateEndpoints              = $DisablePrivateEndpointForDeploymentSlot;
        DiagnosticSettingsLogs                       = $DiagnosticSettingsLogs;
        DiagnosticSettingsMetrics                    = $DiagnosticSettingsMetrics;
        DiagnosticSettingsDisabled                   = $DiagnosticSettingsDisabled;
    }

    New-DeploymentSlot @parametersForDeploymentSlot
}

# VNET Whitelisting
if ($GatewayVnetResourceGroupName -and $GatewayVnetName -and $GatewaySubnetName)
{
    # REMOVE OLD NAMES
    $oldAccessRestrictionRuleName = ToMd5Hash -InputString "$($GatewayVnetName)_$($GatewaySubnetName)_allow"
    Remove-AccessRestrictionIfExists -AppType functionapp -ResourceGroupName $FunctionAppResourceGroupName -ResourceName $FunctionAppName -AccessRestrictionRuleName $oldAccessRestrictionRuleName -AutoGeneratedAccessRestrictionRuleName $False
    # END REMOVE OLD NAMES

    Write-Host 'VNET Whitelisting is desired. Adding the needed components.'

    # Whitelist VNET
    & "$PSScriptRoot\Add-Network-Whitelist-to-Function-App.ps1" -FunctionAppResourceGroupName $FunctionAppResourceGroupName -FunctionAppName $FunctionAppName -AccessRestrictionRuleDescription:$FunctionAppName -Priority $GatewayWhitelistRulePriority -ApplyToMainEntrypoint $true -ApplyToScmEntryPoint $true -SubnetToWhitelistSubnetName $GatewaySubnetName -SubnetToWhitelistVnetName $GatewayVnetName -SubnetToWhitelistVnetResourceGroupName $GatewayVnetResourceGroupName
}

# Add private endpoint & Setup Private DNS
if ($FunctionAppPrivateEndpointVnetResourceGroupName -and $FunctionAppPrivateEndpointVnetName -and $FunctionAppPrivateEndpointSubnetName -and $DNSZoneResourceGroupName -and $FunctionAppPrivateDnsZoneName)
{
    Write-Host 'A private endpoint is desired. Adding the needed components.'
    # Fetch needed information
    $vnetId = (Invoke-Executable az network vnet show --resource-group $FunctionAppPrivateEndpointVnetResourceGroupName --name $FunctionAppPrivateEndpointVnetName | ConvertFrom-Json).id
    $functionAppPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $FunctionAppPrivateEndpointVnetResourceGroupName --name $FunctionAppPrivateEndpointSubnetName --vnet-name $FunctionAppPrivateEndpointVnetName | ConvertFrom-Json).id
    $functionAppPrivateEndpointName = "$($FunctionAppName)-pvtfunc"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $functionAppPrivateEndpointSubnetId -PrivateEndpointName $functionAppPrivateEndpointName -PrivateEndpointResourceGroupName $FunctionAppResourceGroupName -TargetResourceId $functionAppId -PrivateEndpointGroupId sites -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $FunctionAppPrivateDnsZoneName -PrivateDnsLinkName "$($FunctionAppPrivateEndpointVnetName)-appservice"
}

Write-Footer -ScopedPSCmdlet $PSCmdlet