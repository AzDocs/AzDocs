[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    [Parameter(Mandatory)][string] $AppServicePlanName,
    [Parameter(Mandatory)][string] $AppServicePlanResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Alias('LogAnalyticsWorkspaceName')]
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    [Parameter()][string] $AppServiceRunTime,
    [Parameter()][string] $AppServiceNumberOfInstances = 2,
    [Parameter(Mandatory)][System.Object[]] $ResourceTags,
    [Parameter()][bool] $StopAppServiceImmediatelyAfterCreation = $false,
    [Parameter()][bool] $StopAppServiceSlotImmediatelyAfterCreation = $false,
    [Parameter()][bool] $AppServiceAlwaysOn = $true,
    
    # Deployment Slots
    [Parameter(ParameterSetName = 'DeploymentSlot')][switch] $EnableAppServiceDeploymentSlot,
    [Parameter(ParameterSetName = 'DeploymentSlot')][string] $AppServiceDeploymentSlotName = 'staging',
    [Parameter(ParameterSetName = 'DeploymentSlot')][bool] $DisablePublicAccessForAppServiceDeploymentSlot = $true,

    # VNET Whitelisting Parameters
    [Parameter()][string] $GatewayVnetResourceGroupName,
    [Parameter()][string] $GatewayVnetName,
    [Parameter()][string] $GatewaySubnetName,
    [Parameter()][string] $GatewayWhitelistRulePriority = 20,

    # Private Endpoint
    [Alias('VnetResourceGroupName')]
    [Parameter()][string] $AppServicePrivateEndpointVnetResourceGroupName,
    [Alias('VnetName')]
    [Parameter()][string] $AppServicePrivateEndpointVnetName,
    [Alias('ApplicationPrivateEndpointSubnetName')]
    [Parameter()][string] $AppServicePrivateEndpointSubnetName,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Alias('PrivateDnsZoneName')]
    [Parameter()][string] $AppServicePrivateDnsZoneName = 'privatelink.azurewebsites.net',

    # Optional remaining arguments. This is a fix for being able to pass down parameters in an easy way using @PSBoundParameters in Create-Web-App-with-App-Service-Plan-Windows.ps1
    [Parameter(ValueFromRemainingArguments)][string[]] $Remaining
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Write-Warning 'This script is deprecated. Please use the Create-Web-App.ps1 instead.'
Write-Host '##vso[task.complete result=SucceededWithIssues;]'

# Create Web App
& "$PSScriptRoot\Create-Web-App.ps1" @PSBoundParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet