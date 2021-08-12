[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    [Parameter(Mandatory)][string] $AppServicePlanName,
    [Parameter(Mandatory)][string] $AppServicePlanResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Parameter(Mandatory)][string] $FunctionAppStorageAccountName,
    [Alias("LogAnalyticsWorkspaceName")]
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    [Alias("AlwaysOn")]
    [Parameter(Mandatory)][string] $FunctionAppAlwaysOn,
    [Parameter(Mandatory)][string] $FUNCTIONS_EXTENSION_VERSION,
    [Parameter(Mandatory)][string] $ASPNETCORE_ENVIRONMENT,
    [Parameter()][string] $FunctionAppNumberOfInstances = 2,
    [Parameter()][ValidateSet("dotnet-isolated", "dotnet", "node", "python", "custom", "java", "powershell")][string] $FunctionAppRuntime = "dotnet",
    [Parameter()][System.Object[]] $ResourceTags,
    [Parameter(Mandatory)][ValidateSet("Linux", "Windows")][string] $FunctionAppOSType,
    [Parameter()][string][ValidateSet("1.0", "1.1", "1.2")] $FunctionAppMinimalTlsVersion = "1.2",

    # Deployment Slots
    [Parameter(ParameterSetName = 'DeploymentSlot')][switch] $EnableFunctionAppDeploymentSlot,
    [Parameter(ParameterSetName = 'DeploymentSlot')][string] $FunctionAppDeploymentSlotName = "staging",
    [Parameter(ParameterSetName = 'DeploymentSlot')][bool] $DisablePublicAccessForFunctionAppDeploymentSlot = $true,

    # VNET Whitelisting Parameters
    [Parameter()][string] $GatewayVnetResourceGroupName,
    [Parameter()][string] $GatewayVnetName,
    [Parameter()][string] $GatewaySubnetName,
    [Parameter()][string] $GatewayWhitelistRulePriority = 20,

    # Private Endpoint
    [Alias("VnetResourceGroupName")]
    [Parameter()][string] $FunctionAppPrivateEndpointVnetResourceGroupName,
    [Alias("VnetName")]
    [Parameter()][string] $FunctionAppPrivateEndpointVnetName,
    [Parameter()][string] $FunctionAppPrivateEndpointSubnetName,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $FunctionAppPrivateDnsZoneName = "privatelink.azurewebsites.net",

    # Forcefully agree to this resource to be spun up to be publicly available
    [Parameter()][switch] $ForcePublic,

    # Optional remaining arguments. This is a fix for being able to pass down parameters in an easy way using @PSBoundParameters in Create-Function-App-with-App-Service-Plan-Linux.ps1
    [Parameter(ValueFromRemainingArguments)][string[]] $Remaining
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ((!$GatewayVnetResourceGroupName -or !$GatewayVnetName -or !$GatewaySubnetName -or !$GatewayWhitelistRulePriority) -and (!$FunctionAppPrivateEndpointVnetResourceGroupName -or !$FunctionAppPrivateEndpointVnetName -or !$FunctionAppPrivateEndpointSubnetName -or !$DNSZoneResourceGroupName -or !$FunctionAppPrivateDnsZoneName))
{
    # Check if we are making this resource public intentionally
    Assert-IntentionallyCreatedPublicResource -ForcePublic $ForcePublic
}

# Check TLS Version
Assert-TLSVersion -TlsVersion $FunctionAppMinimalTlsVersion

# Fetch AppService Plan ID
$appServicePlanId = (Invoke-Executable az appservice plan show --resource-group $AppServicePlanResourceGroupName --name $AppServicePlanName | ConvertFrom-Json).id

# Fetch the ID from the FunctionApp
$functionAppId = (Invoke-Executable -AllowToFail az functionapp show --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json).id

#TODO: az functionapp create is not idempotent, therefore the following fix. For more information, see https://github.com/Azure/azure-cli/issues/11863
if (!$functionAppId)
{
    # Create FunctionApp
    Invoke-Executable az functionapp create --name $FunctionAppName --plan $appServicePlanId --os-type $FunctionAppOSType --resource-group $FunctionAppResourceGroupName --storage-account $FunctionAppStorageAccountName --runtime $FunctionAppRuntime --functions-version 3 --disable-app-insights --tags ${ResourceTags}
    $functionAppId = (Invoke-Executable az functionapp show --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json).id
}

# Update Tags
Set-ResourceTagsForResource -ResourceId $functionAppId -ResourceTags ${ResourceTags}

# Enforce HTTPS
Invoke-Executable az functionapp update --ids $functionAppId --set httpsOnly=true

# Set Always On, the number of instances and the ftps-state to disable
Invoke-Executable az functionapp config set --ids $functionAppId --always-on $FunctionAppAlwaysOn --number-of-workers $FunctionAppNumberOfInstances --ftps-state Disabled --min-tls-version $FunctionAppMinimalTlsVersion

# Set some basic configs (including vnet route all)
Invoke-Executable az functionapp config appsettings set --ids $functionAppId --settings "ASPNETCORE_ENVIRONMENT=$($ASPNETCORE_ENVIRONMENT)" "FUNCTIONS_EXTENSION_VERSION=$($FUNCTIONS_EXTENSION_VERSION)"

