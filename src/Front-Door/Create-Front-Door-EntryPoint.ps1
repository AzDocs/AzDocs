[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    [Parameter(Mandatory)][string] $FrontDoorProfileName,
    [Parameter(Mandatory)][string] $FrontDoorResourceGroup,
    [Parameter(Mandatory)][string] $EndpointName,
    [Parameter()][string][ValidateSet('Disabled', 'Enabled')] $EndpointIsEnabled = 'Enabled',

    # Origin group
    [Parameter(Mandatory)][string] $OriginGroupName,

    # Rule set name
    [Parameter()][string] $RuleSetName,

    # Route name
    [Parameter(Mandatory)][string] $RouteName,
    [Parameter(Mandatory)][string] $CustomDomainHostName,
    [Parameter()][string][ValidateSet('HttpOnly', 'HttpsOnly', 'MatchRequest')] $RouteForwardingProtocol = 'HttpsOnly',
    [Parameter()][string][ValidateSet('Disabled', 'Enabled')] $RouteHttpsRedirect = 'Enabled',
    [Parameter()][string][ValidateSet('Http', 'Https', 'HttpAndHttps')] $RouteSupportedProtocols = 'Https',
    [Parameter()][string][ValidateSet('Enabled', 'Disabled')] $LinkRouteToDefaultDomain = 'Disabled',

    # Security Policy name
    [Parameter(Mandatory, ParameterSetName = 'waf')][string] $SecurityPolicyName,
    [Parameter(Mandatory, ParameterSetName = 'waf')][string] $WAFPolicyName, 
    [Parameter(Mandatory, ParameterSetName = 'waf')][string] $WAFPolicyResourceGroup
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Create Endpoint 
Write-Host "Creating endpoint for $EndpointName"

$endpointExists = Invoke-Executable -AllowToFail az afd endpoint show --profile-name $FrontDoorProfileName --resource-group $FrontDoorResourceGroup --endpoint-name $EndpointName
if (!$endpointExists)
{
    Invoke-Executable az afd endpoint create --enabled-state $EndpointIsEnabled --endpoint-name $EndpointName --profile-name $FrontDoorProfileName --resource-group $FrontDoorResourceGroup
}

Write-Host "Done creating endpoint for $EndpointName"

# Create Route for Endpoint
Write-Host "Adding route to endpoint for $EndpointName"

$customDomains = Invoke-Executable az afd custom-domain list --profile-name $FrontDoorProfileName --resource-group $FrontDoorResourceGroup | ConvertFrom-Json
$customDomainName = ($customDomains | Where-Object { $_.hostname -eq $CustomDomainHostName }).name

if ($customDomainName)
{
    $paramsForRoute = @{
        FrontDoorProfileName    = $FrontDoorProfileName
        FrontDoorResourceGroup  = $FrontDoorResourceGroup
        RouteName               = $RouteName
        EndpointName            = $EndpointName
        RouteForwardingProtocol = $RouteForwardingProtocol
        RouteHttpsRedirect      = $RouteHttpsRedirect
        OriginGroupName         = $OriginGroupName
        RouteSupportedProtocols = $RouteSupportedProtocols
        CustomDomainName        = $customDomainName
        RuleSetName             = $RuleSetName
        LinkToDefaultDomain     = $LinkRouteToDefaultDomain
    }
    
    Add-RouteToEndpointToFrontDoor @paramsForRoute
    Write-Host "Done adding route to endpoint for $EndpointName"
}
else
{
    throw "Cannot find custom domain host name for $CustomDomainHostName. Please supply the right values."
}

if ($SecurityPolicyName)
{

    Write-Host "Adding security policy to endpoint for $EndpointName"
    $customDomainId = (Invoke-Executable az afd custom-domain show --custom-domain-name $CustomDomainName --profile-name $FrontDoorProfileName --resource-group $FrontDoorResourceGroup | ConvertFrom-Json).id
    $wafPolicyId = (Invoke-Executable az network front-door waf-policy show --name $WAFPolicyName --resource-group $WAFPolicyResourceGroup | ConvertFrom-Json).id 
    Invoke-Executable az afd security-policy create --domains $customDomainId --profile-name $FrontDoorProfileName --resource-group $FrontDoorResourceGroup --security-policy-name $SecurityPolicyName --waf-policy $wafPolicyId
    Write-Host "Done adding security policy to endpoint for $EndpointName"
}

Write-Host 'Done creating entrypoint'
Write-Footer -ScopedPSCmdlet $PSCmdlet