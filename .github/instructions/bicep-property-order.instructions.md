---
description: 'Bicep Property and Decorator Order'
applyTo: '**/*.bicep'
---

Reference: https://github.com/Azure/azure-quickstart-templates/blob/master/1-CONTRIBUTION-GUIDE/best-practices.md#sort-order-of-properties

## Recommended Order for Top-Level Declarations (Bicep File Structure)

```bicep
// 1. Target Scope
targetScope = 'resourceGroup'

// 2. Metadata (Optional)
metadata description = 'Deploys standard web application infrastructure.'

// 3. Parameters
@description('The name of the environment.')
param environmentName string

// 4. Variables
var uniqueStorageName = 'st${uniqueString(resourceGroup().id)}'

// 5. User-Defined Functions (Optional)
func buildResourceName(name string) string => '${environmentName}-${name}'

// 6. Existing Resources (References)
resource existingVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: 'hub-vnet'
}

// 7. New Resources and Modules (Interchangeable)
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: 'plan-${environmentName}'
  location: resourceGroup().location
  sku: { name: 'F1' }
}

module webAppModule 'webApp.bicep' = {
  name: 'webAppDeployment'
  params: {
    planId: appServicePlan.id
  }
}

// 8. Outputs
output webAppUrl string = webAppModule.outputs.siteUrl
```

## Recommended Order for Resources and Modules

### Decorators (placed before the resource/module declaration)

- `@description()` - Always include descriptions for clarity
- `@batchSize()` - Only if batch deployment is needed

### Resource Declaration Order

```bicep
@description('Description goes here')
resource resourceName 'type@version' = {
  // Properties in this order:
  parent: parentResource        // Use parent property instead of / in name
  scope: managementGroup()      // For management group or subscription scope
  name: 'resourceName'          // Resource name (at storage, location level)
  location: 'eastus'            // Azure region
  extendedLocation: { }         // Only if using extended locations
  zones: ['1', '2', '3']        // Availability zones
  sku: { }                      // SKU configuration
  kind: 'TypeName'              // Kind property if applicable
  scale: { }                    // Scale settings
  plan: { }                     // Plan/pricing tier
  identity: { }                 // Managed identity configuration
  dependsOn: [ ]                // Explicit dependencies (prefer implicit)
  tags: { }                     // Tags for resource organization
  properties: { }               // Resource-specific properties

  // Nested resources go after the ordered properties.
  resource childResource 'childType' = {
    name: 'childName'
  }
}
```

### Module Declaration Order

```bicep
@description('Module description')
module moduleName 'path/to/module.bicep' = {
  // Properties in this order:
  scope: managementGroup()      // Scope declaration first
  name: 'deploymentName'        // REQUIRED - enables deployment tracking in Azure Portal
  params: { }                   // Module input parameters
}
```

## Key Rules

- Decorators must come immediately before the resource/module declaration
- For modules, always include the `name` property for deployment traceability and Azure Portal visibility
- Use `parent` property instead of `/` in name for child resources
- Follow the property order above for consistency and readability
- Inner `resource` declarations must appear after ordered top-level properties inside the parent resource body
- Resource/module type grouping is optional, and you can mix `resource` and `module` declarations

### Chronological Order (Recommended)

Order your resources and modules in the order they will actually deploy.
Even though Bicep determines dependencies automatically, arranging declarations chronologically helps readability.

Example sequence:

1. `resource` Log Analytics Workspace
2. `resource` Key Vault (depends on Workspace)
3. `module` Virtual Network
4. `module` Virtual Machine (depends on VNet and Key Vault)

## Automation Script

- PowerShell script for reordering existing Bicep files: `Tools/Reorder-BicepPropertyOrder.ps1`
- Dry run (no file changes): `./Tools/Reorder-BicepPropertyOrder.ps1 -Path .`
- Apply changes: `./Tools/Reorder-BicepPropertyOrder.ps1 -Path . -Apply`
- Inner `resource` declarations are treated as trailing segments and preserved after ordered parent properties
- Expected post-apply validation: dry run reports `Files that would be updated: 0` and `Declarations to reorder: 0`
