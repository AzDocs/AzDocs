/*
.SYNOPSIS
Creating an Azure Container Apps Job
.DESCRIPTION
Creating a container app job with the specified configuration. Supports Manual, Schedule, and Event-driven trigger types with comprehensive identity, secret management, and monitoring capabilities.
.EXAMPLE
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
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.App jobs](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/jobs?pivots=deployment-language-bicep)
- [Container Apps Jobs Documentation](https://learn.microsoft.com/en-us/azure/container-apps/jobs)
*/

// ================================================= Parameters =================================================

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('''
Managed service identity to use for this container app job. Defaults to a system assigned managed identity. 
For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity).
Example:
identity: {
  type: 'None'
},
identity: {
  type: 'UserAssigned'
  userAssignedIdentities: {
    '/subscriptions/<subscriptionId>/resourcegroups/<resourcegroupname>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<userassignedmanagedidentityname>': {}
  }
}
''')
param identity IdentityType = {
  type: 'SystemAssigned'
}

@discriminator('type')
type IdentityType =
  | {
    type: 'SystemAssigned'
  }
  | {
    type: 'UserAssigned'
    userAssignedIdentities: {
      *: {}
    }
  }
  | {
    type: 'None'
  }

@description('The name of the container app job. Must be unique per resource group. Alphanumeric characters and hyphens only.')
@minLength(2)
@maxLength(32)
param jobName string

@description('Name of the managed environment the container app job should be in. Should be pre-existing.')
@minLength(2)
@maxLength(126)
param managedEnvironmentName string

@description('''
Required. The trigger type of the job.
- Manual: Job can be triggered manually
- Schedule: Job runs on a schedule using cron expression
- Event: Job is triggered by external events
''')
@allowed([
  'Manual'
  'Schedule'
  'Event'
])
param triggerType string

@description('''
Optional. Configuration for manual trigger type. Only used when triggerType is 'Manual'.
Example:
{
  parallelism: 4
  replicaCompletionCount: 1
}
''')
param manualTriggerConfig object?

@description('''
Optional. Configuration for schedule trigger type. Required when triggerType is 'Schedule'.
Example:
{
  cronExpression: '0 0 * * *'
  parallelism: 1
  replicaCompletionCount: 1
}
''')
param scheduleTriggerConfig object?

@description('''
Optional. Configuration for event trigger type. Only used when triggerType is 'Event'.
Example:
{
  parallelism: 2
  replicaCompletionCount: 1
  scale: {
    minExecutions: 0
    maxExecutions: 10
    pollingInterval: 30
    rules: []
  }
}
''')
param eventTriggerConfig object?

@description('Required. Maximum number of seconds a replica is allowed to run.')
@minValue(1)
param replicaTimeout int

@description('Optional. Maximum number of retries before failing the job. Defaults to no limit if not set.')
param replicaRetryLimit int?

@description('''
Optional. Settings for Managed Identities that are assigned to the Container App Job. If a Managed Identity is not specified here, default settings will be used.
Example:
[
  {
    identity: '/subscriptions/<subscriptionId>/resourcegroups/<resourcegroupname>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<userassignedmanagedidentityname>'
    lifecycle: 'All'
  }
]
''')
param identitySettings array = []

@description('''
Optional. Collection of private container registry credentials for containers used by the Container App Job.
Example:
[
  {
    server: 'myacr.azurecr.io'
    username: 'acruser'
    passwordSecretRef: 'acrpassword'
    identity: 'system'
  }
]
''')
param registries array = []

@description('''
Optional. Collection of secrets used by a Container App Job. Use with @secure() decorator in modules.
Example:
[
  {
    name: 'acrpassword'
    value: acrPasswordSecureValue
  },
  {
    name: 'connectionstring'
    value: dbConnectionStringSecureValue
  }
]
''')
@secure()
param secrets object = {}

@description('''
Required. List of container definitions for the Container App Job.
Example:
[
  {
    image: 'nginx:latest'
    name: 'jobcontainer'
    resources: {
      cpu: '0.5'
      memory: '1Gi'
    }
  }
]
''')
param containers array

