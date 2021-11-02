[[_TOC_]]

# Description

This snippet will assign a role to the given Azure identity with the specified scope. Scope refers to the scope of the permissions: permissions can apply to a specific (nested) resource, but also to a Resource Group, or possibly an entire Azure subscription.

This snippet will only handle role assignments scoped to resources and nested resources. For broader assignment, you may want to call the [Add-ScopedRoleAssignment](../../../../src/AzDocs.Common/public/Add-ScopedRoleAssignment.ps1) function directly.

# Parameters

The snippet is capable of assigning roles to any type of identity. It's optimized for use with the Managed Identities we're using extensively, such as for a Web App, a Function App or an App Configuration, but other identities can be specified as well, using the correct command line switch.

## Switches

Using switches, the snippet supports different scenarios. You can either use it to assign permissions to a Managed Identity that is specified by means of specifying its resource details (e.g. name and group), or you can specify any other identity.

The switches below control which scenario is executed.

| Switch                     | Description                                                                                                                                                                                            |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| AppServiceManagedIdentity  | Used to specify that you'll be assigning a role to an App Service Managed Identity                                                                                                                     |
| FunctionAppManagedIdentity | Used to specify that you'll be assigning a role to a Function App Managed Identity                                                                                                                     |
| AppConfigManagedIdentity   | Used to specify that you'll be assigning a role to an App Configuration Managed Identity                                                                                                               |
| OtherManagedIdentity       | Used to specify that you'll be assigning a role to another identity. This can be a Managed Identity principal Id, but it can also be the Object ID of any identity of any other type, including Groups |

## Parameters (for use with switches -AppServiceManagedIdentity & -FunctionAppManagedIdentity)

