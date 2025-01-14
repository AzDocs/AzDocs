/*
.SYNOPSIS
Creating an application gateway 
.DESCRIPTION
Creating an application gateway
.EXAMPLE
<pre>
module appgw 'br:contosoregistry.azurecr.io/network/applicationGateways:latest' = {
  name: 'Deploymentname'
  params: {
    applicationGatewayVirtualNetworkName:'myfirstvnet'
    applicationGatewaySubnetName: 'gateway-sub'
    applicationGatewayName: 'myfirstappgwpub'
    applicationGatewayPublicIpName 'myfirstappgwpubip'
    applicationGatewayWebApplicationFirewallPolicyName: 'myfirstappgwpubwaf'
    logAnalyticsWorkspaceResourceId: '/subscriptions/1896c5f9-5e13-4ed2-8018-16aba4e6e83d/resourcegroups/law-rg/providers/microsoft.operationalinsights/workspaces/mylaw'
    ezApplicationGatewayEntrypoints: [
      {
        entrypointHostName: 'test1.com'
        backendAddressFqdn": 'www.google.nl'
        certificateName: 'certificate1.pfx'
      },
      {
        entrypointHostName: 'test2.com'
        backendAddressFqdn: ''
        certificateName: 'test2.pfx'
        backendSettingsOverrideHostName: 'test2.org'
        backendSettingsOverrideTrustedRootCertificates: true
        sslProfileName: 'testprofile'
      }
    ],
    sslProfiles: [
      {
        name: 'testprofile'
        properties: {
          sslPolicy: {
            policyType: 'CustomV2'
            minProtocolVersion: 'TLSv1_3'
            cipherSuites: []
          }
          clientAuthConfiguration: {
            verifyClientCertIssuerDN: true
            verifyClientRevocation: 'OCSP'
          }
          trustedClientCertificates: [
            {
              id: resourceId(subscription().subscriptionId, 'myfirstresourcegroup', 'Microsoft.Network/applicationGateways/trustedClientCertificates', 'myfirstappgwpub', 'testcert')
            }
          ]
        }
      }
    ],
    var trustedClientCertificates = [
      {
        name: 'testcert'
        properties: {
          data: '-----BEGIN CERTIFICATE-----<<PLAINTEXTCERTIFCATEBYTES>>-----END CERTIFICATE-----'
        }
      }
    ]
  }
}
</pre>
<p>Creates an application gateway with the name 'myfirstappgwpub'</p>
.LINKS
- [Bicep Microsoft.Network applicationGateways](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?pivots=deployment-language-bicep)
*/

// ===================================== Parameters =====================================
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = az.resourceGroup().location

@description('The name of the VNet where you want to onboard this Application Gateway into.')
@minLength(2)
@maxLength(64)
param applicationGatewayVirtualNetworkName string

@description('The name resourcegroup where the virtual network resource is allocated.')
param virtualNetworkResourceGroupName string = az.resourceGroup().name

@description('Name of the subnet where the Application Gateway should reside in.')
@minLength(1)
@maxLength(80)
param applicationGatewaySubnetName string

@description('The name of the Application Gateway.')
@minLength(1)
@maxLength(80)
param applicationGatewayName string

@description('The name of the static webapp, by default the first 36 characters of the applicationGatewayName')
@minLength(1)
@maxLength(40)
param redirectStaticWebAppName string = 'stapp-${take(applicationGatewayName, 34)}'

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
For object structure, refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaysslprofile).
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

@description('Trusted client certificates of the application gateway resource.')
param trustedClientCertificates array = []

@description('SSL Certificates. For object structure, refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaysslcertificate).')
param sslCertificates array = []

@description('Trusted Root Certificates for this App GW. For object structure, refer to the [Bicep resource definition](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?pivots=deployment-language-bicep#applicationgatewaytrustedrootcertificate)')
param trustedRootCertificates array = []

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

type ApplicationGatewaySku = {
  name:
    | 'Basic'
    | 'Standard_Large'
    | 'Standard_Medium'
    | 'Standard_Small'
    | 'Standard_v2'
    | 'WAF_Large'
    | 'WAF_Medium'
    | 'WAF_v2'
  tier: 'Basic' | 'Standard' | 'Standard_v2' | 'WAF' | 'WAF_v2'
  family: 'Generation_1' | 'Generation_2' | null
  capacity: int?
}