type container = {
  @description('Optional. Container start command.')
  command: string[]?

  @description('Optional. Container start command arguments.')
  args: string[]?

  @description('Required. Container image tag.')
  image: string

  @description('Optional. Type of image. Either "ContainerImage" for user-provided images or "CloudBuild" for CloudBuild managed images.')
  imageType: ('ContainerImage' | 'CloudBuild')?

  @description('''
  Required. Custom container name. Must consist of lower case alphanumeric characters or hyphens, 
  start with an alphabetic character, and end with an alphanumeric character. Maximum 32 characters.
  ''')
  name: string

  @description('Optional. Container environment variables.')
  env: environmentVarType[]?

  @description('Required. Container resource requirements.')
  resources: containerResourcesType

  @description('Optional. Container volume mounts.')
  volumeMounts: volumeMountType[]?

  @description('Optional. List of probes for the container.')
  probes: containerProbeType[]?
}

type environmentVarType = {
  @description('Required. Environment variable name.')
  name: string

  @description('Optional. Non-secret environment variable value.')
  value: string?

  @description('Optional. Name of the Container App secret from which to pull the environment variable value.')
  secretRef: string?
}

type containerResourcesType = {
  @description('Required. Required CPU in cores as a string, e.g. "0.5", "1", "2", "4". Can be fractional values.')
  cpu: string

  @description('Required. Required memory, e.g. "0.5Gi", "1Gi", "2Gi", "4Gi".')
  memory: string

  @description('Optional. Required GPU in cores for GPU-based jobs.')
  gpu: int?
}

type volumeMountType = {
  @description('Required. Path within the container at which the volume should be mounted. Must not contain ":".')
  mountPath: string

  @description('Required. This must match the Name of a Volume.')
  volumeName: string

  @description('Optional. Path within the volume from which the container\'s volume should be mounted. Defaults to "" (volume\'s root).')
  subPath: string?
}

type containerProbeType = {
  @description('Optional. The type of probe.')
  type: ('Liveness' | 'Readiness' | 'Startup')?

  @description('Optional. HTTPGet specifies the http request to perform.')
  httpGet: containerProbeHttpGetType?

  @description('Optional. TCPSocket specifies an action involving a TCP port.')
  tcpSocket: containerProbeTcpSocketType?

  @description('Optional. Number of seconds after the container has started before probes are initiated.')
  @minValue(1)
  @maxValue(60)
  initialDelaySeconds: int?

  @description('Optional. How often (in seconds) to perform the probe. Defaults to 10.')
  @minValue(1)
  @maxValue(240)
  periodSeconds: int?

  @description('Optional. Number of seconds after which the probe times out. Defaults to 1.')
  @minValue(1)
  @maxValue(240)
  timeoutSeconds: int?

  @description('Optional. Minimum consecutive failures for the probe to be considered failed. Defaults to 3.')
  @minValue(1)
  @maxValue(10)
  failureThreshold: int?

  @description('Optional. Minimum consecutive successes for the probe to be considered successful. Defaults to 1.')
  @minValue(1)
  @maxValue(10)
  successThreshold: int?

  @description('Optional. Grace period in seconds for graceful termination upon probe failure.')
  terminationGracePeriodSeconds: int?
}

type containerProbeHttpGetType = {
  @description('Required. Port number or name to access on the container.')
  port: int

  @description('Optional. Scheme to use for connecting to the host. Defaults to HTTP.')
  scheme: ('HTTP' | 'HTTPS')?

  @description('Optional. Host name to connect to. Defaults to the pod IP.')
  host: string?

  @description('Optional. Path to access on the HTTP server.')
  path: string?

  @description('Optional. HTTP headers to set in the request.')
  httpHeaders: containerProbeHttpGetHeaderType[]?
}

type containerProbeHttpGetHeaderType = {
  @description('Required. Name of the header.')
  name: string

  @description('Required. Value of the header.')
  value: string
}

type containerProbeTcpSocketType = {
  @description('Required. Port number to access on the container.')
  @minValue(1)
  @maxValue(65535)
  port: int

  @description('Optional. Host name to connect to. Defaults to the pod IP.')
  host: string?
}

@description('''
Optional. List of specialized containers that run before job containers.
Example:
[
  {
    image: 'alpine:latest'
    name: 'init-container'
    command: ['sh', '-c']
    args: ['echo "Initializing..."']
    resources: {
      cpu: '0.25'
      memory: '512Mi'
    }
  }
]
''')
param initContainers array = []

@description('''
Optional. List of volume definitions for the Container App Job.
Example:
[
  {
    name: 'azure-files'
    storageName: 'myazurefile'
    storageType: 'AzureFile'
    mountOptions: 'uid=1000,gid=1000'
  }
]
''')
param volumes array = []

@description('Optional. The name of the workload profile to pin for container app job execution.')
param workloadProfileName string = ''