| Parameter                         | Required                        | Example Value                                  | Description                                                                                                        |
| --------------------------------- | ------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| ManagedIdentityResourceName       | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)`    | The name of the resource for which the Managed Identity will need the permission                                   |
| ManagedIdentityResourceGroupName  | <input type="checkbox" checked> | `someresourcegroup-$(Release.EnvironmentName)` | The resource group containing the resource for which the Managed Identity will need the permission                 |
| ManagedIdentityAppServiceSlotName | <input type="checkbox">         | `stagingslot`                                  | Optional; the name of the Deployment Slot for for which the Managed Identity will need the permission              |
| ManagedIdentityApplyToAllSlots    | <input type="checkbox">         | `$false`                                       | The ability to enable managed identities for all the deployment slots that are attached to the webapp/functionapp. |

## Parameters (for use with switch -AppConfigManagedIdentity)

| Parameter                        | Required                        | Example Value                                  | Description                                                                                        |
| -------------------------------- | ------------------------------- | ---------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| ManagedIdentityResourceName      | <input type="checkbox" checked> | `myteam-testconfig-$(Release.EnvironmentName)` | The name of the resource for which the Managed Identity will need the permission                   |
| ManagedIdentityResourceGroupName | <input type="checkbox" checked> | `someresourcegroup-$(Release.EnvironmentName)` | The resource group containing the resource for which the Managed Identity will need the permission |

## Parameters (for use with switch -OtherIdentity)

| Parameter   | Required                        | Example Value                          | Description                                        |
| ----------- | ------------------------------- | -------------------------------------- | -------------------------------------------------- |
| PrincipalId | <input type="checkbox" checked> | `AEE652AD-850D-4F9D-BF2A-015C00B4FB23` | The identity (Object ID) that needs the permission |

## Other parameters

| Parameter                | Required                        | Example Value                                          | Description                                                                                                                                                                                                                               |
| ------------------------ | ------------------------------- | ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| TargetResourceName       | <input type="checkbox" checked> | `myservicebusqueue-$(Release.EnvironmentName)`         | The name of the resource to which the permission is applied                                                                                                                                                                               |
| TargetResourceGroupName  | <input type="checkbox" checked> | `someresourcegroup-$(Release.EnvironmentName)`         | The resource group containing the resource to which the permission is applied                                                                                                                                                             |
| TargetResourceType       | <input type="checkbox" checked> | `queues`                                               | The type of the resource to which the permission is applied                                                                                                                                                                               |
| TargetResourceNamespace  | <input type="checkbox" checked> | `Microsoft.ServiceBus`                                 | The namespace of the resource to which the permission is applied                                                                                                                                                                          |
| TargetResourceParentPath | <input type="checkbox">         | `namespaces\someservicebus-$(Release.EnvironmentName)` | Optional; the parent path of the resource to which the permission is applied.<br>NOTE: the path consists of both the type and the name of the parent resource. So for a Service Bus namespace, it would be `namespaces\theservicebusname` |
| RoleToAssign             | <input type="checkbox" checked> | `Azure Service Bus Data Sender`                        | The role name or role Id to assign                                                                                                                                                                                                        |

# Examples

### Assign with resource scope

To assign the `Azure Service Bus Data Sender` role to a Managed Identity against a Service Bus namespace:

`.\Grant-permissions-to-ManagedIdentity-on-Resource.ps1 -AppServiceManagedIdentity -ManagedIdentityResourceName theManagedIdResource -ManagedIdentityResourceGroupName theManagedIdResourceGroup -TargetResourceName theServiceBusNamespace -TargetResourceGroupName theServiceBusNamespaceResourceGroup -TargetResourceType namespaces -TargetResourceNamespace Microsoft.ServiceBus -RoleToAssign 'Azure Service Bus Data Sender'`

### Assign with nested resource scope

To assign the `Azure Service Bus Data Sender` role to a Managed Identity against a specific queue inside a Service Bus namespace:

`.\Grant-permissions-to-ManagedIdentity-on-Resource.ps1 -AppServiceManagedIdentity -ManagedIdentityResourceName theManagedIdResource -ManagedIdentityResourceGroupName theManagedIdResourceGroup -TargetResourceName theServiceBusQueue -TargetResourceGroupName theServiceBusNamespaceResourceGroup -TargetResourceType queues -TargetResourceParentPath namespaces\theServiceBusNamespace -TargetResourceNamespace Microsoft.ServiceBus -RoleToAssign 'Azure Service Bus Data Sender'`

### Assign to other identity type

To assign the `Azure Service Bus Data Sender` role to an identity (other than a Managed Identity for an app service, function app or app configuration) against a Service Bus namespace:

`.\Grant-permissions-to-ManagedIdentity-on-Resource.ps1 -OtherIdentity -PrincipalId someGuid -TargetResourceName theServiceBusNamespace -TargetResourceGroupName theServiceBusNamespaceResourceGroup -TargetResourceType namespaces -TargetResourceNamespace Microsoft.ServiceBus -RoleToAssign 'Azure Service Bus Data Sender'`

# YAML task

```yaml
- task: AzureCLI@2
  displayName: "Grant permissions to Resource"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Roles/Grant-Permissions-to-ManagedIdentity-on-Resource.ps1"
    arguments: "-AppServiceManagedIdentity -ManagedIdentityResourceName $(AppServiceName) -ManagedIdentityResourceGroupName $(ResourceGroupName) -TargetResourceName $(ServiceBusName) -TargetResourceGroupName $(ServiceBusResourceGroupName) -TargetResourceType $(ServiceBusResourceType) -TargetResourceNamespace $(ServiceBusResourceNamespace) -RoleToAssign $(RoleToAssign) -ManagedIdentityApplyToAllSlots $(ManagedIdentityApplyToAllSlots)"
```

# Code

[Click here to download this script](../../../../src/Roles/Grant-permissions-to-ManagedIdentity-on-Resource.ps1)

# Links

- [Azure CLI - az-webapp-identity-show](https://docs.microsoft.com/en-us/cli/azure/webapp/identity?view=azure-cli-latest#az-webapp-identity-show)

- [Azure CLI - az-functionapp-identity-show](https://docs.microsoft.com/en-us/cli/azure/functionapp/identity?view=azure-cli-latest#az_functionapp_identity_show)

- [Azure CLI - az-appconfig-identity-show](https://docs.microsoft.com/en-us/cli/azure/appconfig/identity?view=azure-cli-latest#az_appconfig_identity_show)

- [Azure CLI - az-resource-show](https://docs.microsoft.com/en-us/cli/azure/resource?view=azure-cli-latest#az_resource_show)

- [Azure CLI - az-role-assignment-create](https://docs.microsoft.com/en-us/cli/azure/role/assignment?view=azure-cli-latest#az-role-assignment-create)

- [Using the Microsoft.Azure.Services.AppAuthentication library for .NET](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity?tabs=dotnet#asal)