@description('SKU of the application gateway resource. For object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaysku).')
param applicationGatewaySku ApplicationGatewaySku = {
  name: 'WAF_v2'
  tier: 'WAF_v2'
  family: 'Generation_2'
}

@description('The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled.')
param logAnalyticsWorkspaceResourceId string = ''

@description('Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings).')
param diagnosticSettingsLogsCategories array = [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings).')
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

@description('Ports configuration for this application gateway. For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayfrontendport).')
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
For object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaysslpolicy).
''')
param sslPolicy object = {
  policyType: 'Predefined'
  policyName: 'AppGwSslPolicy20220101S'
}

@description('The identity to run this application gateway under. This defaults to a System Assigned Managed Identity. For object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#managedserviceidentity).')
param identity object = {
  type: 'SystemAssigned'
}

@description('HTTP probes for automatically testing backend connections. For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayprobe).')
param probes array = []

@description('The rewrite rule sets for this AppGw. For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayrewriteruleset).')
param rewriteRuleSets array = []

@description('Redirect configurations (for example for HTTP -> HTTPS redirects). For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayredirectconfiguration).')
param redirectConfigurations array = []

@description('User defined backend pools. For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaybackendaddresspool).')
param backendAddressPools array = []

@description('User defined Url Path Maps for path-based routing. For array/object structure, please refer to the [Bicep resource definition](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?pivots=deployment-language-bicep#applicationgatewayurlpathmap).')
param urlPathMaps array = []

@description('User defined request routing rules. For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayrequestroutingrule).')
param requestRoutingRules array = []

@description('User defined HTTP listeners. For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayhttplistener).')
param httpListeners array = []

@description('User defined Backend HTTP Settings. For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaybackendhttpsettings).')
param backendHttpSettingsCollection array = []

@description('User defined subnets to onboard this application gateway into. The first (Default) inclusion will be made with the settings you provide in the `applicationGatewayVirtualNetworkName` & `applicationGatewaySubnetName` parameters. You can add additional configs here. For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayipconfiguration).')
param gatewayIPConfigurations array = []

@description('''
  This is the easy way of creating Application Gateway Entrypoints. You are still able to create them yourselves without the "EZ" parameter, but if you need straightforward reverse proxies, this is a lot easier.
  A list of Public Application Gateway Entrypoints to create. Each object in the list should have the following 3 parameters:
    entrypointHostName: The hostname to use on the frontend. For example: 'my.website.contoso.com'
    backendAddressFqdn: The FQDN or IPAddress to use as the backend pool member. For example: 'www.google.nl' or 'myapp.azurewebsites.net'
    certificateName: The name of the certificate to use. For example: 'my.pfx'. This certificate should already be present in the AppGw.
    (optional)backendSettingsOverrideHostName: Hostname used that is used for the backend resouces
    (optional)backendSettingsOverrideTrustedRootCertificates: if true. all the given trusted root CA's are added.
    (optional)backendSettingsOverrideProbePath: If set, the given probe path is used instead of the default one.
    (optional)backendSettingsOverrideRequestTimeout: If set, the given request timeout is used instead of the default one (30 seconds).
    (optional)rewriteRulesetName: if set, it would bind the rewrite set name that is given.

<details>
  <summary>Click to show examples</summary>
  {
    "entrypointHostName": "test1.com",
    "backendAddressFqdn": "www.google.nl",
    "certificateName": "certificate1.pfx"
  },
  {
    "entrypointHostName": "test2.com",
    "backendAddressFqdn": "",
    "certificateName": "test2.pfx",
    "backendSettingsOverrideHostName": "test2.org",
    "backendSettingsOverrideTrustedRootCertificates": true,
    "backendSettingsOverrideProbePath": "/healthprobe",
    "backendSettingsOverrideRequestTimeout": 30,
    "rewriteRulesetName" : "fallback-rewriteset",
    "sslProfileName": "testprofile"
  }
</details>
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

@description('''
The default frontend Ip Configuration that is used to attach the httplisteners to.
''')
@allowed([
  'appGatewayFrontendIP'
  'appGatewayPrivateFrontendIP'
])
param defaultFrontendIpConfigurationName string = enablePrivateFrontendIp
  ? 'appGatewayPrivateFrontendIP'
  : 'appGatewayFrontendIP'

