[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ApplicationGatewayName,
    [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
    [Parameter()][ValidateSet('TLSv1_0', 'TLSv1_1', 'TLSv1_2')][string] $ApplicationGatewayMinimalProtocolVersion = 'TLSv1_2',
    [Parameter()][ValidateSet(
        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
        'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384',
        'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256',
        'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA',
        'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA',
        'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384',
        'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256',
        'TLS_DHE_RSA_WITH_AES_256_CBC_SHA',
        'TLS_DHE_RSA_WITH_AES_128_CBC_SHA',
        'TLS_RSA_WITH_AES_256_GCM_SHA384',
        'TLS_RSA_WITH_AES_128_GCM_SHA256',
        'TLS_RSA_WITH_AES_256_CBC_SHA256',
        'TLS_RSA_WITH_AES_128_CBC_SHA256',
        'TLS_RSA_WITH_AES_256_CBC_SHA',
        'TLS_RSA_WITH_AES_128_CBC_SHA',
        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
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
    )][string[]] $ApplicationGatewayCipherSuites = @(
        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
        'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384',
        'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256',
        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
        'TLS_RSA_WITH_AES_256_GCM_SHA384',
        'TLS_RSA_WITH_AES_128_GCM_SHA256'
    )
)



#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az network application-gateway ssl-policy set --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --policy-type Custom --min-protocol-version $ApplicationGatewayMinimalProtocolVersion --cipher-suites @ApplicationGatewayCipherSuites

Write-Footer -ScopedPSCmdlet $PSCmdlet