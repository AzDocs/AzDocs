/*
.SYNOPSIS
Creating an authorization rule inside of a servicebus namespace topic
.DESCRIPTION
Creating an authorization rule inside of a servicebus namespace topic.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.ServiceBus/Namespaces/Topics/AuthorizationRules](https://learn.microsoft.com/en-us/azure/templates/microsoft.servicebus/namespaces/topics/authorizationrules?pivots=deployment-language-bicep)
*/
@minLength(1)
@description('The name of the authorization rule. This is used to identify the rule in the topic.')
param authorizationRuleName string

@description('The rights that the authorization rule has.')
@allowed([
  'Listen'
  'Send'
  'Manage'
])
param authorizationRuleRights string[]

@minLength(6)
@maxLength(50)
@description('''The name of the servicebus namespace. This will be the target servicebus where systemevents will be delivered.

Character limit: 6-50

Valid characters: Alphanumerics and hyphens.

Start with a letter. End with a letter or number.''')
param serviceBusNamespaceName string

@minLength(1)
@maxLength(260)
@description('''
Character limit: 1-260

Valid characters:
Alphanumerics, periods, hyphens, underscores, and slashes.

Start and end with alphanumeric.
''')
param topicName string

resource servicebusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusNamespaceName
}

resource topic 'Microsoft.ServiceBus/namespaces/topics@2022-01-01-preview' existing = {
  name: topicName
  parent: servicebusNamespace
}

resource authorizationRule 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2024-01-01' = {
  parent: topic
  name: authorizationRuleName
  properties: {
    rights: authorizationRuleRights
  }
}