@description('''
If this is true the default port 80 rule will be adjusted so that it will redirect http to https requests.
If `FqdnToRedirect` is specified, that url will be used. Expected is that the website would redirect any requests to https.
If `FqdnToRedirect` is not specified, an Static Web App will be created that would redirect http to https traffic.

The default port 80 will be configured with a rewrite rule that would change the response from the `FqdnToRedirect` or the fqdn of the static web app address to the original requested host.
''')
param redirectHttpToHttps bool = false

@description('Supply a fqdn to use for redirection. It is expected that the website would redirect all traffic to https with the same fqdn. See also `RedirectHttpToHttps`for more information')
param fqdnToRedirect string = ''

@description('If this is true the default port 80 rule, listener, backendsettings and backendpool will be added to the application gateway.')
param deployDefaults bool = true

@description('The zones to use for this application gateway.')
@allowed([
  '1'
  '2'
  '3'
])
param availabilityZones array = []

@description('Optional parameter to set all custom errorpages on the application gateway to the html file at this url')
param customErrorpagesUrl string = ''

@description('Optional parameter to set custom errorpage for error 403 on the application gateway to the html file at this url')
param customErrorpage403Url string = ''

@description('Optional parameter to set custom errorpage for error 502 on the application gateway to the html file at this url')
param customErrorpage502Url string = ''

@description('Optional array of private link configurations. For object structure, please refer to the [Bicep resource definition](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayprivatelinkconfiguration).')
param privateLinkConfigurations array = []

@description('Optional array for extended frontend IP configurations. For object structure, please refer to the [Bicep resource definition](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?pivots=deployment-language-bicep#applicationgatewayfrontendipconfiguration).')
param extendedFrontendIpConfigurations array = []

// ===================================== Variables =====================================
@description('Building up the Backend Address Pools based on ezApplicationGatewayEntrypoints')
var ezApplicationGatewayBackendAddressPools = [
  for entryPoint in ezApplicationGatewayEntrypoints: {
    name: replace(
      ezApplicationGatewayEntrypointsBackendAddressPoolName,
      '<entrypointHostName>',
      replace(replace(entryPoint.entrypointHostName, '-', '--'), '.', '-')
    )
    properties: union(
      {},
      empty(entryPoint.backendAddressFqdn)
        ? { backendAddresses: [] }
        : {
            backendAddresses: [
              {
                fqdn: entryPoint.backendAddressFqdn
              }
            ]
          }
    )
  }
]

@description('Create a list of trusted root ca id\'s based on the param trustedRootCertificates')
var trustedRootCertificateIds = [
  for trustedRootCertificate in trustedRootCertificates: {
    id: resourceId(
      subscription().subscriptionId,
      az.resourceGroup().name,
      'Microsoft.Network/applicationGateways/trustedRootCertificates',
      applicationGatewayName,
      trustedRootCertificate.name
    )
  }
]

var ezApplicationGatewayBackendHttpSettingsCollection = [
  for entryPoint in ezApplicationGatewayEntrypoints: {
    name: replace(
      ezApplicationGatewayEntrypointsBackendHttpSettingsName,
      '<entrypointHostName>',
      replace(replace(entryPoint.entrypointHostName, '-', '--'), '.', '-')
    )
    properties: union(
      {
        port: 443
        protocol: 'Https'
        cookieBasedAffinity: 'Disabled'
        connectionDraining: {
          enabled: false
          drainTimeoutInSec: 1
        }
        pickHostNameFromBackendAddress: contains(entryPoint, 'backendSettingsOverrideHostName') && !empty(entryPoint.backendSettingsOverrideHostName)
          ? false
          : true
        hostName: contains(entryPoint, 'backendSettingsOverrideHostName') && !empty(entryPoint.backendSettingsOverrideHostName)
          ? entryPoint.backendSettingsOverrideHostName
          : ''
        affinityCookieName: replace(
          ezApplicationGatewayEntrypointsAfinityCookieNameName,
          '<entrypointHostName>',
          replace(replace(entryPoint.entrypointHostName, '-', '--'), '.', '-')
        )
        requestTimeout: contains(entryPoint, 'backendSettingsOverrideRequestTimeout') && entryPoint.backendSettingsOverrideRequestTimeout != null && entryPoint.backendSettingsOverrideRequestTimeout >= 1
          ? entryPoint.backendSettingsOverrideRequestTimeout
          : 30
        probe: {
          id: resourceId(
            subscription().subscriptionId,
            az.resourceGroup().name,
            'Microsoft.Network/applicationGateways/probes',
            applicationGatewayName,
            replace(
              ezApplicationGatewayEntrypointsProbeName,
              '<entrypointHostName>',
              replace(replace(entryPoint.entrypointHostName, '-', '--'), '.', '-')
            )
          )
        }
      },
      contains(entryPoint, 'backendSettingsOverrideTrustedRootCertificates') && entryPoint.backendSettingsOverrideTrustedRootCertificates == true
        ? {
            trustedRootCertificates: trustedRootCertificateIds
          }
        : {}
    )
  }
]