@description('''
Optional. The name of the diagnostics settings. This defaults to 'AzurePlatformCentralizedLogging'.
''')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('Optional. The azure resource id of the log analytics workspace to log the diagnostics to. If empty, logging & diagnostics will be disabled.')
param logAnalyticsWorkspaceResourceId string = ''

@description('''
Optional. Which log categories to enable. This defaults to enabling all logs.
Example:
[
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]
''')
param diagnosticSettingsLogsCategories array = [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]

@description('''
Optional. Which metrics categories to enable. This defaults to enabling all metrics.
Example:
[
  {
    categoryGroup: 'AllMetrics'
    enabled: true
  }
]
''')
param diagnosticSettingsMetricsCategories array = [
  {
    categoryGroup: 'AllMetrics'
    enabled: true
  }
]

@description('''
Optional. Array of role assignments for this container app job.
Example:
[
  {
    roleDefinitionIdOrName: 'Owner'
    principalId: principalObjectId
    principalType: 'ServicePrincipal'
  }
]
''')
param roleAssignments array = []

var secretList = !empty(secrets) ? secrets.secureList : []

var formattedContainers = [
  for container in containers: union(
    {
      name: container.name
      image: container.image
      resources: {
        cpu: json(container.resources.cpu)
        memory: container.resources.memory
      }
    },
    container.?args != null ? { args: container.args } : {},
    container.?command != null ? { command: container.command } : {},
    container.?env != null ? { env: container.env } : {},
    container.?probes != null ? { probes: container.probes } : {},
    container.?volumeMounts != null ? { volumeMounts: container.volumeMounts } : {}
  )
]

var formattedInitContainers = [
  for container in initContainers: union(
    {
      name: container.name
      image: container.image
      resources: {
        cpu: json(container.resources.cpu)
        memory: container.resources.memory
      }
    },
    container.?args != null ? { args: container.args } : {},
    container.?command != null ? { command: container.command } : {},
    container.?env != null ? { env: container.env } : {},
    container.?volumeMounts != null ? { volumeMounts: container.volumeMounts } : {}
  )
]

// ================================================= Resources =================================================

@description('Reference to the managed environment. Should be pre-existing.')
resource managedEnvironment 'Microsoft.App/managedEnvironments@2025-01-01' existing = {
  name: managedEnvironmentName
}

@description('The container app job resource.')
resource job 'Microsoft.App/jobs@2025-01-01' = {
  name: jobName
  location: location
  identity: identity
  tags: tags
  properties: {
    environmentId: managedEnvironment.id
    configuration: union(
      {
        triggerType: triggerType
        replicaTimeout: replicaTimeout
      },
      replicaRetryLimit != null ? { replicaRetryLimit: replicaRetryLimit } : {},
      triggerType == 'Manual'
        ? { manualTriggerConfig: (manualTriggerConfig ?? { parallelism: 1, replicaCompletionCount: 1 }) }
        : {},
      (triggerType == 'Schedule' && scheduleTriggerConfig != null)
        ? { scheduleTriggerConfig: scheduleTriggerConfig }
        : {},
      (triggerType == 'Event' && eventTriggerConfig != null) ? { eventTriggerConfig: eventTriggerConfig } : {},
      !empty(identitySettings) ? { identitySettings: identitySettings } : {},
      !empty(registries) ? { registries: registries } : {},
      !empty(secretList) ? { secrets: secretList } : {}
    )
    template: union(
      {
        containers: formattedContainers
      },
      !empty(initContainers) ? { initContainers: formattedInitContainers } : {},
      !empty(volumes) ? { volumes: volumes } : {}
    )
    workloadProfileName: !empty(workloadProfileName) ? workloadProfileName : null
  }
}

@description('Diagnostic settings for the container app job.')
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: job
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('Role assignments for the container app job.')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [
  for assignment in roleAssignments: {
    name: guid(job.name, assignment.principalId, assignment.roleDefinitionIdOrName)
    scope: job
    properties: {
      roleDefinitionId: subscriptionResourceId(
        'Microsoft.Authorization/roleDefinitions',
        assignment.roleDefinitionIdOrName
      )
      principalId: assignment.principalId
      principalType: assignment.?principalType ?? 'ServicePrincipal'
    }
  }
]

// ================================================= Outputs =================================================

@description('The resource ID of the container app job.')
output jobId string = job.id

@description('The name of the container app job.')
output jobName string = job.name

@description('The principal ID of the system assigned identity.')
output systemAssignedIdentityPrincipalId string = job.?identity.?principalId ?? ''

@description('The location of the container app job.')
output location string = job.location

@description('The provisioning state of the container app job.')
output provisioningState string = job.properties.provisioningState
