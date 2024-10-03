# webtests

Target Scope: resourceGroup

## Synopsis
Creating a webtest resource on an existing Application Insights Resource.

## Description
Creates a webtest resource

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The location for this Application Insights instance to be upserted in. |
| webtestResourceName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. Name of the webtest resource to upsert. |
| applicationInsightsName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Existing parent Application Insights resource |
| webtestName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. User defined name if this WebTest. |
| tags | object? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Resource tags. Note: a mandatory tag \'hidden-link\' based on the \'appInsightResourceId\' parameter will be automatically added to the tags defined here. |
| request | object | <input type="checkbox" checked> | None | <pre></pre> | Required. The collection of request properties.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;RequestUrl: 'https://&#36;{appService.properties.defaultHostName}'<br>&nbsp;&nbsp;&nbsp;HttpVerb: 'GET'<br>&nbsp;&nbsp;&nbsp;ParseDependentRequests: false<br>} |
| webtestDescription | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. User defined description for this WebTest. |
| syntheticMonitorId | string | <input type="checkbox"> | None | <pre>webtestResourceName</pre> | Optional. Unique ID of this WebTest. |
| kind | string | <input type="checkbox"> | `'multistep'` or `'ping'` or `'standard'` | <pre>'standard'</pre> | Optional. The kind of WebTest that this web test watches. |
| webtestLocations | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    Id: 'emea-nl-ams-azr' //West Europe<br>  }<br>  {<br>    Id: 'emea-ch-zrh-edge' //France South<br>  }<br>  {<br>    Id: 'emea-se-sto-edge' //UK West<br>  }<br>]</pre> | Optional. [Complete list](https://learn.microsoft.com/en-us/previous-versions/azure/azure-monitor/app/monitor-web-app-availability#location-population-tags) <br>of where to physically run the tests from to give global coverage for accessibility of your application. |
| enabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Optional. Is the test actively being monitored. |
| frequency | int | <input type="checkbox"> | None | <pre>300</pre> | Optional. Interval in seconds between test runs for this WebTest. |
| timeout | int | <input type="checkbox"> | None | <pre>30</pre> | Optional. Seconds until this WebTest will timeout and fail. |
| retryEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Optional. Allow for retries should this WebTest fail. |
| validationRules | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. The collection of validation rule properties.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;ExpectedHttpStatusCode: 200<br>&nbsp;&nbsp;&nbsp;SSLCheck: true<br>&nbsp;&nbsp;&nbsp;SSLCertRemainingLifetimeCheck: 7<br>} |
| configuration | object? | <input type="checkbox" checked> | None | <pre></pre> | Optional. An XML configuration specification for a WebTest defining an XML specification of a WebTest to run against an application. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| webtestResourceId | string | Outputs the resource id of the webtest resource. |
| webtestResourceName | string | Outputs the resourcename of the webtest resource. |

## Examples
<pre>
module webtest '.br:contosoregistry.azurecr.io/insights/webtests.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 56), 'webtest')
  params: {
    applicationInsightsName: appInsights.outputs.appInsightsName
    request: {
      RequestUrl: 'https://www.nu.nl'
      HttpVerb: 'GET'
      ParseDependentRequests: false
    }
    webtestName: 'cmdbhandlertest'
    webtestResourceName: 'webtest'
    validationRules: {
      ExpectedHttpStatusCode: 200
      SSLCheck: true
      SSLCertRemainingLifetimeCheck: 7
    }
  }
}
</pre>
<p>Creates a Application Insights WebTest resource with the name 'webtest'</p>

## Links
- [Bicep AppInsights WebTests](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/webtests?pivots=deployment-language-bicep)
