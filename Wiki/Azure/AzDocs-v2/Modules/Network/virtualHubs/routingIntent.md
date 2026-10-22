# routingIntent

Target Scope: resourceGroup

## Synopsis
Configuring Routing Intent for a Virtual Hub.

## Description
Configuring Routing Intent for a Virtual Hub with the given specs. This module requires an existing Virtual Hub and Azure Firewall.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| azureFirewallResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | Required. Hub firewall Resource ID. |
| routingIntentName | string | <input type="checkbox"> | None | <pre>'defaultRouteTable'</pre> | Optional. The name of the routing intent configuration. |
| virtualHubName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. Name of the Virtual Hub. |
| privateToFirewall | bool | <input type="checkbox"> | None | <pre>true</pre> | Optional. Configures Routing Intent to forward Private traffic to the firewall (RFC1918). |
| internetToFirewall | bool | <input type="checkbox"> | None | <pre>true</pre> | Optional. Configures Routing Intent to Forward Internet traffic to the firewall (0.0.0.0/0). |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| routingIntentName | string | The name of the Routing Intent configuration. |
| routingIntentResourceId | string | The resource ID of the Routing Intent configuration. |
| routingIntentResourceGroupName | string | The resource group the Routing Intent configuration was deployed into. |

## Examples
<pre>
module routingIntent 'br:contosoregistry.azurecr.io/network/routingIntent:latest' = {
  name: '${deployment().name}-routingintent'
  params: {
    virtualHubName: virtualHub.name
    azureFirewallResourceId: azureFirewall.id
    privateToFirewall: true
    internetToFirewall: true
  }
}
</pre>
<p>Creates a Routing Intent configuration that routes both private and internet traffic to the Azure Firewall.</p>

## Links
- [Bicep Microsoft.Network virtualHubs/routingIntent](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualhubs/routingintent?pivots=deployment-language-bicep)<br>
- [Virtual Hub Routing Intent](https://learn.microsoft.com/en-us/azure/virtual-wan/how-to-routing-policies)
