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
    [Parameter(Mandatory)][string] $BackendDomainname,
    [Parameter()][string] $HealthProbeDomainName,
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
    [Parameter()][string] $HttpsSettingsCustomRootCertificateFilePath,
    [Alias("MatchStatusCodes")]
    [Parameter()][string] $HealthProbeMatchStatusCodes = "200-399",
    [Alias("GatewayRuleType")]
    [Parameter(Mandatory)][ValidateSet("Basic", "PathBasedRouting")][string] $ApplicationGatewayRuleType = "Basic",
    [Parameter()][string] $ApplicationGatewayRuleDefaultIngressDomainName, 
    [Parameter()][string] $ApplicationGatewayRulePath
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

try
{
    # Create the Entrypoint. In this script thats simply done with the backenddomain directly.
    New-ApplicationGatewayEntrypoint -CertificatePath $CertificatePath -IngressDomainName $IngressDomainName -ApplicationGatewayName $ApplicationGatewayName -ApplicationGatewayFacingType $ApplicationGatewayFacingType -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -CertificateKeyvaultResourceGroupName $CertificateKeyvaultResourceGroupName `
        -CertificateKeyvaultName $CertificateKeyvaultName -CertificatePassword $CertificatePassword -BackendDomainName $BackendDomainname -HealthProbeUrlPath $HealthProbeUrlPath -HealthProbeIntervalInSeconds $HealthProbeIntervalInSeconds `
        -HealthProbeNumberOfTriesBeforeMarkedDown $HealthProbeNumberOfTriesBeforeMarkedDown -HealthProbeTimeoutInSeconds $HealthProbeTimeoutInSeconds -HealthProbeProtocol $HealthProbeProtocol -HttpsSettingsRequestToBackendProtocol $HttpsSettingsRequestToBackendProtocol -HttpsSettingsRequestToBackendPort $HttpsSettingsRequestToBackendPort `
        -HttpsSettingsRequestToBackendCookieAffinity $HttpsSettingsRequestToBackendCookieAffinity -HttpsSettingsRequestToBackendConnectionDrainingTimeoutInSeconds $HttpsSettingsRequestToBackendConnectionDrainingTimeoutInSeconds -HttpsSettingsRequestToBackendTimeoutInSeconds $HttpsSettingsRequestToBackendTimeoutInSeconds -HttpsSettingsCustomRootCertificateFilePath $HttpsSettingsCustomRootCertificateFilePath `
        -HealthProbeMatchStatusCodes $HealthProbeMatchStatusCodes -ApplicationGatewayRuleType $ApplicationGatewayRuleType -HealthProbeDomainName $HealthProbeDomainName -ApplicationGatewayRuleDefaultIngressDomainName $ApplicationGatewayRuleDefaultIngressDomainName -ApplicationGatewayRulePath $ApplicationGatewayRulePath
}
catch
{
    throw
}
finally
{
    [Console]::ResetColor()
}

Write-Footer -ScopedPSCmdlet $PSCmdlet