#  Create diagnostics settings
Set-DiagnosticSettings -ResourceId $functionAppId -ResourceName $FunctionAppName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -Logs "[{ 'category': 'FunctionAppLogs', 'enabled': true } ]".Replace("'", '\"') -Metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')

# Create & Assign WebApp identity to AppService
Invoke-Executable az functionapp identity assign --ids $functionAppId

# By default a staging slot will be added
if ($EnableFunctionAppDeploymentSlot)
{
    # Create deployment slot 
    Invoke-Executable az functionapp deployment slot create --resource-group $FunctionAppResourceGroupName --name $FunctionAppName  --slot $FunctionAppDeploymentSlotName
    $functionAppStagingId = (Invoke-Executable az functionapp show --name $FunctionAppName --resource-group $FunctionAppResourceGroupName --slot $FunctionAppDeploymentSlotName | ConvertFrom-Json).id
    Invoke-Executable az functionapp config set --ids $functionAppStagingId --always-on $FunctionAppAlwaysOn --number-of-workers $FunctionAppNumberOfInstances --ftps-state Disabled --min-tls-version $FunctionAppMinimalTlsVersion
    Invoke-Executable az functionapp config appsettings set --ids $functionAppStagingId --settings "ASPNETCORE_ENVIRONMENT=$($ASPNETCORE_ENVIRONMENT)" "FUNCTIONS_EXTENSION_VERSION=$($FUNCTIONS_EXTENSION_VERSION)"
    Invoke-Executable az functionapp identity assign --ids $functionAppStagingId --slot $FunctionAppDeploymentSlotName
    
    Set-DiagnosticSettings -ResourceId $functionAppStagingId -ResourceName $FunctionAppName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -Logs "[{ 'category': 'FunctionAppLogs', 'enabled': true } ]".Replace("'", '\"') -Metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')

    if ($DisablePublicAccessForFunctionAppDeploymentSlot)
    {
        $accessRestrictionRuleName = 'DisablePublicAccess'
        $cidr = '0.0.0.0/0'
        $accessRestrictionAction = 'Deny'
        
        Add-AccessRestriction -AppType functionapp -ResourceGroupName $FunctionAppResourceGroupName -ResourceName $FunctionAppName -AccessRestrictionRuleName $accessRestrictionRuleName -CIDR $cidr -AccessRestrictionAction $accessRestrictionAction -Priority 100000 -DeploymentSlotName $FunctionAppDeploymentSlotName -AccessRestrictionRuleDescription $FunctionAppName -ApplyToMainEntrypoint $True -ApplyToScmEntrypoint $True -AutoGeneratedAccessRestrictionRuleName $False
    }
}

# VNET Whitelisting
if ($GatewayVnetResourceGroupName -and $GatewayVnetName -and $GatewaySubnetName)
{
    # REMOVE OLD NAMES
    $oldAccessRestrictionRuleName = ToMd5Hash -InputString "$($GatewayVnetName)_$($GatewaySubnetName)_allow"
    Remove-AccessRestrictionIfExists -AppType functionapp -ResourceGroupName $FunctionAppResourceGroupName -ResourceName $FunctionAppName -AccessRestrictionRuleName $oldAccessRestrictionRuleName -AutoGeneratedAccessRestrictionRuleName $False
    # END REMOVE OLD NAMES

    Write-Host "VNET Whitelisting is desired. Adding the needed components."

    # Whitelist VNET
    & "$PSScriptRoot\Add-Network-Whitelist-to-Function-App.ps1" -FunctionAppResourceGroupName $FunctionAppResourceGroupName -FunctionAppName $FunctionAppName -AccessRestrictionRuleDescription:$FunctionAppName -Priority $GatewayWhitelistRulePriority -ApplyToMainEntrypoint $true -ApplyToScmEntryPoint $true -SubnetToWhitelistSubnetName $GatewaySubnetName -SubnetToWhitelistVnetName $GatewayVnetName -SubnetToWhitelistVnetResourceGroupName $GatewayVnetResourceGroupName
}

# Add private endpoint & Setup Private DNS
if ($FunctionAppPrivateEndpointVnetResourceGroupName -and $FunctionAppPrivateEndpointVnetName -and $FunctionAppPrivateEndpointSubnetName -and $DNSZoneResourceGroupName -and $FunctionAppPrivateDnsZoneName)
{
    Write-Host "A private endpoint is desired. Adding the needed components."
    # Fetch needed information
    $vnetId = (Invoke-Executable az network vnet show --resource-group $FunctionAppPrivateEndpointVnetResourceGroupName --name $FunctionAppPrivateEndpointVnetName | ConvertFrom-Json).id
    $functionAppPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $FunctionAppPrivateEndpointVnetResourceGroupName --name $FunctionAppPrivateEndpointSubnetName --vnet-name $FunctionAppPrivateEndpointVnetName | ConvertFrom-Json).id
    $functionAppPrivateEndpointName = "$($FunctionAppName)-pvtfunc"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $functionAppPrivateEndpointSubnetId -PrivateEndpointName $functionAppPrivateEndpointName -PrivateEndpointResourceGroupName $FunctionAppResourceGroupName -TargetResourceId $functionAppId -PrivateEndpointGroupId sites -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $FunctionAppPrivateDnsZoneName -PrivateDnsLinkName "$($FunctionAppPrivateEndpointVnetName)-appservice"
}


Write-Footer -ScopedPSCmdlet $PSCmdlet