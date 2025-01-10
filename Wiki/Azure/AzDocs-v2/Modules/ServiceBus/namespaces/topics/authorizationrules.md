# authorizationrules

Target Scope: resourceGroup

## Synopsis
Creating an authorization rule inside of a servicebus namespace topic

## Description
Creating an authorization rule inside of a servicebus namespace topic.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| authorizationRuleName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the authorization rule. This is used to identify the rule in the topic. |
| authorizationRuleRights | string[] | <input type="checkbox" checked> | `'Listen'` or `'Send'` or `'Manage'` | <pre></pre> | The rights that the authorization rule has. |
| serviceBusNamespaceName | string | <input type="checkbox" checked> | Length between 6-50 | <pre></pre> | <br>Character limit: 6-50<br><br>Valid characters: Alphanumerics and hyphens.<br> |
| topicName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | Character limit: 1-260<br><br>Valid characters:<br>Alphanumerics, periods, hyphens, underscores, and slashes.<br><br>Start and end with alphanumeric. |

## Examples
<pre>
module authorizationRule 'br:contosoregistry.azurecr.io/servicebus/namespaces/topics/authorizationrules:latest' = {
  name: '${take(deployment().name, 36)}-${take('topic-${topicName}', 20)}-authorizationrules'
  params: {
    authorizationRuleName: authorizationRuleName
    authorizationRuleRights: authorizationRuleRights
    serviceBusNamespaceName: serviceBusNamespaceName
    topicName: topicNames
  }
}

</pre>
<p>Creating an authorization rule inside of a servicebus namespace topic</p>

## Links
- [Bicep Microsoft.ServiceBus/Namespaces/Topics/AuthorizationRules](https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces/topics/authorizationrules?pivots=deployment-language-bicep)
