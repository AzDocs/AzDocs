# jobs

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="IdentityType">IdentityType</a>  | <pre>&nbsp;&nbsp;&nbsp;&#124; {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;type: 'SystemAssigned'<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&#124; {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;type: 'UserAssigned'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;userAssignedIdentities: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*: {}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&#124; {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;type: 'None'<br>&nbsp;&nbsp;&nbsp;}<br></pre> | type |  | 
| <a id="container">container</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Optional. Container start command.')<br>&nbsp;&nbsp;&nbsp;command: string[]?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Container start command arguments.')<br>&nbsp;&nbsp;&nbsp;args: string[]?<br><br>&nbsp;&nbsp;&nbsp;@description('Required. Container image tag.')<br>&nbsp;&nbsp;&nbsp;image: string<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Type of image. Either "ContainerImage" for user-provided images or "CloudBuild" for CloudBuild managed images.')<br>&nbsp;&nbsp;&nbsp;imageType: ('ContainerImage' &#124; 'CloudBuild')?<br><br>&nbsp;&nbsp;&nbsp;@description('''<br>&nbsp;&nbsp;&nbsp;Required. Custom container name. Must consist of lower case alphanumeric characters or hyphens, <br>&nbsp;&nbsp;&nbsp;start with an alphabetic character, and end with an alphanumeric character. Maximum 32 characters.<br>&nbsp;&nbsp;&nbsp;''')<br>&nbsp;&nbsp;&nbsp;name: string<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Container environment variables.')<br>&nbsp;&nbsp;&nbsp;env: environmentVarType[]?<br><br>&nbsp;&nbsp;&nbsp;@description('Required. Container resource requirements.')<br>&nbsp;&nbsp;&nbsp;resources: containerResourcesType<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Container volume mounts.')<br>&nbsp;&nbsp;&nbsp;volumeMounts: volumeMountType[]?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. List of probes for the container.')<br>&nbsp;&nbsp;&nbsp;probes: containerProbeType[]?<br>}<br></pre> |  |  | 
| <a id="environmentVarType">environmentVarType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Required. Environment variable name.')<br>&nbsp;&nbsp;&nbsp;name: string<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Non-secret environment variable value.')<br>&nbsp;&nbsp;&nbsp;value: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Name of the Container App secret from which to pull the environment variable value.')<br>&nbsp;&nbsp;&nbsp;secretRef: string?<br>}<br></pre> |  |  | 
| <a id="containerResourcesType">containerResourcesType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Required. Required CPU in cores as a string, e.g. "0.5", "1", "2", "4". Can be fractional values.')<br>&nbsp;&nbsp;&nbsp;cpu: string<br><br>&nbsp;&nbsp;&nbsp;@description('Required. Required memory, e.g. "0.5Gi", "1Gi", "2Gi", "4Gi".')<br>&nbsp;&nbsp;&nbsp;memory: string<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Required GPU in cores for GPU-based jobs.')<br>&nbsp;&nbsp;&nbsp;gpu: int?<br>}<br></pre> |  |  | 
| <a id="volumeMountType">volumeMountType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Required. Path within the container at which the volume should be mounted. Must not contain ":".')<br>&nbsp;&nbsp;&nbsp;mountPath: string<br><br>&nbsp;&nbsp;&nbsp;@description('Required. This must match the Name of a Volume.')<br>&nbsp;&nbsp;&nbsp;volumeName: string<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Path within the volume from which the container\'s volume should be mounted. Defaults to "" (volume\'s root).')<br>&nbsp;&nbsp;&nbsp;subPath: string?<br>}<br></pre> |  |  | 
| <a id="containerProbeType">containerProbeType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Optional. The type of probe.')<br>&nbsp;&nbsp;&nbsp;type: ('Liveness' &#124; 'Readiness' &#124; 'Startup')?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. HTTPGet specifies the http request to perform.')<br>&nbsp;&nbsp;&nbsp;httpGet: containerProbeHttpGetType?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. TCPSocket specifies an action involving a TCP port.')<br>&nbsp;&nbsp;&nbsp;tcpSocket: containerProbeTcpSocketType?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Number of seconds after the container has started before probes are initiated.')<br>&nbsp;&nbsp;&nbsp;@minValue(1)<br>&nbsp;&nbsp;&nbsp;@maxValue(60)<br>&nbsp;&nbsp;&nbsp;initialDelaySeconds: int?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. How often (in seconds) to perform the probe. Defaults to 10.')<br>&nbsp;&nbsp;&nbsp;@minValue(1)<br>&nbsp;&nbsp;&nbsp;@maxValue(240)<br>&nbsp;&nbsp;&nbsp;periodSeconds: int?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Number of seconds after which the probe times out. Defaults to 1.')<br>&nbsp;&nbsp;&nbsp;@minValue(1)<br>&nbsp;&nbsp;&nbsp;@maxValue(240)<br>&nbsp;&nbsp;&nbsp;timeoutSeconds: int?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Minimum consecutive failures for the probe to be considered failed. Defaults to 3.')<br>&nbsp;&nbsp;&nbsp;@minValue(1)<br>&nbsp;&nbsp;&nbsp;@maxValue(10)<br>&nbsp;&nbsp;&nbsp;failureThreshold: int?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Minimum consecutive successes for the probe to be considered successful. Defaults to 1.')<br>&nbsp;&nbsp;&nbsp;@minValue(1)<br>&nbsp;&nbsp;&nbsp;@maxValue(10)<br>&nbsp;&nbsp;&nbsp;successThreshold: int?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Grace period in seconds for graceful termination upon probe failure.')<br>&nbsp;&nbsp;&nbsp;terminationGracePeriodSeconds: int?<br>}<br></pre> |  |  | 
| <a id="containerProbeHttpGetType">containerProbeHttpGetType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Required. Port number or name to access on the container.')<br>&nbsp;&nbsp;&nbsp;port: int<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Scheme to use for connecting to the host. Defaults to HTTP.')<br>&nbsp;&nbsp;&nbsp;scheme: ('HTTP' &#124; 'HTTPS')?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Host name to connect to. Defaults to the pod IP.')<br>&nbsp;&nbsp;&nbsp;host: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Path to access on the HTTP server.')<br>&nbsp;&nbsp;&nbsp;path: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. HTTP headers to set in the request.')<br>&nbsp;&nbsp;&nbsp;httpHeaders: containerProbeHttpGetHeaderType[]?<br>}<br></pre> |  |  | 
| <a id="containerProbeHttpGetHeaderType">containerProbeHttpGetHeaderType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Required. Name of the header.')<br>&nbsp;&nbsp;&nbsp;name: string<br><br>&nbsp;&nbsp;&nbsp;@description('Required. Value of the header.')<br>&nbsp;&nbsp;&nbsp;value: string<br>}<br></pre> |  |  | 
| <a id="containerProbeTcpSocketType">containerProbeTcpSocketType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Required. Port number to access on the container.')<br>&nbsp;&nbsp;&nbsp;@minValue(1)<br>&nbsp;&nbsp;&nbsp;@maxValue(65535)<br>&nbsp;&nbsp;&nbsp;port: int<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Host name to connect to. Defaults to the pod IP.')<br>&nbsp;&nbsp;&nbsp;host: string?<br>}<br></pre> |  |  | 

## Synopsis
Creating an Azure Container Apps Job

## Description
Creating a container app job with the specified configuration. Supports Manual, Schedule, and Event-driven trigger types with comprehensive identity, secret management, and monitoring capabilities.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| identity | [IdentityType](#IdentityType) | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this container app job. Defaults to a system assigned managed identity. <br>For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity).<br>Example:<br>identity: {<br>&nbsp;&nbsp;&nbsp;type: 'None'<br>},<br>identity: {<br>&nbsp;&nbsp;&nbsp;type: 'UserAssigned'<br>&nbsp;&nbsp;&nbsp;userAssignedIdentities: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'/subscriptions/<subscriptionId>/resourcegroups/<resourcegroupname>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<userassignedmanagedidentityname>': {}<br>&nbsp;&nbsp;&nbsp;}<br>} |
| jobName | string | <input type="checkbox" checked> | Length between 2-32 | <pre></pre> | The name of the container app job. Must be unique per resource group. Alphanumeric characters and hyphens only. |
| managedEnvironmentName | string | <input type="checkbox" checked> | Length between 2-126 | <pre></pre> | Name of the managed environment the container app job should be in. Should be pre-existing. |
| managedEnvironmentResourceGroupName | string | <input type="checkbox"> | Length between 1-90 | <pre>az.resourceGroup().name</pre> | The name of the resourcegroup where the managed environment resides. Defaults to the current resourcegroup. |
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
