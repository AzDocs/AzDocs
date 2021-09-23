[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ApplicationGatewayName,
    [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
    [Parameter(Mandatory)][string] $SSLProfileName,
    [Parameter()][ValidateSet('Predefined', 'Custom')][string] $ApplicationGatewayPolicyType = 'Custom',
    [Parameter()][ValidateSet('AppGwSslPolicy20150501', 'AppGwSslPolicy20170401', 'AppGwSslPolicy20170401S')][string] $ApplicationGatewayPredefinedPolicyName = 'AppGwSslPolicy20170401S',
    [Parameter()][ValidateSet('TLSv1_0', 'TLSv1_1', 'TLSv1_2')][string] $ApplicationGatewayMinimalProtocolVersion = 'TLSv1_2',
    [Parameter()][ValidateSet(
        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
        'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384',
        'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256',
        'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384',
        'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256',
        'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA',
        'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA',
        'TLS_DHE_RSA_WITH_AES_256_CBC_SHA',
        'TLS_DHE_RSA_WITH_AES_128_CBC_SHA',
        'TLS_RSA_WITH_AES_256_GCM_SHA384',
        'TLS_RSA_WITH_AES_128_GCM_SHA256',
        'TLS_RSA_WITH_AES_256_CBC_SHA256',
        'TLS_RSA_WITH_AES_128_CBC_SHA256',
        'TLS_RSA_WITH_AES_256_CBC_SHA',
        'TLS_RSA_WITH_AES_128_CBC_SHA',
        'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384',
        'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256',
        'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA',
        'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA',
        'TLS_DHE_DSS_WITH_AES_256_CBC_SHA256',
        'TLS_DHE_DSS_WITH_AES_128_CBC_SHA256',
        'TLS_DHE_DSS_WITH_AES_256_CBC_SHA',
        'TLS_DHE_DSS_WITH_AES_128_CBC_SHA',
        'TLS_RSA_WITH_3DES_EDE_CBC_SHA',
        'TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA'
    )][string[]] $ApplicationGatewayCipherSuites = @('TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
        'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384',
        'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256' )
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$optionalParameters = @()

if ($ApplicationGatewayPolicyType -and $ApplicationGatewayPolicyType -eq 'Predefined')
{
    if ($ApplicationGatewayPredefinedPolicyName)
    {
        $optionalParameters += "--policy-name", "$ApplicationGatewayPredefinedPolicyName"
    }
}
elseif ($ApplicationGatewayPolicyType -and $ApplicationGatewayPolicyType -eq 'Custom')
{
    # Check TLS Version
    Assert-TLSVersion -TlsVersion $ApplicationGatewayMinimalProtocolVersion

    $optionalParameters += "--min-protocol-version", "$ApplicationGatewayMinimalProtocolVersion"

    $optionalParameters += "--cipher-suites"
    foreach ($ApplicationGatewayCipherSuite in $ApplicationGatewayCipherSuites)
    {
        # Check CipherSuite
        Assert-CipherSuite -CipherSuite $ApplicationGatewayCipherSuite
        $optionalParameters += $ApplicationGatewayCipherSuite
    }
}
else
{
    throw "Unsupported operation"
}

$currentSSLProfiles = Invoke-Executable az network application-gateway ssl-profile list --gateway-name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName | ConvertFrom-Json | Where-Object name -eq "$SSLProfileName"
if ($currentSSLProfiles)
{
    # TODO see https://github.com/Azure/azure-cli/issues/19036
    Write-Warning 'Updating of the ssl profile is not yet supported with azure cli.'
    Write-Host "##vso[task.complete result=SucceededWithIssues;]"
}
else
{
    Invoke-Executable az network application-gateway ssl-profile add --gateway-name $ApplicationGatewayName --name $SSLProfileName --resource-group $ApplicationGatewayResourceGroupName --policy-type $ApplicationGatewayPolicyType @optionalParameters
}

Write-Footer -ScopedPSCmdlet $PSCmdlet