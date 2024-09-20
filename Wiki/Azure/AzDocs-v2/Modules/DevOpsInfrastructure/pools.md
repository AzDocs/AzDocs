# pools

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="additionalAzureDevOpsOrganizationsType">additionalAzureDevOpsOrganizationsType</a>  | <pre>{</pre> |  |  | 

## Synopsis
Creating a Managed DevOps pool.

## Description
This module creates a managed devops pool with the given specs. If you want to use with a BYO NetworkProfile, the App 'DevOpsInfrastructure' needs to have Network rights on the subnet.<br>
The account that runs the creation of this pool needs to have DevOps Organisation Pool Administrator rights otherwise you will receive the error: Failed to provision agent pool.<br>
See also the [quickstart](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/quickstart-azure-portal?view=azure-devops) for prerequisites.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The location of the resource. Defaults to the resourcegroups location. |
| managedDevOpsPoolName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the managed devops pool to upsert. |
| devCenterProjectName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing Dev Center project. |
| virtualNetworkResourceGroupName | string | <input type="checkbox"> | None | <pre>resourceGroup().name</pre> | The name of the resource group of the existing virtual network that has the subnet to integrate the devops pool in. |
| virtualNetworkName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the existing virtual network that has the subnet to integrate the devops pool in. |
| subnetName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the existing subnet to integrate the devops pool in. This subnet needs to be delegated to Microsoft.DevOpsInfrastructure/pools. |
| userAssignedManagedIdentityName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the existing user assigned managed identity. |
| managedDevOpsPoolImages | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    aliases: [<br>      'ubuntu-22.04'<br>    ]<br>    buffer: '*'<br>    wellKnownImageName: 'ubuntu-22.04/latest'<br>  }<br>  {<br>    aliases: ['windows-2022', 'windows-latest']<br>    buffer: '*'<br>    wellKnownImageName: 'windows-2022/latest'<br>  }<br>]</pre> | The images to use for the pool. See for more info: [information](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/configure-images?view=azure-devops&tabs=azure-portal).<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;resourceId: '/Subscriptions/&#36;{az.subscription().subscriptionId}/Providers/Microsoft.Compute/Locations/&#36;{location}/Publishers/canonical/ArtifactTypes/VMImage/Offers/0001-com-ubuntu-server-focal/Skus/20_04-lts-gen2/versions/latest'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;aliases: []<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;buffer: '*'<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;resourceId: '/subscriptions/&#36;{remoteSubscriptionId}/resourceGroups/&#36;{remoteResourceGroupName}/providers/Microsoft.Compute/galleries/&#36;{galleryName}/images/ubuntu22/versions/latest'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;aliases: []<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;buffer: '*'<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;aliases: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'ubuntu-22.04'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;buffer: '*'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;wellKnownImageName: 'ubuntu-22.04/latest'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| azureDevOpsPoolsPermissionsProfile | string | <input type="checkbox"> | `'Inherit'` or `'CreatorOnly'` or `'SpecificAccoumnts'` | <pre>'Inherit'</pre> | The permissions profile for the AzureDevOps pool in the project. |
| poolInteractiveMode | string | <input type="checkbox"> | `'Service'` or `'Interactive'` | <pre>'Service'</pre> | The interactive mode of the pool. Service mode means the pool runs as a service account. Interactive mode means the pool runs as an interactive account. |
| keyvaultConfiguration | object | <input type="checkbox"> | None | <pre>{<br>  keyExportable: false<br>  observedCertificates: []<br>}</pre> | Future keyvault configuration for the pool. Currently it is not used. |
| agentSkuName | string | <input type="checkbox"> | None | <pre>'Standard_D2ads_v5'</pre> | The sku name for the Azure VM used in the pool. See for more info: [information](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/prerequisites?view=azure-devops&tabs=azure-portal#review-managed-devops-pools-quotas) |
| osDiskStorageAccountType | string | <input type="checkbox"> | `'Premium'` or `'Standard'` or `'StandardSSD'` | <pre>'Standard'</pre> | The storage account name for the OS disk of the pool. |
| dataDisks | array | <input type="checkbox"> | None | <pre>[]</pre> | A list of empty data disks to attach. Avoid drive letters A, C, D or E.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"diskSizeGiB": 1,<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"storageAccountType": "Premium_LRS",<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"driveLetter": "F"<br>&nbsp;&nbsp;&nbsp;}<br>] |
| agentScalingProfile | object | <input type="checkbox"> | None | <pre>{<br>  kind: 'Stateless' //Fresh Agent every time<br>  resourcePredictionsProfile: {<br>    predictionPreference: 'MostCostEffective' //The balance between cost and performance for standby agents.<br>    kind: 'Automatic' //Standby agent mode<br>  }<br>}</pre> | The kind of the agent scaling profile.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;maxAgentLifetime: '7.00:00:00'<br>&nbsp;&nbsp;&nbsp;gracePeriodTimeSpan: '00:30:00'<br>&nbsp;&nbsp;&nbsp;kind: 'Stateful'<br>&nbsp;&nbsp;&nbsp;resourcePredictionsProfile: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;kind: 'Automatic'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;predictionPreference: 'MostCostEffective'<br>&nbsp;&nbsp;&nbsp;}<br>} |
| azureDevOpsOrganizationName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the initial existing Azure DevOps to configure the pools in. |
| azureDevOpsProjects | array | <input type="checkbox"> | None | <pre>[]</pre> | The AzureDevOps projects to add the pool to. Empty array means all projects. |
| maximumConcurrencyPoolSize | int | <input type="checkbox"> | Value between 1-10000 | <pre>2</pre> | Defines how many VM resources can be created at any given time. |
| organizationProfileOrganizationsParallelism | int | <input type="checkbox"> | None | <pre>1</pre> | How many pools can run in parallel when using multiple AzureDevOps organizations. <br>Also the sum of parallelism for all organizations must equal the max pool size (maximumConcurrencyPoolSize). |
| additionalAzureDevOpsOrganizations | [additionalAzureDevOpsOrganizationsType](#additionalAzureDevOpsOrganizationsType) | <input type="checkbox"> | None | <pre>[]</pre> | The additional AzureDevOps organizations to add the pool to.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;url: 'https://dev.azure.com/azureDevOpsOrganizationName'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;projects: []<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;parallelism: 1 //dependent on the total number of organizations<br>&nbsp;&nbsp;&nbsp;}<br>] |

## Examples
<pre>
module devopspools 'br:contosoregistry.azurecr.io/devopsinfrastructure/pools:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 52), 'mandevpools')
  params: {
    managedDevOpsPoolName: mydevopspool
    devCenterProjectName: mydevcenterproject
    azureDevOpsOrganizationName: myazuredevops
  }
}
</pre>
<p>Creates a devops pool with the given specs</p>

## Links
- [ARM Microsoft.DevOpsInfrastructure](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/quickstart-arm-template?view=azure-devops)