var ezApplicationGatewayHttpListeners = [
  for entryPoint in ezApplicationGatewayEntrypoints: {
    name: replace(
      ezApplicationGatewayEntrypointsHttpsListenerName,
      '<entrypointHostName>',
      replace(replace(entryPoint.entrypointHostName, '-', '--'), '.', '-')
    )
    properties: union(
      {
        frontendIPConfiguration: {
          id: resourceId(
            subscription().subscriptionId,
            az.resourceGroup().name,
            'Microsoft.Network/applicationGateways/frontendIPConfigurations',
            applicationGatewayName,
            defaultFrontendIpConfigurationName
          )
        }
        frontendPort: {
          id: resourceId(
            subscription().subscriptionId,
            az.resourceGroup().name,
            'Microsoft.Network/applicationGateways/frontendPorts',
            applicationGatewayName,
            'Port_443'
          ) // TODO: Hardcoded value
        }
        protocol: 'Https'
        sslCertificate: {
          id: resourceId(
            subscription().subscriptionId,
            az.resourceGroup().name,
            'Microsoft.Network/applicationGateways/sslCertificates',
            applicationGatewayName,
            replace(replace(replace(replace(entryPoint.certificateName, '-', '--'), '.', '-'), '_', '-'), ' ', '-')
          )
        }
        hostName: entryPoint.entrypointHostName
        requireServerNameIndication: true
      },
      contains(entryPoint, 'sslProfileName') && !empty(entryPoint.sslProfileName)
        ? {
            sslProfile: {
              id: resourceId(
                subscription().subscriptionId,
                az.resourceGroup().name,
                'Microsoft.Network/applicationGateways/sslProfiles',
                applicationGatewayName,
                entryPoint.sslProfileName
              )
            }
          }
        : {}
    )
  }
]

var ezApplicationGatewayRequestRoutingRules = [
  for i in range(0, length(ezApplicationGatewayEntrypoints)): {
    name: replace(
      ezApplicationGatewayEntrypointsRequestRoutingRuleName,
      '<entrypointHostName>',
      replace(replace(ezApplicationGatewayEntrypoints[i].entrypointHostName, '-', '--'), '.', '-')
    )
    properties: union(
      {
        ruleType: 'Basic'
        priority: (i * 10) + 10000
        httpListener: {
          id: resourceId(
            subscription().subscriptionId,
            az.resourceGroup().name,
            'Microsoft.Network/applicationGateways/httpListeners',
            applicationGatewayName,
            replace(
              ezApplicationGatewayEntrypointsHttpsListenerName,
              '<entrypointHostName>',
              replace(replace(ezApplicationGatewayEntrypoints[i].entrypointHostName, '-', '--'), '.', '-')
            )
          )
        }
        backendAddressPool: {
          id: resourceId(
            subscription().subscriptionId,
            az.resourceGroup().name,
            'Microsoft.Network/applicationGateways/backendAddressPools',
            applicationGatewayName,
            replace(
              ezApplicationGatewayEntrypointsBackendAddressPoolName,
              '<entrypointHostName>',
              replace(replace(ezApplicationGatewayEntrypoints[i].entrypointHostName, '-', '--'), '.', '-')
            )
          )
        }
        backendHttpSettings: {
          id: resourceId(
            subscription().subscriptionId,
            az.resourceGroup().name,
            'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
            applicationGatewayName,
            replace(
              ezApplicationGatewayEntrypointsBackendHttpSettingsName,
              '<entrypointHostName>',
              replace(replace(ezApplicationGatewayEntrypoints[i].entrypointHostName, '-', '--'), '.', '-')
            )
          )
        }
      },
      contains(ezApplicationGatewayEntrypoints[i], 'rewriteRulesetName') && !empty(ezApplicationGatewayEntrypoints[i].rewriteRulesetName)
        ? {
            rewriteRuleSet: {
              id: resourceId(
                subscription().subscriptionId,
                az.resourceGroup().name,
                'Microsoft.Network/applicationGateways/rewriteRuleSets',
                applicationGatewayName,
                ezApplicationGatewayEntrypoints[i].rewriteRulesetName
              )
            }
          }
        : {}
    )
  }
]

