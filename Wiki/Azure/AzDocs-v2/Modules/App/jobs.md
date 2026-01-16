# jobs

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="IdentityType">IdentityType</a>  | <pre></pre> | type |  | 
| <a id="container">container</a>  | <pre>{</pre> |  |  | 
| <a id="environmentVarType">environmentVarType</a>  | <pre>{</pre> |  |  | 
| <a id="containerResourcesType">containerResourcesType</a>  | <pre>{</pre> |  |  | 
| <a id="volumeMountType">volumeMountType</a>  | <pre>{</pre> |  |  | 
| <a id="containerProbeType">containerProbeType</a>  | <pre>{</pre> |  |  | 
| <a id="containerProbeHttpGetType">containerProbeHttpGetType</a>  | <pre>{</pre> |  |  | 
| <a id="containerProbeHttpGetHeaderType">containerProbeHttpGetHeaderType</a>  | <pre>{</pre> |  |  | 
| <a id="containerProbeTcpSocketType">containerProbeTcpSocketType</a>  | <pre>{</pre> |  |  | 

## Synopsis
Creating an Azure Container Apps Job

## Description
Creating a container app job with the specified configuration. Supports Manual, Schedule, and Event-driven trigger types with comprehensive identity, secret management, and monitoring capabilities.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| identity | IdentityType | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this container app job. Defaults to a system assigned managed identity. <br>For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity).<br>Example:<br>identity: {<br>&nbsp;&nbsp;&nbsp;type: 'None'<br>},<br>identity: {<br>&nbsp;&nbsp;&nbsp;type: 'UserAssigned'<br>&nbsp;&nbsp;&nbsp;userAssignedIdentities: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'/subscriptions/<subscriptionId>/resourcegroups/<resourcegroupname>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<userassignedmanagedidentityname>': {}<br>&nbsp;&nbsp;&nbsp;}<br>} |
| jobName | string | <input type="checkbox" checked> | Length between 2-32 | <pre></pre> | The name of the container app job. Must be unique per resource group. Alphanumeric characters and hyphens only. |
| managedEnvironmentName | string | <input type="checkbox" checked> | Length between 2-126 | <pre></pre> | Name of the managed environment the container app job should be in. Should be pre-existing. |
| triggerType | string | <input type="checkbox" checked> | `'Manual'` or `'Schedule'` or `'Event'` | <pre></pre> | Required. The trigger type of the job.<br>- Manual: Job can be triggered manually<br>- Schedule: Job runs on a schedule using cron expression<br>- Event: Job is triggered by external events |
| manualTriggerConfig | object? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Configuration for manual trigger type. Only used when triggerType is 'Manual'.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;parallelism: 4<br>&nbsp;&nbsp;&nbsp;replicaCompletionCount: 1<br>} |
| scheduleTriggerConfig | object? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Configuration for schedule trigger type. Required when triggerType is 'Schedule'.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;cronExpression: '0 0 * * *'<br>&nbsp;&nbsp;&nbsp;parallelism: 1<br>&nbsp;&nbsp;&nbsp;replicaCompletionCount: 1<br>} |
| eventTriggerConfig | object? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Configuration for event trigger type. Only used when triggerType is 'Event'.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;parallelism: 2<br>&nbsp;&nbsp;&nbsp;replicaCompletionCount: 1<br>&nbsp;&nbsp;&nbsp;scale: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;minExecutions: 0<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;maxExecutions: 10<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pollingInterval: 30<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;rules: []<br>&nbsp;&nbsp;&nbsp;}<br>} |
| replicaTimeout | int | <input type="checkbox" checked> | Value between 1-* | <pre></pre> | Required. Maximum number of seconds a replica is allowed to run. |
| replicaRetryLimit | int? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Maximum number of retries before failing the job. Defaults to no limit if not set. |
| identitySettings | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional. Settings for Managed Identities that are assigned to the Container App Job. If a Managed Identity is not specified here, default settings will be used.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;identity: '/subscriptions/<subscriptionId>/resourcegroups/<resourcegroupname>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<userassignedmanagedidentityname>'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;lifecycle: 'All'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| registries | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional. Collection of private container registry credentials for containers used by the Container App Job.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;server: 'myacr.azurecr.io'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;username: 'acruser'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;passwordSecretRef: 'acrpassword'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;identity: 'system'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| secrets | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. Collection of secrets used by a Container App Job. Use with @secure() decorator in modules.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'acrpassword'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: acrPasswordSecureValue<br>&nbsp;&nbsp;&nbsp;},<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'connectionstring'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: dbConnectionStringSecureValue<br>&nbsp;&nbsp;&nbsp;}<br>] |
| containers | array | <input type="checkbox" checked> | None | <pre></pre> | Required. List of container definitions for the Container App Job.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;image: 'nginx:latest'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'jobcontainer'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;resources: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cpu: '0.5'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;memory: '1Gi'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;}<br>] |
| initContainers | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional. List of specialized containers that run before job containers.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;image: 'alpine:latest'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'init-container'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;command: ['sh', '-c']<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;args: ['echo "Initializing..."']<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;resources: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cpu: '0.25'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;memory: '512Mi'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;}<br>] |
| volumes | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional. List of volume definitions for the Container App Job.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'azure-files'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;storageName: 'myazurefile'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;storageType: 'AzureFile'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;mountOptions: 'uid=1000,gid=1000'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| workloadProfileName | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The name of the workload profile to pin for container app job execution. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | Optional. The name of the diagnostics settings. This defaults to 'AzurePlatformCentralizedLogging'. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. The azure resource id of the log analytics workspace to log the diagnostics to. If empty, logging & diagnostics will be disabled. |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Optional. Which log categories to enable. This defaults to enabling all logs.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;categoryGroup: 'allLogs'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;enabled: true<br>&nbsp;&nbsp;&nbsp;}<br>] |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Optional. Which metrics categories to enable. This defaults to enabling all metrics.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;categoryGroup: 'AllMetrics'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;enabled: true<br>&nbsp;&nbsp;&nbsp;}<br>] |
| roleAssignments | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional. Array of role assignments for this container app job.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;roleDefinitionIdOrName: 'Owner'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;principalId: principalObjectId<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;principalType: 'ServicePrincipal'<br>&nbsp;&nbsp;&nbsp;}<br>] |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| jobId | string | The resource ID of the container app job. |
| jobName | string | The name of the container app job. |
| systemAssignedIdentityPrincipalId | string | The principal ID of the system assigned identity. |
| location | string | The location of the container app job. |
| provisioningState | string | The provisioning state of the container app job. |

