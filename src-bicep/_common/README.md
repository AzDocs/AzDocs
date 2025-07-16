# Common Bicep Types

This folder contains shared user-defined types that can be imported and used across multiple Bicep modules in this repository. These types promote consistency, reusability, and type safety across all Azure resource modules.

## Available Type Libraries

### `authorizationTypes.bicep`

Contains common types for Azure authorization resources:

- **`roleAssignment`**: Configuration for a role assignment

**Usage Example:**

```bicep
import { roleAssignment } from '../_common/authorizationTypes.bicep'

param roleAssignments roleAssignment[] = [
  {
    roleDefinitionIdOrName: 'Storage Blob Data Contributor'
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
]
```

### `diagnosticTypes.bicep`

Contains common types for Azure Monitor diagnostic settings:

- **`diagnosticLogCategory`**: Configuration for diagnostic log categories
- **`diagnosticMetricCategory`**: Configuration for diagnostic metric categories

**Usage Example:**

```bicep
import { diagnosticLogCategory, diagnosticMetricCategory } from '../_common/diagnosticTypes.bicep'

param diagnosticSettingsLogsCategories diagnosticLogCategory[] = [
  {
    categoryGroup: 'allLogs'
    enabled: true
    retentionPolicy: {
      days: 7
      enabled: true
    }
  }
]
```

### `networkTypes.bicep`

Contains common types for network access controls:

- **`virtualNetworkRule`**: Configuration for virtual network access rules
- **`ipRule`**: Configuration for IP-based access rules

**Usage Example:**

```bicep
import { virtualNetworkRule, ipRule } from '../_common/networkTypes.bicep'

param virtualNetworkRules virtualNetworkRule[] = [
  {
    id: '/subscriptions/.../subnets/mysubnet'
    ignoreMissingVnetServiceEndpoint: false
  }
]

param ipRules ipRule[] = [
  {
    value: '10.0.0.0/24'
  }
]
```

## Benefits

1. **Type Safety**: Compile-time validation of complex parameter structures
2. **Consistency**: Ensures all modules use the same type definitions for common parameters
3. **Maintainability**: Single source of truth for type definitions
4. **Documentation**: Self-documenting code with comprehensive property descriptions
5. **Reusability**: Types can be easily imported into any module that needs them

## Adding New Common Types

When adding new common types:

1. Create appropriately named `.bicep` files in this folder
2. Use the `@export()` decorator on all types that should be available for import
3. Add comprehensive documentation with `@description()` decorators
4. Update this README with usage examples
5. Ensure the types follow Azure Resource Manager template specifications

## Links

- [Bicep User-Defined Types](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/user-defined-data-types)
- [Azure Monitor Diagnostic Settings](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?pivots=deployment-language-bicep)
- [Azure Network Security](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups?pivots=deployment-language-bicep)
- [Azure Role Assignment](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
