[[_TOC_]]

# Description

This snippet will make it possible for you to update the tags of multiple resources/resourcegroups. When running this snippet you will have three operations you can perform:

- Merge -> adds a new / updates an existing tag.
- Replace -> replaces all tags with the new tags you've provided.
- Delete -> removes the tags you've provided.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

## General parameters

| Parameter    | Required                        | Example Value                   | Description                                                                                                          |
| ------------ | ------------------------------- | ------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Operation    | <input type="checkbox" checked> | `merge`                         | The operation that has to be performed on the tags. You can choose from the following: `merge`, `replace`, `delete`. |
| ResourceTags | <input type="checkbox" checked> | `@('tag=value';'tag2=value2';)` | The resourcetags to merge, replace or delete.                                                                        |

## Single resource parameters

| Parameter            | Required                        | Example Value        | Description                                                                                    |
| -------------------- | ------------------------------- | -------------------- | ---------------------------------------------------------------------------------------------- |
| ResourceGroupName    | <input type="checkbox" checked> | `resourcegroup-name` | The name of the resourcegroup.                                                                 |
| ResourceName         | <input type="checkbox" checked> | `resource-name`      | The name of the resource.                                                                      |
| IncludeResourceGroup | <input type="checkbox">         | `n.a.`               | Pass this switch when you want to include the tags of the resourcegroup to be updated as well. |

## Multiple resourcegroups parameters

| Parameter                       | Required                        | Example Value                                      | Description                                                                                                |
| ------------------------------- | ------------------------------- | -------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| ResourceGroupNames              | <input type="checkbox" checked> | `@('resourcegroupname-1'; 'resourcegroupname-2';)` | The names of the resourcegroups you would like to updated.                                                 |
| IncludeResourcesInResourceGroup | <input type="checkbox">         | `n.a.`                                             | Pass this switch when you want to include the resources inside of the resourcegroup to be updated as well. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Set Tags for Resources"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Generic/Set-Tags-For-Resources.ps1"
    arguments: "-Operation '$(Operation)' -ResourceTags $(ResourceTags) -ResourceGroupName '$(ResourceGroupName)' -ResourceName '$(ResourceName)' -IncludeResourceGroup -ResourceGroupNames $(ResourceGroupNames) -IncludeResourcesInResourceGroup
```

# Code

[Click here to download this script](../../../../src/Generic/Set-Tags-For-Resources.ps1)

# Links

[Azure CLI - az resource list](https://docs.microsoft.com/en-us/cli/azure/resource?view=azure-cli-latest#az_resource_list)

[Azure CLI - az tag update](https://docs.microsoft.com/en-us/cli/azure/tag?view=azure-cli-latest#az_tag_update)
