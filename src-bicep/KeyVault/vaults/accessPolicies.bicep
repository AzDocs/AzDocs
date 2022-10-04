@description('''
The name of the KeyVault to upsert
Keyvault name restrictions:
- Keyvault names must be between 3 and 24 alphanumeric characters in length. The name must begin with a letter, end with a letter or digit, and not contain consecutive hyphens
- Your keyVaultName must be unique within Azure.
''')
@minLength(3)
@maxLength(24)
param keyVaultName string

@description('The AAD Object ID of the pricipal you want to assign the role to.')
@minLength(36)
@maxLength(36)
param principalId string

@description('Assigned permissions for Principal ID. Please refer to this documentation for the object structure: https://docs.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults/accesspolicies?tabs=bicep#permissions')
param keyVaultPermissions object

@description('The action we choose for keyvault accessPolicies.')
@allowed([
  'add'
  'remove'
  'replace'
])
param policyAction string = 'add'

@description('Upsert the accessPolicies to the keyvault')
resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  name: keyVaultName
  resource keyVaultPolicies 'accessPolicies' = {
    name: policyAction
    properties: {
      accessPolicies: [
        {
          objectId: principalId
          permissions: keyVaultPermissions
          tenantId: subscription().tenantId
        }
      ]
    }
  }
}
