// ===================================== Parameters =====================================
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The name of the VNet where you want to onboard this Application Gateway into.')
@minLength(2)
@maxLength(64)
param applicationGatewayVirtualNetworkName string

@description('Name of the subnet where the Application Gateway should reside in.')
@minLength(1)
@maxLength(80)
param applicationGatewaySubnetName string

@description('The name of the Application Gateway.')
@minLength(1)
@maxLength(80)
param applicationGatewayName string

@description('The minimum instance count for Application Gateway. The Application Gateway will scale out with a minimum of this minCapacity. For highly available Application Gateways, please use 2 or higher.')
@minValue(0)
@maxValue(125)
param minCapacity int = 2

@description('The maximum instance count for Application Gateway. The Application Gateway will scale out to this number tops.')
@minValue(1)
@maxValue(125)
param maxCapacity int = 10

@description('''
SSL profiles of the application gateway resource. 
For object structure, refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaysslprofile.
By default this module will add a `Legacy` SSL profile which is using TLS 1.2 with these ciphersuites:
    'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'
    'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'
    'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
    'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
    'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384'
    'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256'
    'TLS_RSA_WITH_AES_256_GCM_SHA384'
    'TLS_RSA_WITH_AES_128_GCM_SHA256'
You can append this profile with your own defined profiles.
''')
param sslProfiles array = []

@description('SSL Certificates. For object structure, refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaysslcertificate.')
param sslCertificates array = []

@description('Cookie based affinity.')
@allowed([
  'Enabled'
  'Disabled'
])
param cookieBasedAffinity string = 'Disabled'

@description('The resourcename of the public ip which will be used for the frontend ip of this application gateway. This should be pre-existing.')
@minLength(1)
@maxLength(80)
param applicationGatewayPublicIpName string

@description('The resourcename of the Web Application Firewall policy name which will be used for this Application Gateway. This should be pre-existing.')
@minLength(1)
@maxLength(80)
param applicationGatewayWebApplicationFirewallPolicyName string

@description('SKU of the application gateway resource. For object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaysku.')
param applicationGatewaySku object = {
  name: 'WAF_v2'
  tier: 'WAF_v2'
}

@description('Web application firewall configuration to be used with this application gateway. Defaults to OWASP 3.1 in Prevention mode. For more information refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaywebapplicationfirewallconfiguration.')
param webApplicationFirewallConfiguration object = {
  enabled: true
  firewallMode: 'Prevention'
  ruleSetType: 'OWASP'
  ruleSetVersion: '3.1'
  requestBodyCheck: true
  maxRequestBodySizeInKb: 128
  fileUploadLimitInMb: 100
}

@description('The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled.')
@minLength(0)
param logAnalyticsWorkspaceResourceId string

