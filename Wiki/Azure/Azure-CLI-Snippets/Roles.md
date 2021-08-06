[[_TOC_]]

# Roles

In other resources (App Service, Function App, etc.) Managed Identities are created for you when you create the resource. The script [Grant-Permissions-to-ManagedIdentity-on-Resource](/Azure/Azure-CLI-Snippets/Roles/Grant-Permissions-to-ManagedIdentity-on-Resource) gives you an easy way to grant permissions to a resource with one of the earlier created Managed Identities.

You will have to provide the target (to whom you grant permissions) and the identity (for who you grant permissions). At the moment, the following resources can be picked:

- Webapp
- FunctionApp
- AppConfig
