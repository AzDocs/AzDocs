[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ApplicationGatewayName,
    [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
    [Parameter()][ValidateSet('Predefined', 'Custom')][string] $ApplicationGatewayPolicyType,
    [Parameter()][ValidateSet('AppGwSslPolicy20150501', 'AppGwSslPolicy20170401', 'AppGwSslPolicy20170401S')][string] $ApplicationGatewayPredefinedPolicyName,
    [Parameter()][ValidateSet('TLSv1_0', 'TLSv1_1', 'TLSv1_2')][string] $ApplicationGatewayMinimalProtocolVersion,
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
    )][string[]] $ApplicationGatewayCipherSuites
)

# AT THE POINT OF WRITING (2021-03-27) THE RECOMMENDED CONFIG IS:
# MINIMAL TLS VERSION: TLSv1_2
# Used Ciphers:
# 'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
# 'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
# 'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
# 'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
# 'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384',
# 'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256',
# These two are for backwards compatibility. They are used in older software & IE11 on Windows 7 & 8.1. IE11 on Win10 supports stronger ciphers.
# 'TLS_RSA_WITH_AES_256_GCM_SHA384',
# 'TLS_RSA_WITH_AES_128_GCM_SHA256'

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$optionalParameters = @()

if ($ApplicationGatewayPredefinedPolicyName)
{
    $optionalParameters += "--name", "$ApplicationGatewayPredefinedPolicyName"
}

if ($ApplicationGatewayMinimalProtocolVersion)
{
    $optionalParameters += "--min-protocol-version", "$ApplicationGatewayMinimalProtocolVersion"
}

if ($ApplicationGatewayCipherSuites)
{
    $optionalParameters += "--cipher-suites"
    foreach ($ApplicationGatewayCipherSuite in $ApplicationGatewayCipherSuites)
    {
        $optionalParameters += $ApplicationGatewayCipherSuite
    }
}

Invoke-Executable az network application-gateway ssl-policy set --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --policy-type $ApplicationGatewayPolicyType @optionalParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet