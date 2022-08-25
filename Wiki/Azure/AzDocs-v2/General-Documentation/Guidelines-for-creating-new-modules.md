[[_TOC_]]

# Guidelines for creating new modules

If you want to create new modules, make sure they follow the [Code conventions checklist](#code-conventions-checklist) & [Naming convention](#naming). A general advise is to take a look at other scripts and copy those and go from there.

Modules documentation is created based on the metadata you provide in modules.

It uses the [decorators](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/parameters#decorators) on the param and output sections. At the time of writing there is no proper solution for module documentation([See also this github issue](https://github.com/Azure/bicep/issues/7298)). We choose to use the same syntax as [powershell based help comments](  
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help). With the difference that powershell comment block uses `<# #>` tags and bicep uses the `/* */` tags.

## Coding Convention

Every Bicep module is built with the following 4 components (ordered as they should be ordered in your scripts):

- param
- var
- resource & (optional) module
- output

Each param should have a "high security standard" and/or "high quality of life" default value.
TODO: explain what this means.

### Naming convention

- params, vars, resources, modules & outputs are always written in camelCasing.

- Our script & function parameters are written PascalCase
- Names should be logical, recognizable and should avoid confusion (see below).

We also make sure that there can be no confusion between parameters and the working of these parameters. This means that your parameters should explicitly be named for what it is. For example; in the `blobServices.bicep` module there are multiple parameters which are "names". To make sure we know exactly which value to put in which parameter, we've named all parameters as following: `blobContainerName` & `storageAccountName` etc. We couldve named `blobContainerName` simply: `name` but this might've been confusing. So always be overly explicit with your parameter names.

### Code conventions checklist

Whenever submitting new modules or changing existing modules, please make sure it is checked against the checklist below.

- <input type="checkbox"> Update the CHANGELOG with the changes you make. Especially breaking changes.
- <input type="checkbox"> Using the VSCode Bicep module to format & verify the module.
- <input type="checkbox"> Single purpose modules. So no creating storage account & blob container in one. Do include things like networking & security like vnet whitelisting or private endpoints into the creation of resources.
- <input type="checkbox"> Be explicit with your module parameter names. As described in the previous paragraph. So `storageAccountName` instead of `name` to avoid confusion.
- <input type="checkbox"> Modules which are modified should not break previous versions unless it's absolutely not possible to create backwards compatibility.
- <input type="checkbox"> Parameters are automatically set to required if there is no default value applied. _TODO metadata override required_
- <input type="checkbox"> Make sure to use validation [decorators](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/parameters#decorators) on parameters when needed & possible. For example: `@minLength`, `@maxLength` and `@allowed()`.
- <input type="checkbox"> ​Naming conventions should be implementable from the projectlayer. So no hardcoded names in the modules. For a configurable (sub)resourcename example; please look at the `ezApplicationGatewayEntrypointsBackendAddressPoolName` parameter in the `applicationGateways.bicep` module.
- <input type="checkbox"> For every resource that can make use of System Assigned Managed Identities, these should be created and used by default. Also support for User Assigned Managed Identities should be present. For an example; please look at the `identity` param in the `applicationGateways.bicep` module.
- <input type="checkbox"> For every resource that can make use of Diagnostic Settings, these should be enabled by default & you should be able to pass a Log Analytics Workspace Resource ID to the module so that it will configure to log to that LAW.
- <input type="checkbox"> For every resource that has support for Tags, this should be configurable and added to the module.
- <input type="checkbox"> For every resource that has support for VNet whitelisting, this should be configurable and added to the module.
- <input type="checkbox"> For every resource that has support for Private Endpoints, this should be configurable and added to the module.
- <input type="checkbox"> For every resource that can be created with a public endpoint, a switch statement should be added with the name `forcePublic` to allow this. If none of the private endpoint/vnet whitelisting parameters are provided the traffic from public should be blocked by default (with `forcePublic` = `false`).
- <input type="checkbox"> For every resource that has the possibility to set TLS, the TLS version should be default on a secure TLS version (at the time of writing TLS 1.2 or higher).
- <input type="checkbox"> For every resource that can be created without TLS enforced, a switch statement should be added with the name `forceDisableTLS` to allow this. This so that this cannot happen unintentionally.
- <input type="checkbox"> Metadata should be added accordingly which is used to generate a wiki page for the bicep module. This metadata has to have the following information:
  - <input type="checkbox"> Description - Short description of the module and what it does.
  - <input type="checkbox"> Example - A bicep module call task that can be copied/pasted into your main bicep file.
  - <input type="checkbox"> Links - Links that can be used to get more information about the different resources.
- <input type="checkbox"> Make sure to also update the templates with newly created / updated yaml tasks.
- <input type="checkbox"> The script should've been tested (including for every subresource that it could be used for).
- <input type="checkbox"> When a script will be deprecated add a warning to the wiki page that the script will be deprecated.
- <input type="checkbox"> When a script will be deprecated add it to the CHANGELOG.
