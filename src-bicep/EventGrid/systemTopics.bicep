/*
.SYNOPSIS
Creating a Event Grid System Topic resource
.DESCRIPTION
Creating a Event Grid System Topic resource with the given specs.
.EXAMPLE
<pre>
module systemTopic 'br:contosoregistry.azurecr.io/eventgrid/systemTopics:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'topic')
  scope: resourceGroup
  params: {
    eventGridNamespaceName: eventGridNamespaceName
    location: 'global'
    eventSource: az.subscription().id
    eventTopicType: 'Microsoft.Resources.Subscriptions'
  }
}
</pre>
<p>Creating a Event Grid System Topic resource with the name eventGridNamespaceName</p>
.LINKS
- [Bicep Microsoft.EventGrid/systemTopics](https://learn.microsoft.com/en-us/azure/templates/microsoft.eventgrid/systemtopics?pivots=deployment-language-bicep)
*/

@description('The name of this Event Grid System Topic resource.')
@minLength(3)
@maxLength(50)
param eventGridNamespaceName string

@description('Specifies the Azure location where the resource should be created. Defaults \'global\'.')
param location string = 'global'

@description('Managed service identity to use for this Resource. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.eventgrid/systemtopics?pivots=deployment-language-bicep#identityinfo).')
param identity object = {
  type: 'SystemAssigned'
}

@description('The source (resource id) of the events. Defaults to the subscription resource id')
param eventSource string = az.subscription().id

@description('The topic type to subscribe to. Defaults to Microsoft.Resources.Subscriptions.')
param eventTopicType string = 'Microsoft.Resources.Subscriptions'

resource systemTopic 'Microsoft.EventGrid/systemTopics@2022-06-15' = {
  name: eventGridNamespaceName
  location: location
  identity: identity
  properties: {
    source: eventSource
    topicType: eventTopicType
  }
}

output identityPrincipalId string = systemTopic.identity.principalId