var ezApplicationGatewayProbes = [
  for entryPoint in ezApplicationGatewayEntrypoints: {
    name: replace(
      ezApplicationGatewayEntrypointsProbeName,
      '<entrypointHostName>',
      replace(replace(entryPoint.entrypointHostName, '-', '--'), '.', '-')
    )
    properties: {
      protocol: 'Https'
      path: contains(entryPoint, 'backendSettingsOverrideProbePath') && !empty(entryPoint.backendSettingsOverrideProbePath)
        ? entryPoint.backendSettingsOverrideProbePath
        : '/'
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
  }
]

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
resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name: applicationGatewayVirtualNetworkName
  scope: az.resourceGroup(virtualNetworkResourceGroupName)
}

@description('The default frontend ip configurations. If the private frontend IP feature is enabled, this will prepare the correct object structure for both public & private ip\'s. If disabled, it will only include the public ip.')
var frontendIpConfigurations = enablePrivateFrontendIp
  ? [
      publicFrontendIpConfiguration
      {
        name: 'appGatewayPrivateFrontendIP'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: privateFrontendStaticIp
          subnet: {
            id: '${vnet.id}/subnets/${applicationGatewaySubnetName}'
          }
        }
      }
    ]
  : [
      publicFrontendIpConfiguration
    ]

@description('This is the custom v2 legacy profile')
var legacyCustomV2Profile = {
  name: 'Legacy'
  properties: {
    sslPolicy: {
      policyType: 'Predefined'
      policyName: 'AppGwSslPolicy20220101'
    }
    clientAuthConfiguration: {
      verifyClientCertIssuerDN: false
    }
  }
}

@description('This is the custom v1 legacy profile')
var legacyCustomProfile = {
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
        'TLS_RSA_WITH_AES_256_GCM_SHA384'
        'TLS_RSA_WITH_AES_128_GCM_SHA256'
      ]
    }
    clientAuthConfiguration: {
      verifyClientCertIssuerDN: false
    }
  }
}

@description('Defines the default legacy profile, based on if the main profile is customv2 or something else.')
var legacyProfile = sslPolicy.policyType == 'Custom' || (sslPolicy.policyType == 'Predefined' && startsWith(
    sslPolicy.policyName,
    'AppGwSslPolicy201'
  ))
  ? legacyCustomProfile
  : legacyCustomV2Profile

var defaultBackendPoolName = 'appGatewayBackendPool'
var defaultRuleName = 'defaultRule'
var defaultRewriteRuleName = 'appGatewayRedirectRule'
var defaultHttpListener = 'appGatewayHttpListener'
var defaultBackendHttpSettingsName = 'appGatewayBackendHttpSettings'

@description('This unifies the user-defined SSL profiles & the default legacy profile we offer from this module.')
var unifiedSslProfiles = union(sslProfiles, [legacyProfile])

@description('Default backendpool that is used for all port 80 calls')
var defaultBackendAddressPool = deployDefaults
  ? [
      {
        name: defaultBackendPoolName
        properties: {
          backendAddresses: (!redirectHttpToHttps)
            ? []
            : [
                {
                  fqdn: empty(fqdnToRedirect) ? swaRedirect.outputs.staticWebAppUrl : fqdnToRedirect
                }
              ]
        }
      }
    ]
  : []