@description('Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings.')
param diagnosticSettingsLogsCategories array = [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings')
param diagnosticSettingsMetricsCategories array = [
  {
    categoryGroup: 'AllMetrics'
    enabled: true
  }
]

@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('Enable a private IP on the frontend of this application gateway. This is used if you want to expose your application gateway on your internal VNet. If this is enabled, you have to fill the `privateFrontendStaticIp` parameter too. Defaults to `false`.')
param enablePrivateFrontendIp bool = false

@description('The IP to use as private frontend IP for your application gateway. This should be an IP inside the subnet refered to with the `applicationGatewaySubnetName` parameter. If you want to use this, make sure to enable the `enablePrivateFrontendIp` parameter.')
@minLength(0) // 1.1.1.1
@maxLength(15) // 255.255.255.255
param privateFrontendStaticIp string = ''

@description('Ports configuration for this application gateway. For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayfrontendport.')
param frontendPorts array = [
  {
    name: 'Port_80'
    properties: {
      port: 80
    }
  }
  {
    name: 'Port_443'
    properties: {
      port: 443
    }
  }
]

@description('''
The default SSL policy to use for entrypoints. This policy is used whenever no specific SSL Profile is being selected.
For object structure, please refer to: https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaysslpolicy.
This defaults to TLS 1.2 with these ciphersuites:
  'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'
  'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'
  'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
  'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
  'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384'
  'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256'
''')
param sslPolicy object = {
  policyType: 'Custom'
  minProtocolVersion: 'TLSv1_2'
  cipherSuites: [
    'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'
    'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'
    'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
    'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
    'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384'
    'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256'
  ]
}

@description('The identity to run this application gateway under. This defaults to a System Assigned Managed Identity. For object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#managedserviceidentity.')
param identity object = {
  type: 'SystemAssigned'
}

@description('HTTP probes for automatically testing backend connections. For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayprobe.')
param probes array = []

@description('The rewrite rule sets for this AppGw. For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayrewriteruleset.')
param rewriteRuleSets array = []

@description('Redirect configurations (for example for HTTP -> HTTPS redirects). For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayredirectconfiguration.')
param redirectConfigurations array = []

@description('User defined backend pools. For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaybackendaddresspool.')
param backendAddressPools array = []

@description('User defined request routing rules. For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayrequestroutingrule.')
param requestRoutingRules array = []

@description('User defined HTTP listeners. For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayhttplistener.')
param httpListeners array = []

@description('User defined Backend HTTP Settings. For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaybackendhttpsettings.')
param backendHttpSettingsCollection array = []

@description('User defined subnets to onboard this application gateway into. The first (Default) inclusion will be made with the settings you provide in the `applicationGatewayVirtualNetworkName` & `applicationGatewaySubnetName` parameters. You can add additional configs here. For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayipconfiguration.')
param gatewayIPConfigurations array = []

@description('''
  This is the easy way of creating Application Gateway Entrypoints. You are still able to create them yourselves without the "EZ" parameter, but if you need straightforward reverse proxies, this is a lot easier.
  A list of Public Application Gateway Entrypoints to create. Each object in the list should have the following 3 parameters:
    entrypointHostName: The hostname to use on the frontend. For example: 'my.website.contoso.com'
    backendAddressFqdn: The FQDN or IPAddress to use as the backend pool member. For example: 'www.google.nl' or 'myapp.azurewebsites.net'
    certificateName: The name of the certificate to use. For example: 'my.pfx'. This certificate should already be present in the AppGw.
''')
param ezApplicationGatewayEntrypoints array = []

@description('''
Optional override for the BackendAddressPool names for the EZ Entrypoints feature.
You can use the following placeholders which will be replaced by their respective values:
  - <entrypointHostName> will be replaced by the `entrypointHostName` parameter in each `ezApplicationGatewayEntrypoints` entry. It will also automatically replace -'s with -- and .'s with -'s to comply with naming requirements.
Defaults to: <entrypointHostName>-backendaddresspool
''')
param ezApplicationGatewayEntrypointsBackendAddressPoolName string = '<entrypointHostName>-backendaddresspool'

@description('''
Optional override for the BackendHttpSettingsCollection names for the EZ Entrypoints feature.
You can use the following placeholders which will be replaced by their respective values:
  - <entrypointHostName> will be replaced by the `entrypointHostName` parameter in each `ezApplicationGatewayEntrypoints` entry. It will also automatically replace -'s with -- and .'s with -'s to comply with naming requirements.
Defaults to: <entrypointHostName>-backendaddresssettings
''')
param ezApplicationGatewayEntrypointsBackendHttpSettingsName string = '<entrypointHostName>-backendaddresssettings'

@description('''
Optional override for the BackendHttpSettingsCollection names for the EZ Entrypoints feature.
You can use the following placeholders which will be replaced by their respective values:
  - <entrypointHostName> will be replaced by the `entrypointHostName` parameter in each `ezApplicationGatewayEntrypoints` entry. It will also automatically replace -'s with -- and .'s with -'s to comply with naming requirements.
Defaults to: <entrypointHostName>-backendaddresssettings
''')
param ezApplicationGatewayEntrypointsAfinityCookieNameName string = '<entrypointHostName>-httpscookie'

@description('''
Optional override for the BackendHttpSettingsCollection names for the EZ Entrypoints feature.
You can use the following placeholders which will be replaced by their respective values:
  - <entrypointHostName> will be replaced by the `entrypointHostName` parameter in each `ezApplicationGatewayEntrypoints` entry. It will also automatically replace -'s with -- and .'s with -'s to comply with naming requirements.
Defaults to: <entrypointHostName>-httpslistener
''')
param ezApplicationGatewayEntrypointsHttpsListenerName string = '<entrypointHostName>-httpslistener'

@description('''
Optional override for the BackendHttpSettingsCollection names for the EZ Entrypoints feature.
You can use the following placeholders which will be replaced by their respective values:
  - <entrypointHostName> will be replaced by the `entrypointHostName` parameter in each `ezApplicationGatewayEntrypoints` entry. It will also automatically replace -'s with -- and .'s with -'s to comply with naming requirements.
Defaults to: <entrypointHostName>-requestroutingrule
''')
param ezApplicationGatewayEntrypointsRequestRoutingRuleName string = '<entrypointHostName>-requestroutingrule'

@description('''
Optional override for the BackendHttpSettingsCollection names for the EZ Entrypoints feature.
You can use the following placeholders which will be replaced by their respective values:
  - <entrypointHostName> will be replaced by the `entrypointHostName` parameter in each `ezApplicationGatewayEntrypoints` entry. It will also automatically replace -'s with -- and .'s with -'s to comply with naming requirements.
Defaults to: <entrypointHostName>-httpsprobe
''')
param ezApplicationGatewayEntrypointsProbeName string = '<entrypointHostName>-httpsprobe'

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

// ===================================== Variables =====================================

var ezApplicationGatewayBackendAddressPools = [for entryPoint in ezApplicationGatewayEntrypoints: {
  name: replace(ezApplicationGatewayEntrypointsBackendAddressPoolName, '<entrypointHostName>', replace(replace(entryPoint.entrypointHostName, '-', '--'), '.', '-'))
  properties: {
    backendAddresses: [
      {
        fqdn: entryPoint.backendAddressFqdn
      }
    ]
  }
}]

var ezApplicationGatewayBackendHttpSettingsCollection = [for entryPoint in ezApplicationGatewayEntrypoints: {
  name: replace(ezApplicationGatewayEntrypointsBackendHttpSettingsName, '<entrypointHostName>', replace(replace(entryPoint.entrypointHostName, '-', '--'), '.', '-'))
  properties: {
    port: 443
    protocol: 'Https'
    cookieBasedAffinity: 'Disabled'
    connectionDraining: {
      enabled: false
      drainTimeoutInSec: 1
    }
    pickHostNameFromBackendAddress: true
    affinityCookieName: replace(ezApplicationGatewayEntrypointsAfinityCookieNameName, '<entrypointHostName>', replace(replace(entryPoint.entrypointHostName, '-', '--'), '.', '-'))
    requestTimeout: 30
    probe: {
      id: resourceId(subscription().subscriptionId, az.resourceGroup().name, 'Microsoft.Network/applicationGateways/probes', applicationGatewayName, replace(ezApplicationGatewayEntrypointsProbeName, '<entrypointHostName>', replace(replace(entryPoint.entrypointHostName, '-', '--'), '.', '-')))
    }
  }
}]

var ezApplicationGatewayHttpListeners = [for entryPoint in ezApplicationGatewayEntrypoints: {
  name: replace(ezApplicationGatewayEntrypointsHttpsListenerName, '<entrypointHostName>', replace(replace(entryPoint.entrypointHostName, '-', '--'), '.', '-'))
  properties: {
    frontendIPConfiguration: {
      id: resourceId(subscription().subscriptionId, az.resourceGroup().name, 'Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGatewayFrontendIP')
    }
    frontendPort: {
      id: resourceId(subscription().subscriptionId, az.resourceGroup().name, 'Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'Port_443') // TODO: Hardcoded value
    }
    protocol: 'Https'
    sslCertificate: {
      id: resourceId(subscription().subscriptionId, az.resourceGroup().name, 'Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, replace(replace(replace(replace(entryPoint.certificateName, '-', '--'), '.', '-'), '_', '-'), ' ', '-'))
    }
    hostName: entryPoint.entrypointHostName
    requireServerNameIndication: true
  }
}]

var ezApplicationGatewayRequestRoutingRules = [for i in range(0, length(ezApplicationGatewayEntrypoints)): {
  name: replace(ezApplicationGatewayEntrypointsRequestRoutingRuleName, '<entrypointHostName>', replace(replace(ezApplicationGatewayEntrypoints[i].entrypointHostName, '-', '--'), '.', '-'))
  properties: {
    ruleType: 'Basic'
    priority: (i * 10) + 10000
    httpListener: {
      id: resourceId(subscription().subscriptionId, az.resourceGroup().name, 'Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, replace(ezApplicationGatewayEntrypointsHttpsListenerName, '<entrypointHostName>', replace(replace(ezApplicationGatewayEntrypoints[i].entrypointHostName, '-', '--'), '.', '-')))
    }
    backendAddressPool: {
      id: resourceId(subscription().subscriptionId, az.resourceGroup().name, 'Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, replace(ezApplicationGatewayEntrypointsBackendAddressPoolName, '<entrypointHostName>', replace(replace(ezApplicationGatewayEntrypoints[i].entrypointHostName, '-', '--'), '.', '-')))
    }
    backendHttpSettings: {
      id: resourceId(subscription().subscriptionId, az.resourceGroup().name, 'Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, replace(ezApplicationGatewayEntrypointsBackendHttpSettingsName, '<entrypointHostName>', replace(replace(ezApplicationGatewayEntrypoints[i].entrypointHostName, '-', '--'), '.', '-')))
    }
  }
}]

var ezApplicationGatewayProbes = [for entryPoint in ezApplicationGatewayEntrypoints: {
  name: replace(ezApplicationGatewayEntrypointsProbeName, '<entrypointHostName>', replace(replace(entryPoint.entrypointHostName, '-', '--'), '.', '-'))
  properties: {
    protocol: 'Https'
    path: '/'
    interval: 60
    timeout: 20
    unhealthyThreshold: 2
    pickHostNameFromBackendHttpSettings: true
    minServers: 0
    match: {
      statusCodes: [
        '200-399'
      ]
    }
  }
}]

@description('The public frontend ip configuration for this application gateway. This will be merged into the `frontendIpConfigurations` variable.')
var publicFrontendIpConfiguration = {
  name: 'appGatewayFrontendIP'
  properties: {
    privateIPAllocationMethod: 'Dynamic'
    publicIPAddress: {
      id: applicationGatewayPublicIp.id
    }
  }
}

@description('The default frontend ip configurations. If the private frontend IP feature is enabled, this will prepare the correct object structure for both public & private ip\'s. If disabled, it will only include the public ip.')
var frontendIpConfigurations = enablePrivateFrontendIp ? [
  publicFrontendIpConfiguration
  {
    name: 'appGatewayPrivateFrontendIP'
    properties: {
      privateIPAllocationMethod: 'Static'
      privateIPAddress: privateFrontendStaticIp
      subnet: {
        id: '${resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', applicationGatewayVirtualNetworkName)}/subnets/${applicationGatewaySubnetName}'
      }
    }
  }
] : [
  publicFrontendIpConfiguration
]

@description('This unifies the user-defined SSL profiles & the default legacy profile we offer from this module.')
var unifiedSslProfiles = union(sslProfiles, [
    {
      name: 'Legacy'
      properties: {
        sslPolicy: {
          policyType: 'Custom'
          minProtocolVersion: 'TLSv1_2'
          cipherSuites: [
            'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'
            'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'
            'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
            'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
            'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384'
            'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256'
            'TLS_RSA_WITH_AES_256_GCM_SHA384'
            'TLS_RSA_WITH_AES_128_GCM_SHA256'
          ]
        }
        clientAuthConfiguration: {
          verifyClientCertIssuerDN: false
        }
      }
    }
  ])

@description('This unifies the user-defined backend pools & the ezApplicationGatewayBackendAddressPools with the default application gateway backendpool. We need at least 1 backendpool for the appgw to be created, so we just create a dummy default one.')
var unifiedBackendAddressPools = union(union(backendAddressPools, [
      {
        name: 'appGatewayBackendPool'
        properties: {
          backendAddresses: []
        }
      }
    ]), ezApplicationGatewayBackendAddressPools)

@description('This unifies the user-defined request routing rules & the ezApplicationGatewayRequestRoutingRules with the default application gateway request routing rule. We need at least 1 request routing rule for the appgw to be created, so we just create a dummy default one.')
var unifiedRequestRoutingRules = union(union(requestRoutingRules, [
      {
        name: 'defaultRule'
        properties: {
          ruleType: 'Basic'
          priority: 10
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'appGatewayHttpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'appGatewayBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'appGatewayBackendHttpSettings')
          }
        }
      }
    ]), ezApplicationGatewayRequestRoutingRules)

@description('This unifies the user-defined http listener & the ezApplicationGatewayHttpListeners with the default application gateway http listener. We need at least 1 http listener for the appgw to be created, so we just create a dummy default one.')
var unifiedHttpListeners = union(union([
      {
        name: 'appGatewayHttpListener'
        properties: {
          firewallPolicy: {
            id: applicationGatewayWafPolicies.id
          }
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'Port_80')
          }
          protocol: 'Http'
          requireServerNameIndication: false
        }
      }
    ], httpListeners), ezApplicationGatewayHttpListeners)

