# namespaces

Target Scope: resourceGroup

## Synopsis
Creating a Service Bus Namespace

## Description
Creating a Service Bus Namespace resource with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| serviceBusNamespaceName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the servicebus namespace. This will be the target servicebus where systemevents will be delivered. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| skuName | string | <input type="checkbox"> | `'Basic'` or  `'Premium'` or  `'Standard'` | <pre>'Standard'</pre> | Specifies the sku of the servicebus namespace. |
| skuCapacity | int | <input type="checkbox"> | None | <pre>1</pre> | Messaging units for your service bus premium namespace. Valid capacities are {1, 2, 4, 8, 16} multiples of your properties.premiumMessagingPartitions setting. For example, If properties.premiumMessagingPartitions is 1 then possible capacity values are 1, 2, 4, 8, and 16. If properties.premiumMessagingPartitions is 4 then possible capacity values are 4, 8, 16, 32 and 64. |
| serviceBusMinimumTlsVersion | string | <input type="checkbox"> | `'1.0'` or  `'1.1'` or  `'1.2'` | <pre>'1.2'</pre> | Set the minimum TLS version to be permitted on requests to this servicebus. |
| publicNetworkAccess | bool | <input type="checkbox"> | None | <pre>false</pre> | The default network action for this Azure Service Bus. |
| disableLocalAuth | bool | <input type="checkbox"> | None | <pre>true</pre> | This property disables SAS authentication for the Service Bus namespace. |
| zoneRedundant | bool | <input type="checkbox"> | None | <pre>false</pre> | Enabling this property creates a Premium Service Bus Namespace in regions supported availability zones. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| serviceBusNamespaceId | string |  |
| serviceBusNamespaceName | string |  |
## Examples
<pre>
module serviceBusNamespace 'br:contosoregistry.azurecr.io/servicebus/namespaces:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'sbnamespace')
  scope: resourceGroup
  params: {
    serviceBusNamespaceName: serviceBusNamespaceName
    disableLocalAuth: false
    publicNetworkAccess: true
    location: location
    serviceBusMinimumTlsVersion: '1.2'
    skuName: 'Standard'
    skuCapacity: 1
  }
}
</pre>
<p>Creates a servicebus namespace with the name 'ServiceBusNamespace'</p>

## Links
- [Bicep Microsoft.ServiceBus Namespaces](https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces?pivots=deployment-language-bicep)