@description('This unifies the user-defined backend pools & the ezApplicationGatewayBackendAddressPools with the default application gateway backendpool. We need at least 1 backendpool for the appgw to be created, so we just create a dummy default one.')
var unifiedBackendAddressPools = union(
  backendAddressPools,
  ezApplicationGatewayBackendAddressPools,
  defaultBackendAddressPool
)

@description('The priority should be between 1 and 20000')
var maxPriority = 20000

@description('This unifies the user-defined request routing rules & the ezApplicationGatewayRequestRoutingRules with the default application gateway request routing rule. We need at least 1 request routing rule for the appgw to be created, so we just create a dummy default one.')
var unifiedRequestRoutingRules = union(
  requestRoutingRules,
  ezApplicationGatewayRequestRoutingRules,
  deployDefaults
    ? [
        {
          name: defaultRuleName
          properties: union(
            {
              ruleType: 'Basic'
              priority: maxPriority
              httpListener: {
                id: resourceId(
                  'Microsoft.Network/applicationGateways/httpListeners',
                  applicationGatewayName,
                  defaultHttpListener
                )
              }
              backendAddressPool: {
                id: resourceId(
                  'Microsoft.Network/applicationGateways/backendAddressPools',
                  applicationGatewayName,
                  defaultBackendPoolName
                )
              }
              backendHttpSettings: {
                id: resourceId(
                  'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
                  applicationGatewayName,
                  defaultBackendHttpSettingsName
                )
              }
            },
            redirectHttpToHttps
              ? {
                  rewriteRuleSet: {
                    id: resourceId(
                      'Microsoft.Network/applicationGateways/rewriteRuleSets',
                      applicationGatewayName,
                      defaultRewriteRuleName
                    )
                  }
                }
              : {}
          )
        }
      ]
    : []
)

@description('This unifies the user-defined http listener & the ezApplicationGatewayHttpListeners with the default application gateway http listener. We need at least 1 http listener for the appgw to be created, so we just create a dummy default one.')
var unifiedHttpListeners = union(
  httpListeners,
  ezApplicationGatewayHttpListeners,
  deployDefaults
    ? [
        {
          name: defaultHttpListener
          properties: {
            firewallPolicy: {
              id: applicationGatewayWafPolicies.id
            }
            frontendIPConfiguration: {
              id: resourceId(
                'Microsoft.Network/applicationGateways/frontendIPConfigurations',
                applicationGatewayName,
                defaultFrontendIpConfigurationName
              )
            }
            frontendPort: {
              id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'Port_80') //TODO hardcode refence to a param
            }
            protocol: 'Http'
            requireServerNameIndication: false
          }
        }
      ]
    : []
)

var defaultBackendHttpSettings = deployDefaults
  ? [
      {
        name: defaultBackendHttpSettingsName
        properties: union(
          {
            port: 80
            protocol: 'Http'
            cookieBasedAffinity: cookieBasedAffinity
            pickHostNameFromBackendAddress: true
            requestTimeout: 20
          },
          (!redirectHttpToHttps)
            ? {}
            : {
                pickHostNameFromBackendAddress: false
                hostname: empty(fqdnToRedirect) ? swaRedirect.outputs.staticWebAppUrl : fqdnToRedirect
              }
        )
      }
    ]
  : []

@description('This unifies the user-defined backend http settings & the ezApplicationGatewayBackendHttpSettingsCollection with the default application gateway backend http settings. We need at least 1 backend http settings for the appgw to be created, so we just create a dummy default one.')
var unifiedBackendHttpSettingsCollection = union(
  backendHttpSettingsCollection,
  ezApplicationGatewayBackendHttpSettingsCollection,
  defaultBackendHttpSettings
)

@description('This unifies the user-defined probes with the ez gateway probes.')
var unifiedProbes = union(probes, ezApplicationGatewayProbes)

@description('This unifies the user-defined frontend ip configurations with the default application gateway backend frontend ip configuration. We need at least 1 frontend ip configuration for the appgw to be created, so we just create a dummy default one.')
var unifiedGatewayIPConfigurations = union(gatewayIPConfigurations, [
  {
    name: 'appGatewayIpConfig'
    properties: {
      subnet: {
        id: '${vnet.id}/subnets/${applicationGatewaySubnetName}'
      }
    }
  }
])

