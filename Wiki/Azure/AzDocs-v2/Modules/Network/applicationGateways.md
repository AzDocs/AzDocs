﻿# applicationGateways

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="ApplicationGatewaySku">ApplicationGatewaySku</a>  | <pre>{</pre> |  |  | 

## Synopsis
Creating an application gateway 

## Description
Creating an application gateway

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>az.resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| applicationGatewayVirtualNetworkName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The name of the VNet where you want to onboard this Application Gateway into. |
| virtualNetworkResourceGroupName | string | <input type="checkbox"> | None | <pre>az.resourceGroup().name</pre> | The name resourcegroup where the virtual network resource is allocated. |
| applicationGatewaySubnetName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | Name of the subnet where the Application Gateway should reside in. |
| applicationGatewayName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The name of the Application Gateway. |
| redirectStaticWebAppName | string | <input type="checkbox"> | Length between 1-40 | <pre>'stapp-&#36;{take(applicationGatewayName, 34)}'</pre> | The name of the static webapp, by default the first 36 characters of the applicationGatewayName |
| minCapacity | int | <input type="checkbox"> | Value between 0-125 | <pre>2</pre> | The minimum instance count for Application Gateway. The Application Gateway will scale out with a minimum of this minCapacity. For highly available Application Gateways, please use 2 or higher. |
| maxCapacity | int | <input type="checkbox"> | Value between 1-125 | <pre>10</pre> | The maximum instance count for Application Gateway. The Application Gateway will scale out to this number tops. |
| sslProfiles | array | <input type="checkbox"> | None | <pre>[]</pre> | SSL profiles of the application gateway resource. <br>For object structure, refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaysslprofile).<br>By default this module will add a `Legacy` SSL profile which is using TLS 1.2 with these ciphersuites:<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'TLS_RSA_WITH_AES_256_GCM_SHA384'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'TLS_RSA_WITH_AES_128_GCM_SHA256'<br>You can append this profile with your own defined profiles. |
| trustedClientCertificates | array | <input type="checkbox"> | None | <pre>[]</pre> | Trusted client certificates of the application gateway resource. |
| sslCertificates | array | <input type="checkbox"> | None | <pre>[]</pre> | SSL Certificates. For object structure, refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaysslcertificate). |
| trustedRootCertificates | array | <input type="checkbox"> | None | <pre>[]</pre> | Trusted Root Certificates for this App GW. For object structure, refer to the [Bicep resource definition](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?pivots=deployment-language-bicep#applicationgatewaytrustedrootcertificate) |
| cookieBasedAffinity | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Disabled'</pre> | Cookie based affinity. |
| applicationGatewayPublicIpName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The resourcename of the public ip which will be used for the frontend ip of this application gateway. This should be pre-existing. |
| applicationGatewayWebApplicationFirewallPolicyName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The resourcename of the Web Application Firewall policy name which will be used for this Application Gateway. This should be pre-existing. |
| applicationGatewaySku | [ApplicationGatewaySku](#ApplicationGatewaySku) | <input type="checkbox"> | None | <pre>{<br>  name: 'WAF_v2'<br>  tier: 'WAF_v2'<br>  family: 'Generation_2'<br>}</pre> | SKU of the application gateway resource. For object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaysku). |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings). |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings). |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| enablePrivateFrontendIp | bool | <input type="checkbox"> | None | <pre>false</pre> | Enable a private IP on the frontend of this application gateway. This is used if you want to expose your application gateway on your internal VNet. If this is enabled, you have to fill the `privateFrontendStaticIp` parameter too. Defaults to `false`. |
| privateFrontendStaticIp | string | <input type="checkbox"> | Length between 0-15 | <pre>''</pre> | The IP to use as private frontend IP for your application gateway. This should be an IP inside the subnet refered to with the `applicationGatewaySubnetName` parameter. If you want to use this, make sure to enable the `enablePrivateFrontendIp` parameter. |
| frontendPorts | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    name: 'Port_80'<br>    properties: {<br>      port: 80<br>    }<br>  }<br>  {<br>    name: 'Port_443'<br>    properties: {<br>      port: 443<br>    }<br>  }<br>]</pre> | Ports configuration for this application gateway. For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayfrontendport). |
| sslPolicy | object | <input type="checkbox"> | None | <pre>{<br>  policyType: 'Predefined'<br>  policyName: 'AppGwSslPolicy20220101S'<br>}</pre> | The default SSL policy to use for entrypoints. This policy is used whenever no specific SSL Profile is being selected.<br>For object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaysslpolicy). |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | The identity to run this application gateway under. This defaults to a System Assigned Managed Identity. For object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#managedserviceidentity). |
| probes | array | <input type="checkbox"> | None | <pre>[]</pre> | HTTP probes for automatically testing backend connections. For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayprobe). |
| rewriteRuleSets | array | <input type="checkbox"> | None | <pre>[]</pre> | The rewrite rule sets for this AppGw. For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayrewriteruleset). |
| redirectConfigurations | array | <input type="checkbox"> | None | <pre>[]</pre> | Redirect configurations (for example for HTTP -> HTTPS redirects). For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayredirectconfiguration). |
| backendAddressPools | array | <input type="checkbox"> | None | <pre>[]</pre> | User defined backend pools. For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaybackendaddresspool). |
| urlPathMaps | array | <input type="checkbox"> | None | <pre>[]</pre> | User defined Url Path Maps for path-based routing. For array/object structure, please refer to the [Bicep resource definition](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?pivots=deployment-language-bicep#applicationgatewayurlpathmap). |
| requestRoutingRules | array | <input type="checkbox"> | None | <pre>[]</pre> | User defined request routing rules. For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayrequestroutingrule). |
| httpListeners | array | <input type="checkbox"> | None | <pre>[]</pre> | User defined HTTP listeners. For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayhttplistener). |
| backendHttpSettingsCollection | array | <input type="checkbox"> | None | <pre>[]</pre> | User defined Backend HTTP Settings. For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewaybackendhttpsettings). |
| gatewayIPConfigurations | array | <input type="checkbox"> | None | <pre>[]</pre> | User defined subnets to onboard this application gateway into. The first (Default) inclusion will be made with the settings you provide in the `applicationGatewayVirtualNetworkName` & `applicationGatewaySubnetName` parameters. You can add additional configs here. For array/object structure, please refer to the [Bicep resource definition](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayipconfiguration). |
| ezApplicationGatewayEntrypoints | array | <input type="checkbox"> | None | <pre>[]</pre> | &nbsp;&nbsp;&nbsp;This is the easy way of creating Application Gateway Entrypoints. You are still able to create them yourselves without the "EZ" parameter, but if you need straightforward reverse proxies, this is a lot easier.<br>&nbsp;&nbsp;&nbsp;A list of Public Application Gateway Entrypoints to create. Each object in the list should have the following 3 parameters:<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;entrypointHostName: The hostname to use on the frontend. For example: 'my.website.contoso.com'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;backendAddressFqdn: The FQDN or IPAddress to use as the backend pool member. For example: 'www.google.nl' or 'myapp.azurewebsites.net'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;certificateName: The name of the certificate to use. For example: 'my.pfx'. This certificate should already be present in the AppGw.<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(optional)backendSettingsOverrideHostName: Hostname used that is used for the backend resouces<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(optional)backendSettingsOverrideTrustedRootCertificates: if true. all the given trusted root CA's are added.<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(optional)backendSettingsOverrideProbePath: If set, the given probe path is used instead of the default one.<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(optional)backendSettingsOverrideRequestTimeout: If set, the given request timeout is used instead of the default one (30 seconds).<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(optional)rewriteRulesetName: if set, it would bind the rewrite set name that is given.<br><br><details><br>&nbsp;&nbsp;&nbsp;<summary>Click to show examples</summary><br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"entrypointHostName": "test1.com",<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"backendAddressFqdn": "www.google.nl",<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"certificateName": "certificate1.pfx"<br>&nbsp;&nbsp;&nbsp;},<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"entrypointHostName": "test2.com",<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"backendAddressFqdn": "",<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"certificateName": "test2.pfx",<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"backendSettingsOverrideHostName": "test2.org",<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"backendSettingsOverrideTrustedRootCertificates": true,<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"backendSettingsOverrideProbePath": "/healthprobe",<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"backendSettingsOverrideRequestTimeout": 30,<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"rewriteRulesetName" : "fallback-rewriteset",<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"sslProfileName": "testprofile"<br>&nbsp;&nbsp;&nbsp;}<br></details> |
| ezApplicationGatewayEntrypointsBackendAddressPoolName | string | <input type="checkbox"> | None | <pre>'<entrypointHostName>-backendaddresspool'</pre> | Optional override for the BackendAddressPool names for the EZ Entrypoints feature.<br>You can use the following placeholders which will be replaced by their respective values:<br>&nbsp;&nbsp;&nbsp;- <entrypointHostName> will be replaced by the `entrypointHostName` parameter in each `ezApplicationGatewayEntrypoints` entry. It will also automatically replace -'s with -- and .'s with -'s to comply with naming requirements.<br>Defaults to: <entrypointHostName>-backendaddresspool |
| ezApplicationGatewayEntrypointsBackendHttpSettingsName | string | <input type="checkbox"> | None | <pre>'<entrypointHostName>-backendaddresssettings'</pre> | Optional override for the BackendHttpSettingsCollection names for the EZ Entrypoints feature.<br>You can use the following placeholders which will be replaced by their respective values:<br>&nbsp;&nbsp;&nbsp;- <entrypointHostName> will be replaced by the `entrypointHostName` parameter in each `ezApplicationGatewayEntrypoints` entry. It will also automatically replace -'s with -- and .'s with -'s to comply with naming requirements.<br>Defaults to: <entrypointHostName>-backendaddresssettings |
| ezApplicationGatewayEntrypointsAfinityCookieNameName | string | <input type="checkbox"> | None | <pre>'<entrypointHostName>-httpscookie'</pre> | Optional override for the BackendHttpSettingsCollection names for the EZ Entrypoints feature.<br>You can use the following placeholders which will be replaced by their respective values:<br>&nbsp;&nbsp;&nbsp;- <entrypointHostName> will be replaced by the `entrypointHostName` parameter in each `ezApplicationGatewayEntrypoints` entry. It will also automatically replace -'s with -- and .'s with -'s to comply with naming requirements.<br>Defaults to: <entrypointHostName>-backendaddresssettings |
| ezApplicationGatewayEntrypointsHttpsListenerName | string | <input type="checkbox"> | None | <pre>'<entrypointHostName>-httpslistener'</pre> | Optional override for the BackendHttpSettingsCollection names for the EZ Entrypoints feature.<br>You can use the following placeholders which will be replaced by their respective values:<br>&nbsp;&nbsp;&nbsp;- <entrypointHostName> will be replaced by the `entrypointHostName` parameter in each `ezApplicationGatewayEntrypoints` entry. It will also automatically replace -'s with -- and .'s with -'s to comply with naming requirements.<br>Defaults to: <entrypointHostName>-httpslistener |
| ezApplicationGatewayEntrypointsRequestRoutingRuleName | string | <input type="checkbox"> | None | <pre>'<entrypointHostName>-requestroutingrule'</pre> | Optional override for the BackendHttpSettingsCollection names for the EZ Entrypoints feature.<br>You can use the following placeholders which will be replaced by their respective values:<br>&nbsp;&nbsp;&nbsp;- <entrypointHostName> will be replaced by the `entrypointHostName` parameter in each `ezApplicationGatewayEntrypoints` entry. It will also automatically replace -'s with -- and .'s with -'s to comply with naming requirements.<br>Defaults to: <entrypointHostName>-requestroutingrule |
| ezApplicationGatewayEntrypointsProbeName | string | <input type="checkbox"> | None | <pre>'<entrypointHostName>-httpsprobe'</pre> | Optional override for the BackendHttpSettingsCollection names for the EZ Entrypoints feature.<br>You can use the following placeholders which will be replaced by their respective values:<br>&nbsp;&nbsp;&nbsp;- <entrypointHostName> will be replaced by the `entrypointHostName` parameter in each `ezApplicationGatewayEntrypoints` entry. It will also automatically replace -'s with -- and .'s with -'s to comply with naming requirements.<br>Defaults to: <entrypointHostName>-httpsprobe |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| defaultFrontendIpConfigurationName | string | <input type="checkbox"> | `'appGatewayFrontendIP'` or `'appGatewayPrivateFrontendIP'` | <pre>enablePrivateFrontendIp</pre> | The default frontend Ip Configuration that is used to attach the httplisteners to. |
| redirectHttpToHttps | bool | <input type="checkbox"> | None | <pre>false</pre> | If this is true the default port 80 rule will be adjusted so that it will redirect http to https requests.<br>If `FqdnToRedirect` is specified, that url will be used. Expected is that the website would redirect any requests to https.<br>If `FqdnToRedirect` is not specified, an Static Web App will be created that would redirect http to https traffic.<br><br>The default port 80 will be configured with a rewrite rule that would change the response from the `FqdnToRedirect` or the fqdn of the static web app address to the original requested host. |
| fqdnToRedirect | string | <input type="checkbox"> | None | <pre>''</pre> | Supply a fqdn to use for redirection. It is expected that the website would redirect all traffic to https with the same fqdn. See also `RedirectHttpToHttps`for more information |
| deployDefaults | bool | <input type="checkbox"> | None | <pre>true</pre> | If this is true the default port 80 rule, listener, backendsettings and backendpool will be added to the application gateway. |
| availabilityZones | array | <input type="checkbox"> | `'1'` or `'2'` or `'3'` | <pre>[]</pre> | The zones to use for this application gateway. |
| customErrorpagesUrl | string | <input type="checkbox"> | None | <pre>''</pre> | Optional parameter to set all custom errorpages on the application gateway to the html file at this url |
| customErrorpage403Url | string | <input type="checkbox"> | None | <pre>''</pre> | Optional parameter to set custom errorpage for error 403 on the application gateway to the html file at this url |
| customErrorpage502Url | string | <input type="checkbox"> | None | <pre>''</pre> | Optional parameter to set custom errorpage for error 502 on the application gateway to the html file at this url |
| privateLinkConfigurations | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional array of private link configurations. For object structure, please refer to the [Bicep resource definition](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep#applicationgatewayprivatelinkconfiguration). |
| extendedFrontendIpConfigurations | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional array for extended frontend IP configurations. For object structure, please refer to the [Bicep resource definition](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?pivots=deployment-language-bicep#applicationgatewayfrontendipconfiguration). |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| applicationGatewayId | string | Output the application gateway resource id. |
| applicationGatewayName | string | Output the application gateway name. |

## Examples
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

## Links
- [Bicep Microsoft.Network applicationGateways](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?pivots=deployment-language-bicep)
