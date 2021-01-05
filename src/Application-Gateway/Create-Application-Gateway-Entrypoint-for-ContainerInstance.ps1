<#
.SYNOPSIS
Configure the Application Gateway for a site.

.DESCRIPTION
Configure the Application Gateway for sites for a public or private certificate.

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)][String] $certificatePath,
    [Parameter(Mandatory)][string] $domainName,
    [Parameter(Mandatory)][string] $gatewayName,
    [Parameter(Mandatory)][string] $gatewayType,
    [Parameter(Mandatory)][string] $sharedServicesResourceGroupName,
    [Parameter(Mandatory)][string] $sharedServicesKeyvaultName,
    [Parameter(Mandatory)][string] $certificatePassword,
    [Parameter(Mandatory)][string] $containerName,
    [Parameter(Mandatory)][string] $containerResourceGroupName,
    [Parameter(Mandatory)][string] $healthProbePath,
    [Parameter()][int] $healthProbeInterval = 60,
    [Parameter()][int] $healthProbeThreshold = 2,
    [Parameter()][int] $healthProbeTimeout = 20,
    [Parameter()][ValidateSet("HTTP", "HTTPS")][string] $healthProbeProtocol = "HTTPS",
    [Parameter()][ValidateSet("HTTP", "HTTPS")][string] $httpsSettingsProtocol = "HTTPS",
    [Parameter()][ValidateRange(0, 65535)][int] $httpsSettingsPort = 443,
    [Parameter()][ValidateSet("Disabled", "Enabled")][string] $httpsSettingsCookieAffinity = "Disabled",
    [Parameter()][int] $httpsSettingsConnectionDrainingTimeout = 0,
    [Parameter()][int] $httpsSettingsTimeout = 30,
    [Parameter()][string] $matchStatusCodes = "200-399",
    [Parameter(Mandatory)][ValidateSet("Basic", "PathBasedRouting")][string] $gatewayRuleType
)
#TODO check this script, still valid?
$ErrorActionPreference = "Continue"

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\AppGateway-Helper-Functions.ps1"
#endregion ===END IMPORTS===

Write-Header
try
{
    # Get the IP for the container instance
    $ipAddress = az container show --name $containerName --resource-group $containerResourceGroupName --query=ipAddress.ip | ConvertFrom-Json

    if(!$ipAddress)
    {
        throw "IP Address for this container could not be found."
    }

    # Create the Entrypoint. In this script thats simply done with the backenddomain directly.
    New-Entrypoint -certificatePath $certificatePath -domainName $domainName -gatewayName $gatewayName -gatewayType $gatewayType -sharedServicesResourceGroupName $sharedServicesResourceGroupName `
    -sharedServicesKeyvaultName $sharedServicesKeyvaultName -certificatePassword $certificatePassword -backendDomainname $ipAddress -healthProbePath $healthProbePath -healthProbeInterval $healthProbeInterval `
    -healthProbeThreshold $healthProbeThreshold -healthProbeTimeout $healthProbeTimeout -healthProbeProtocol $healthProbeProtocol -httpsSettingsProtocol $httpsSettingsProtocol -httpsSettingsPort $httpsSettingsPort `
    -httpsSettingsCookieAffinity $httpsSettingsCookieAffinity -httpsSettingsConnectionDrainingTimeout $httpsSettingsConnectionDrainingTimeout -httpsSettingsTimeout $httpsSettingsTimeout -matchStatusCodes $matchStatusCodes `
    -gatewayRuleType $gatewayRuleType
}
catch
{
    throw
}
finally
{
    [Console]::ResetColor()
}

Write-Footer