function New-DeploymentSlot
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] [ValidateSet('functionapp', 'webapp')]$AppType,
        [Parameter(Mandatory)][string] $ResourceResourceGroupName,
        [Parameter(Mandatory)][string] $ResourceName,
        [Parameter(Mandatory)][string] $ResourceDeploymentSlotName,
        [Parameter(Mandatory)][string] $ResourceAppServicePlanTier,
        [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
        [Parameter()][bool] $StopResourceSlotImmediatelyAfterCreation,
        [Parameter()][System.Object[]] $ResourceTags,
        [Parameter()][string] $ResourceNumberOfInstances = 2,
        [Parameter()][bool] $ResourceAlwaysOn = $true,
        [Parameter()][string][ValidateSet("1.0", "1.1", "1.2")] $ResourceMinimalTlsVersion = "1.2",
        [Parameter()][bool] $DisablePublicAccessForResourceDeploymentSlot = $true,
        # Forcefully agree to this resource to be spun up to be publicly available
        [Parameter()][switch] $ForcePublic,
     
        # VNET Whitelisting Parameters
        [Parameter()][bool] $ResourceDisableVNetWhitelisting = $false,
        [Parameter()][string] $GatewayVnetResourceGroupName,
        [Parameter()][string] $GatewayVnetName,
        [Parameter()][string] $GatewaySubnetName,
        [Parameter()][string] $GatewayWhitelistRulePriority = 20,

        # Private endpoints
        [Parameter()][bool] $ResourceDisablePrivateEndpoints = $false,
        [Parameter()][string] $ResourcePrivateEndpointVnetResourceGroupName,
        [Parameter()][string] $ResourcePrivateEndpointVnetName,
        [Parameter()][string] $ResourcePrivateEndpointSubnetName,
        [Parameter()][string] $DNSZoneResourceGroupName,
        [Parameter()][string] $ResourcePrivateDnsZoneName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    # Check if the deployment slot can be spinned up publicly
    if (!$ResourceEnableVNetWhitelisting -and !$ResourceEnablePrivateEndpoints -and !$DisablePublicAccessForResourceDeploymentSlot) 
    {
        Assert-IntentionallyCreatedPublicResource -ForcePublic:$ForcePublic
    }

    # Create deployment slot
    Invoke-Executable az $AppType deployment slot create --resource-group $ResourceResourceGroupName --name $ResourceName --slot $ResourceDeploymentSlotName
    

    # Stop immediately if desired
    if ($StopResourceSlotImmediatelyAfterCreation)
    {
        Invoke-Executable az $AppType stop --name $ResourceName --resource-group $ResourceResourceGroupName --slot $ResourceDeploymentSlotName
    }
    
    # Set configuration
    $resourceSlotId = (Invoke-Executable az $AppType show --name $ResourceName --resource-group $ResourceResourceGroupName --slot $ResourceDeploymentSlotName | ConvertFrom-Json).id
    Invoke-Executable az $AppType config set --ids $resourceSlotId --number-of-workers $ResourceNumberOfInstances --always-on $ResourceAlwaysOn --ftps-state Disabled --min-tls-version $ResourceMinimalTlsVersion --slot $ResourceDeploymentSlotName
    Invoke-Executable az $Apptype identity assign --ids $resourceSlotId --slot $ResourceDeploymentSlotName
    
    Set-ConfigurationForResource -AppType $AppType -ResourceSlotId $resourceSlotId -ResourceResourceGroupName $ResourceResourceGroupName -ResourceDeploymentSlotName $ResourceDeploymentSlotName -ResourceAppServicePlanTier $ResourceAppServicePlanTier -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $ResourceName

    # Update Tags
    Set-ResourceTagsForResource -ResourceId $resourceSlotId -ResourceTags ${ResourceTags}

    # VNET Whitelisting
    if (!$ResourceDisableVNetWhitelisting -and $GatewayVnetResourceGroupName -and $GatewayVnetName -and $GatewaySubnetName)
    {
        Write-Host "VNET Whitelisting is desired. Adding the needed components."
        $RootPath = (Get-Item $PSScriptRoot).Parent.Parent
        switch ($AppType)
        {
            'webapp' { & "$RootPath\App-Services\Add-Network-Whitelist-to-App-Service.ps1" -AppServiceResourceGroupName $ResourceResourceGroupName -AppServiceName $ResourceName -AppServiceDeploymentSlotName $ResourceDeploymentSlotName -AccessRestrictionRuleDescription:$ResourceName -Priority $GatewayWhitelistRulePriority -ApplyToMainEntrypoint $true -ApplyToScmEntryPoint $true -SubnetToWhitelistSubnetName $GatewaySubnetName -SubnetToWhitelistVnetName $GatewayVnetName -SubnetToWhitelistVnetResourceGroupName $GatewayVnetResourceGroupName }
            'functionapp' { & "$RootPath\Functions\Add-Network-Whitelist-to-Function-App.ps1" -FunctionAppResourceGroupName $ResourceResourceGroupName -FunctionAppName $ResourceName -FunctionAppDeploymentSlotName $ResourceDeploymentSlotName -AccessRestrictionRuleDescription:$ResourceName -Priority $GatewayWhitelistRulePriority -ApplyToMainEntrypoint $true -ApplyToScmEntryPoint $true -SubnetToWhitelistSubnetName $GatewaySubnetName -SubnetToWhitelistVnetName $GatewayVnetName -SubnetToWhitelistVnetResourceGroupName $GatewayVnetResourceGroupName }
        }
    }

    # Add private endpoint & Setup Private DNS
    if (!$ResourceDisablePrivateEndpoints -and $ResourcePrivateEndpointVnetResourceGroupName -and $ResourcePrivateEndpointVnetName -and $ResourcePrivateEndpointSubnetName -and $DNSZoneResourceGroupName -and $ResourcePrivateDnsZoneName)
    {
        # Fetch needed information
        Write-Host "A private endpoint is desired. Adding the needed components."
        $vnetId = (Invoke-Executable az network vnet show --resource-group $ResourcePrivateEndpointVnetResourceGroupName --name $ResourcePrivateEndpointVnetName | ConvertFrom-Json).id
        $resourcePrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ResourcePrivateEndpointVnetResourceGroupName --name $ResourcePrivateEndpointSubnetName --vnet-name $ResourcePrivateEndpointVnetName | ConvertFrom-Json).id
        $resourcePrivateEndpointName = Get-PrivateEndpointNameForResource -AppType $AppType -ResourceName $ResourceName -ResourceDeploymentSlotName $ResourceDeploymentSlotName
        $parentResourceId = (Invoke-Executable az $AppType show --ids $resourceSlotId | ConvertFrom-Json).id
 
        # Add private endpoint & Setup Private DNS
        Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $resourcePrivateEndpointSubnetId -PrivateEndpointName $resourcePrivateEndpointName -PrivateEndpointResourceGroupName $ResourceResourceGroupName -TargetResourceId $parentResourceId -PrivateEndpointGroupId "sites-$ResourceDeploymentSlotName" -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $ResourcePrivateDnsZoneName -PrivateDnsLinkName "$($ResourcePrivateEndpointVnetName)-appservice"
    }
    
    # Disable public acces, if it's not public
    if (!$ForcePublic -and $DisablePublicAccessForResourceDeploymentSlot)
    {
        Write-Host "Disabling public access on the deployment slot."

        $accessRestrictionRuleName = 'DisablePublicAccess'
        $cidr = '0.0.0.0/0'
        $accessRestrictionAction = 'Deny'
        $priority = 100000

        $RootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
        switch ($AppType)
        {
            'webapp' { & "$RootPath\App-Services\Add-Network-Whitelist-to-App-Service.ps1" -AppServiceResourceGroupName $ResourceResourceGroupName -AppServiceName $ResourceName -AppServiceDeploymentSlotName $ResourceDeploymentSlotName -AccessRestrictionRuleName $accessRestrictionRuleName -AccessRestrictionRuleDescription:$ResourceName -Priority $priority -ApplyToMainEntrypoint $true -ApplyToScmEntryPoint $true -AccessRestrictionAction $accessRestrictionAction -CIDR $cidr }
            'functionapp' { & "$RootPath\Functions\Add-Network-Whitelist-to-Function-App.ps1" -FunctionAppResourceGroupName $ResourceResourceGroupName -FunctionAppName $ResourceName -FunctionAppDeploymentSlotName $ResourceDeploymentSlotName -AccessRestrictionRuleName $accessRestrictionRuleName -AccessRestrictionRuleDescription:$ResourceName -Priority $priority -ApplyToMainEntrypoint $true -ApplyToScmEntryPoint $true -AccessRestrictionAction $accessRestrictionAction -CIDR $cidr }
        }
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Get-PrivateEndpointNameForResource
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] [ValidateSet('functionapp', 'webapp')]$AppType,
        [Parameter(Mandatory)][string] $ResourceName,
        [Parameter(Mandatory)][string] $ResourceDeploymentSlotName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    switch ($AppType)
    {
        'webapp' { Write-Output "$ResourceName-pvtapp-$ResourceDeploymentSlotName" }
        'functionapp' { Write-Output "$ResourceName-pvtfunc-$ResourceDeploymentSlotName" }
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Set-ConfigurationForResource
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] [ValidateSet('functionapp', 'webapp')]$AppType,
        [Parameter(Mandatory)][string] $ResourceSlotId,
        [Parameter(Mandatory)][string] $ResourceResourceGroupName,
        [Parameter(Mandatory)][string] $ResourceDeploymentSlotName,
        [Parameter(Mandatory)][string] $ResourceAppServicePlanTier,
        [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
        [Parameter(Mandatory)][string] $ResourceName
    )
    
    Write-Header -ScopedPSCmdlet $PSCmdlet

    switch ($AppType)
    {
        'webapp'
        {
            # Enforce HTTPS
            Invoke-Executable az webapp update --resource-group $ResourceResourceGroupName --name $ResourceName --slot $ResourceDeploymentSlotName --https-only true
            Invoke-Executable az webapp log config --ids $ResourceSlotId --detailed-error-messages true --docker-container-logging filesystem --failed-request-tracing true --level warning --web-server-logging filesystem --slot $ResourceDeploymentSlotName
        
            $diagnosticSettingsForWebapp = Get-DiagnosticSettingBasedOnTier -ResourceType $AppType -CurrentResourceTier $ResourceAppServicePlanTier
            if ($diagnosticSettingsForWebapp.DiagnosticSettingType -eq 'Logs')
            {
                Set-DiagnosticSettings -ResourceId $ResourceSlotId -ResourceName $ResourceName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -Logs $diagnosticSettingsForWebapp.DiagnosticSettingValue -Metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')
            }
        }
        'functionapp'
        {
            # Enforce HTTPS
            Invoke-Executable az functionapp update --ids $ResourceSlotId --set httpsOnly=true

            Invoke-Executable az functionapp config appsettings set --ids $ResourceSlotId --settings "ASPNETCORE_ENVIRONMENT=$($ASPNETCORE_ENVIRONMENT)" "FUNCTIONS_EXTENSION_VERSION=$($FUNCTIONS_EXTENSION_VERSION)"
            Set-DiagnosticSettings -ResourceId $resourceSlotId -ResourceName $ResourceName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -Logs "[{ 'category': 'FunctionAppLogs', 'enabled': true } ]".Replace("'", '\"') -Metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')
        }
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}