var unifiedRewriteRuleSets = union(
  rewriteRuleSets,
  redirectHttpToHttps
    ? [
        {
          name: 'appGatewayRedirectRule'
          properties: {
            rewriteRules: [
              {
                ruleSequence: 100
                conditions: [
                  {
                    variable: 'http_resp_Location'
                    pattern: '(https?):\\/\\/${replace(empty(fqdnToRedirect) ? swaRedirect.outputs.staticWebAppUrl : fqdnToRedirect, '.', '\\.')}(.*)$'
                    ignoreCase: true
                    negate: false
                  }
                ]
                name: 'RedirectToOriginalUrl'
                actionSet: {
                  requestHeaderConfigurations: []
                  responseHeaderConfigurations: [
                    {
                      headerName: 'Location'
                      headerValue: 'https://{var_host}{http_resp_Location_2}'
                    }
                  ]
                }
              }
            ]
          }
        }
      ]
    : []
)

var customErrorConfigurations = union(
  [],
  (!empty(customErrorpage403Url) || !empty(customErrorpagesUrl))
    ? [
        {
          customErrorPageUrl: !empty(customErrorpage403Url) ? customErrorpage403Url : customErrorpagesUrl
          statusCode: 'HttpStatus403'
        }
      ]
    : [],
  (!empty(customErrorpage502Url) || !empty(customErrorpagesUrl))
    ? [
        {
          customErrorPageUrl: !empty(customErrorpage502Url) ? customErrorpage502Url : customErrorpagesUrl
          statusCode: 'HttpStatus502'
        }
      ]
    : []
)

var generation1TierList = [
  'Standard'
  'WAF'
]

var sku = {
  name: applicationGatewaySku.name
  tier: applicationGatewaySku.tier
  family: contains(generation1TierList, applicationGatewaySku.tier) ? 'Generation_1' : 'Generation_2'
  capacity: applicationGatewaySku.capacity ?? null
}

// ===================================== Resources =====================================
@description('Static website if http needs to be redirected to https and no fqdn is supplied with `FqdnToRedirect`')
module swaRedirect '../Web/staticSites.bicep' = if (redirectHttpToHttps && empty(fqdnToRedirect)) {
  name: '${take(deployment().name, 60)}-swa' //64 - 4 = 60
  params: {
    location: location
    staticWebAppName: redirectStaticWebAppName
  }
}

@description('Fetch the existing AppGW WAF policy for further use.')
resource applicationGatewayWafPolicies 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2021-08-01' existing = {
  name: applicationGatewayWebApplicationFirewallPolicyName
}

@description('Fetch the existing AppGW public IP address for further use.')
resource applicationGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2022-01-01' existing = {
  name: applicationGatewayPublicIpName
}

@description('Upsert the Application Gateway with the given parameters.')
resource applicationGateway 'Microsoft.Network/applicationGateways@2024-05-01' = {
  name: applicationGatewayName
  tags: tags
  location: location
  identity: identity
  properties: {
    sku: sku
    autoscaleConfiguration: {
      minCapacity: minCapacity
      maxCapacity: max(maxCapacity, minCapacity)
    }
    customErrorConfigurations: customErrorConfigurations
    gatewayIPConfigurations: unifiedGatewayIPConfigurations
    frontendIPConfigurations: empty(extendedFrontendIpConfigurations)
      ? frontendIpConfigurations
      : union(frontendIpConfigurations, extendedFrontendIpConfigurations)
    frontendPorts: frontendPorts
    backendAddressPools: unifiedBackendAddressPools
    backendHttpSettingsCollection: unifiedBackendHttpSettingsCollection
    httpListeners: unifiedHttpListeners
    urlPathMaps: urlPathMaps
    requestRoutingRules: unifiedRequestRoutingRules
    enableHttp2: true
    firewallPolicy: {
      id: applicationGatewayWafPolicies.id
    }
    privateLinkConfigurations: privateLinkConfigurations
    sslProfiles: unifiedSslProfiles
    sslPolicy: sslPolicy
    sslCertificates: sslCertificates
    probes: unifiedProbes
    rewriteRuleSets: unifiedRewriteRuleSets
    redirectConfigurations: redirectConfigurations
    trustedRootCertificates: trustedRootCertificates
    trustedClientCertificates: trustedClientCertificates
  }
  zones: availabilityZones
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
