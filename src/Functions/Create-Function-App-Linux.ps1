[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    [Parameter(Mandatory)][string] $AppServicePlanName,
    [Parameter(Mandatory)][string] $AppServicePlanResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Parameter(Mandatory)][string] $FunctionAppStorageAccountName,
    [Parameter(Mandatory)][string] $FunctionAppDiagnosticsName,
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceName,
    [Alias("AlwaysOn")]
    [Parameter(Mandatory)][string] $FunctionAppAlwaysOn,
    [Parameter(Mandatory)][string] $FUNCTIONS_EXTENSION_VERSION,
    [Parameter(Mandatory)][string] $ASPNETCORE_ENVIRONMENT,
    [Parameter()][string] $FunctionAppNumberOfInstances = 2,
    [Parameter()][ValidateSet("dotnet-isolated", "dotnet", "node", "python", "custom", "java")][string] $FunctionAppRuntime = "dotnet",
    [Parameter(Mandatory)][System.Object[]] $ResourceTags,

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

    # Optional remaining arguments. This is a fix for being able to pass down parameters in an easy way using @PSBoundParameters in Create-Function-App-with-App-Service-Plan-Linux.ps1
    [Parameter(ValueFromRemainingArguments)][string[]] $Remaining
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Fetch AppService Plan ID
$appServicePlanId = (Invoke-Executable az appservice plan show --resource-group $AppServicePlanResourceGroupName --name $AppServicePlanName | ConvertFrom-Json).id

# Fetch the ID from the FunctionApp
$functionAppId = (Invoke-Executable -AllowToFail az functionapp show --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json).id

#TODO: az functionapp create is not idempotent, therefore the following fix. For more information, see https://github.com/Azure/azure-cli/issues/11863
if (!$functionAppId)
{
    # Create FunctionApp
    Invoke-Executable az functionapp create --name $FunctionAppName --plan $appServicePlanId --os-type "Linux" --resource-group $FunctionAppResourceGroupName --storage-account $FunctionAppStorageAccountName --runtime $FunctionAppRuntime --functions-version 3 --disable-app-insights --tags ${ResourceTags}
    $functionAppId = (Invoke-Executable az functionapp show --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json).id
}

# Enforce HTTPS
Invoke-Executable az functionapp update --ids $functionAppId --set httpsOnly=true

# Set Always On, the number of instances and the ftps-state to disable
Invoke-Executable az functionapp config set --ids $functionAppId --always-on $FunctionAppAlwaysOn --number-of-workers $FunctionAppNumberOfInstances --ftps-state Disabled

# Set some basic configs (including vnet route all)
Invoke-Executable az functionapp config appsettings set --ids $functionAppId --settings "ASPNETCORE_ENVIRONMENT=$($ASPNETCORE_ENVIRONMENT)" "FUNCTIONS_EXTENSION_VERSION=$($FUNCTIONS_EXTENSION_VERSION)"

#  Create diagnostics settings
Invoke-Executable az monitor diagnostic-settings create --resource $functionAppId --name $FunctionAppDiagnosticsName --workspace $LogAnalyticsWorkspaceName --logs "[{ 'category': 'FunctionAppLogs', 'enabled': true } ]".Replace("'", '\"') --metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')

# Create & Assign WebApp identity to AppService
Invoke-Executable az functionapp identity assign --ids $functionAppId

# By default a staging slot will be added
if ($EnableFunctionAppDeploymentSlot)
{
    Invoke-Executable az functionapp deployment slot create --resource-group $FunctionAppResourceGroupName --name $FunctionAppName  --slot $FunctionAppDeploymentSlotName
    $functionAppStagingId = (Invoke-Executable az functionapp show --name $FunctionAppName --resource-group $FunctionAppResourceGroupName --slot $FunctionAppDeploymentSlotName | ConvertFrom-Json).id
    Invoke-Executable az functionapp config set --ids $functionAppStagingId --always-on $FunctionAppAlwaysOn --number-of-workers $FunctionAppNumberOfInstances --ftps-state Disabled
    Invoke-Executable az functionapp config appsettings set --ids $functionAppStagingId --settings "ASPNETCORE_ENVIRONMENT=$($ASPNETCORE_ENVIRONMENT)" "FUNCTIONS_EXTENSION_VERSION=$($FUNCTIONS_EXTENSION_VERSION)"
    Invoke-Executable az functionapp identity assign --ids $functionAppStagingId --slot $FunctionAppDeploymentSlotName

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