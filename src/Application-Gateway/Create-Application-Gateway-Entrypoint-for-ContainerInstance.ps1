[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $CertificatePath,
    [Parameter(Mandatory)][string] $CertificatePassword,
    [Alias("DomainName")]
    [Parameter(Mandatory)][string] $IngressDomainName,
    [Alias("GatewayName")]
    [Parameter(Mandatory)][string] $ApplicationGatewayName,
    [Alias("GatewayType")]
    [Parameter(Mandatory)][ValidateSet("Private", "Public")][string] $ApplicationGatewayFacingType,
    [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
    [Parameter(Mandatory)][string] $CertificateKeyvaultResourceGroupName,
    [Alias("SharedServicesKeyvaultName")]
    [Parameter(Mandatory)][string] $CertificateKeyvaultName,
    [Parameter(Mandatory)][string] $ContainerName,
    [Parameter(Mandatory)][string] $ContainerResourceGroupName,
    [Alias("HealthProbePath")]
    [Parameter(Mandatory)][string] $HealthProbeUrlPath,
    [Alias("HealthProbeInterval")]
    [Parameter()][int] $HealthProbeIntervalInSeconds = 60,
    [Alias("HealthProbeThreshold")]
    [Parameter()][int] $HealthProbeNumberOfTriesBeforeMarkedDown = 2,
    [Alias("HealthProbeTimeout")]
    [Parameter()][int] $HealthProbeTimeoutInSeconds = 20,
    [Parameter()][ValidateSet("HTTP", "HTTPS")][string] $HealthProbeProtocol = "HTTPS",
    [Alias("HttpsSettingsProtocol")]
    [Parameter()][ValidateSet("HTTP", "HTTPS")][string] $HttpsSettingsRequestToBackendProtocol = "HTTPS",
    [Alias("HttpsSettingsPort")]
    [Parameter()][ValidateRange(0, 65535)][int] $HttpsSettingsRequestToBackendPort = 443,
    [Alias("HttpsSettingsCookieAffinity")]
    [Parameter()][ValidateSet("Disabled", "Enabled")][string] $HttpsSettingsRequestToBackendCookieAffinity = "Disabled",
    [Alias("HttpsSettingsConnectionDrainingTimeout")]
    [Parameter()][int] $HttpsSettingsRequestToBackendConnectionDrainingTimeoutInSeconds = 0,
    [Alias("HttpsSettingsTimeout")]
    [Parameter()][int] $HttpsSettingsRequestToBackendTimeoutInSeconds = 30,
    [Alias("MatchStatusCodes")]
    [Parameter()][string] $HealthProbeMatchStatusCodes = "200-399",
    [Alias("GatewayRuleType")]
    [Parameter(Mandatory)][ValidateSet("Basic", "PathBasedRouting")][string] $ApplicationGatewayRuleType
)

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
    $ipAddress = Invoke-Executable -AllowToFail az container show --name $ContainerName --resource-group $ContainerResourceGroupName --query=ipAddress.ip | ConvertFrom-Json

    if(!$ipAddress)
    {
        throw "IP Address for this container could not be found."
    }

    # Create the Entrypoint. In this script thats simply done with the backenddomain directly.
    New-ApplicationGatewayEntrypoint -CertificatePath $CertificatePath -IngressDomainName $IngressDomainName -ApplicationGatewayName $ApplicationGatewayName -ApplicationGatewayFacingType $ApplicationGatewayFacingType -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -CertificateKeyvaultResourceGroupName $CertificateKeyvaultResourceGroupName `
    -CertificateKeyvaultName $CertificateKeyvaultName -CertificatePassword $CertificatePassword -BackendDomainName $ipAddress -HealthProbeUrlPath $HealthProbeUrlPath -HealthProbeIntervalInSeconds $HealthProbeIntervalInSeconds `
    -HealthProbeNumberOfTriesBeforeMarkedDown $HealthProbeNumberOfTriesBeforeMarkedDown -HealthProbeTimeoutInSeconds $HealthProbeTimeoutInSeconds -HealthProbeProtocol $HealthProbeProtocol -HttpsSettingsRequestToBackendProtocol $HttpsSettingsRequestToBackendProtocol -HttpsSettingsRequestToBackendPort $HttpsSettingsRequestToBackendPort `
    -HttpsSettingsRequestToBackendCookieAffinity $HttpsSettingsRequestToBackendCookieAffinity -HttpsSettingsRequestToBackendConnectionDrainingTimeoutInSeconds $HttpsSettingsRequestToBackendConnectionDrainingTimeoutInSeconds -HttpsSettingsRequestToBackendTimeoutInSeconds $HttpsSettingsRequestToBackendTimeoutInSeconds -HealthProbeMatchStatusCodes $HealthProbeMatchStatusCodes `
    -ApplicationGatewayRuleType $ApplicationGatewayRuleType
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