## Examples
<pre>
module job 'br:contosoregistry.azurecr.io/app/jobs:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 56), 'job')
  params: {
    jobName: 'myjob'
    managedEnvironmentName: managedEnvironment.outputs.managedEnvironmentName
    triggerType: 'Manual'
    replicaTimeout: 300
    containers: [
      {
        name: 'jobcontainer'
        image: 'nginx:latest'
        resources: {
          cpu: '0.5'
          memory: '1Gi'
        }
      }
    ]
    location: location
  }
}
</pre>
<p>Creates a manual trigger container app job with a single nginx container.</p>
<pre>
module job 'br:contosoregistry.azurecr.io/app/jobs:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 56), 'job')
  params: {
    jobName: 'cronjob'
    managedEnvironmentName: managedEnvironment.outputs.managedEnvironmentName
    triggerType: 'Schedule'
    scheduleTriggerConfig: {
      cronExpression: '0 0 * * *'
      parallelism: 1
      replicaCompletionCount: 1
    }
    replicaTimeout: 300
    containers: [
      {
        name: 'jobcontainer'
        image: 'myacr.azurecr.io/myimage:latest'
        resources: {
          cpu: '1'
          memory: '2Gi'
        }
      }
    ]
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.id
    location: location
  }
}
</pre>
<p>Creates a scheduled (cron) container app job that runs daily at midnight with diagnostic logging.</p>

## Links
- [Bicep Microsoft.App jobs](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/jobs?pivots=deployment-language-bicep)<br>
- [Container Apps Jobs Documentation](https://learn.microsoft.com/en-us/azure/container-apps/jobs)
