[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    [Parameter(Mandatory)][string] $FrontDoorProfileName,
    [Parameter(Mandatory)][string] $FrontDoorResourceGroup,

    # Origin group
    [Parameter(Mandatory)][string] $OriginGroupName,
    # Health probe origin group
    [Parameter()][string] $OriginHealthProbePath = "/",
    [Parameter()][string][ValidateSet("Http", "Https", "NotSet")] $OriginHealthProbeProtocol = 'Https',
    [Parameter()][string][ValidateSet("GET", "HEAD", "NotSet")] $OriginHealthProbeRequestType = 'GET',
    [Parameter()][string] $OriginHealthProbeIntervalInSeconds = 100,
    
    # Health probe Load Balancing
    [Parameter()][string] $OriginLoadBalancingSampleSize = 4, 
    [Parameter()][string] $OriginLoadBalancingSuccessfulSamplesRequired = 3, 
    [Parameter()][string] $OriginLoadBalancingAdditationalLatencyInMilliseconds = 50,

    # Origin
    [Parameter(Mandatory)][string] $OriginName,
    [Parameter(Mandatory)][string][ValidateSet('webapp', 'functionapp', 'custom')] $ResourceType,
    [Parameter()][string] $ResourceName,
    [Parameter()][string] $CustomOriginHostName,

    [Parameter()][string] $OriginHttpPort = "80",
    [Parameter()][string] $OriginHttpsPort = "443",
    [Parameter()][string] $OriginPriority = "1", 
    [Parameter()][string] $OriginWeight = "1000", 
    [Parameter()][string][ValidateSet("Enabled", "Disabled")] $OriginEnabled = "Enabled"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Create origin group
Write-Host "Creating origin group for $OriginGroupName"

$paramsForOriginGroup = @{
    FrontDoorProfileName                                 = $FrontDoorProfileName;
    FrontDoorResourceGroup                               = $FrontDoorResourceGroup;
    OriginGroupName                                      = $OriginGroupName;
    OriginHealthProbePath                                = $OriginHealthProbePath;
    OriginHealthProbeProtocol                            = $OriginHealthProbeProtocol;
    OriginHealthProbeRequestType                         = $OriginHealthProbeRequestType;
    OriginHealthProbeIntervalInSeconds                   = $OriginHealthProbeIntervalInSeconds;
    OriginLoadBalancingSampleSize                        = $OriginLoadBalancingSampleSize;
    OriginLoadBalancingSuccessfulSamplesRequired         = $OriginLoadBalancingSuccessfulSamplesRequired;
    OriginLoadBalancingAdditationalLatencyInMilliseconds = $OriginLoadBalancingAdditationalLatencyInMilliseconds;
}

Add-OriginGroupToFrontDoor @paramsForOriginGroup
Write-Host "Done creating origin group for $OriginGroupName"

# Add origin to the group
Write-Host "Generating hostname based on resourcetype: $ResourceType"
switch ($ResourceType) {
    'webapp' { $hostname = "$($ResourceName).azurewebsites.net" }
    'functionapp' { $hostname = "$($ResourceName).azurewebsites.net" }
    'custom' { $hostname = $CustomOriginHostName }
}

Write-Host "Generated hostname $hostname"
Write-Host "Creating origin for host $hostName"


$paramsForOrigin = @{
    FrontDoorProfileName   = $FrontDoorProfileName;
    FrontDoorResourceGroup = $FrontDoorResourceGroup;
    OriginGroupName        = $OriginGroupName;
    OriginName             = $OriginName;
    OriginHostName         = $hostName;
    OriginHttpPort         = $OriginHttpPort;
    OriginHttpsPort        = $OriginHttpsPort;
    OriginPriority         = $OriginPriority;
    OriginWeight           = $OriginWeight;
    OriginEnabled          = $OriginEnabled;
}

Add-OriginToOriginGroup @paramsForOrigin
Write-Host "Done creating origin for host $hostName"

Write-Footer -ScopedPSCmdlet $PSCmdlet