@description('This unifies the user-defined backend http settings & the ezApplicationGatewayBackendHttpSettingsCollection with the default application gateway backend http settings. We need at least 1 backend http settings for the appgw to be created, so we just create a dummy default one.')
var unifiedBackendHttpSettingsCollection = union(union(backendHttpSettingsCollection, [
      {
        name: 'appGatewayBackendHttpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: cookieBasedAffinity
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]), ezApplicationGatewayBackendHttpSettingsCollection)

@description('This unifies the user-defined probes with the ez gateway probes.')
var unifiedProbes = union(probes, ezApplicationGatewayProbes)

@description('This unifies the user-defined frontend ip configurations with the default application gateway backend frontend ip configuration. We need at least 1 frontend ip configuration for the appgw to be created, so we just create a dummy default one.')
var unifiedGatewayIPConfigurations = union(gatewayIPConfigurations, [
    {
      name: 'appGatewayIpConfig'
      properties: {
        subnet: {
          id: '${resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', applicationGatewayVirtualNetworkName)}/subnets/${applicationGatewaySubnetName}'
        }
      }
    }
  ])

// ===================================== Resources =====================================

@description('Fetch the existing AppGW WAF policy for further use.')
#disable-next-line BCP081
resource applicationGatewayWafPolicies 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2021-08-01' existing = {
  name: applicationGatewayWebApplicationFirewallPolicyName
}

