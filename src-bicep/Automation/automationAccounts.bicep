@description('Specifies the Azure location where the key vault should be created.')
param location string = resourceGroup().location

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
The name of the Automation Account to be upserted.
Min length: 6
Max length: 50
''')
@minLength(6)
@maxLength(50)
param automationAccountName string

@description('''
Sets the identity property for the automation account
Example:
{
  type: 'UserAssigned'
  userAssignedIdentities: userAssignedIdentities
}'
''')
param identity object = {
  type: 'SystemAssigned'
}

@description('''
Indicates whether requests using non-AAD authentication are blocked
''')
param disableLocalAuthentication bool = false

@description('''
Indicates whether traffic on the non-ARM endpoint (Webhook/Agent) is allowed from the public internet
''')
param publicNetworkAccess bool = false

@description('''
Set the encryption properties for the automation account
Example:
{
  identity: {
    userAssignedIdentity: any()
  }
  keySource: 'Microsoft.Keyvault'
  keyVaultProperties: {
    keyName: 'string'
    keyvaultUri: 'string'
    keyVersion: 'string'
  }
}
''')
param encryption object = {
  identity: {}
  keySource: 'Microsoft.Automation'
}

@description('''
Sets the SKU of the automation account
Example:
{
  capacity: null
  family: null
  name: 'Free'
}
''')
param sku object = {
  capacity: null
  family: null
  name: 'Basic'
}

@description('The Automation Account to be upserted.')
resource automationAccount 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: automationAccountName
  location: location
  tags: tags
  identity: identity
  properties: {
    disableLocalAuth: disableLocalAuthentication
    encryption: encryption
    publicNetworkAccess: publicNetworkAccess
    sku: sku
  }
}
