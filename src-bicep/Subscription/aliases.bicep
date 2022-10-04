targetScope = 'managementGroup'
@description('The subscription name. Preferably without spaces.')
@minLength(1)
@maxLength(64)
param subscriptionName string

@description('Provide the full resource ID of billing scope to use for subscription creation.')
param billingScopeResourceId string

@description('The workload type of this subscription.')
@allowed([
  'Production'
  'DevTest'
])
param subscriptionWorkloadType string

@description('Azure AD Object ID of the principal that should be made owner of this created subscription.')
@maxLength(36)
param subscriptionOwnerId string = ''

@description('Upsert the subscription with the given context')
resource subscription 'Microsoft.Subscription/aliases@2021-10-01' = {
  scope: tenant() // Derived from the pipeline context
  name: subscriptionName
  properties: {
    workload: subscriptionWorkloadType
    displayName: subscriptionName
    billingScope: billingScopeResourceId
    additionalProperties: {
      managementGroupId: managementGroup().id // This is fetched from the pipeline where you define the management group context
      subscriptionOwnerId: subscriptionOwnerId
      subscriptionTenantId: tenant().tenantId // Derived from the pipeline context
    }
  }
}

@description('Output the subscription id to be used in the further part of the pipeline')
output subscriptionId string = subscription.properties.subscriptionId