@description('Fetch the existing AppGW public IP address for further use.')
#disable-next-line BCP081
resource applicationGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2021-08-01' existing = {
  name: applicationGatewayPublicIpName
}

@description('Upsert the Application Gateway with the given parameters.')
resource applicationGateway 'Microsoft.Network/applicationGateways@2021-08-01' = {
  name: applicationGatewayName
  tags: tags
  location: location
  identity: identity
  properties: {
    sku: applicationGatewaySku
    autoscaleConfiguration: {
      minCapacity: minCapacity
      maxCapacity: maxCapacity
    }
    gatewayIPConfigurations: unifiedGatewayIPConfigurations
    frontendIPConfigurations: frontendIpConfigurations
    frontendPorts: frontendPorts
    backendAddressPools: unifiedBackendAddressPools
    backendHttpSettingsCollection: unifiedBackendHttpSettingsCollection
    httpListeners: unifiedHttpListeners
    requestRoutingRules: unifiedRequestRoutingRules
    enableHttp2: true
    webApplicationFirewallConfiguration: webApplicationFirewallConfiguration
    firewallPolicy: {
      id: applicationGatewayWafPolicies.id
    }
    sslProfiles: unifiedSslProfiles
    sslPolicy: sslPolicy
    sslCertificates: sslCertificates
    probes: unifiedProbes
    rewriteRuleSets: rewriteRuleSets
    redirectConfigurations: redirectConfigurations
  }
}

@description('Upsert the diagnostic settings associated with the application gateway.')
resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: applicationGateway
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

// ===================================== Outputs =====================================
@description('Output the application gateway resource id.')
output applicationGatewayId string = applicationGateway.id
@description('Output the application gateway name.')
output applicationGatewayName string = applicationGateway.name
