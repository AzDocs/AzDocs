# containerApps

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="IdentityType">IdentityType</a>  | <pre></pre> | type |  | 
| <a id="ingressPortMapping">ingressPortMapping</a>  | <pre>{</pre> |  |  | 
| <a id="corsPolicyType">corsPolicyType</a>  | <pre>{</pre> |  |  | 
| <a id="container">container</a>  | <pre>{</pre> |  |  | 
| <a id="environmentVar">environmentVar</a>  | <pre>{</pre> |  |  | 
| <a id="containerAppProbe">containerAppProbe</a>  | <pre>{</pre> |  |  | 
| <a id="volumeMount">volumeMount</a>  | <pre>{</pre> |  |  | 
| <a id="containerAppProbeHttpGet">containerAppProbeHttpGet</a>  | <pre>{</pre> |  |  | 
| <a id="containerAppProbeHttpGetHeadersItem">containerAppProbeHttpGetHeadersItem</a>  | <pre>{</pre> |  |  | 
| <a id="containerAppProbeTcpSocket">containerAppProbeTcpSocket</a>  | <pre>{</pre> |  |  | 
| <a id="serviceBind">serviceBind</a>  | <pre>{</pre> |  |  | 

## Synopsis
Creating a Azure ContainerApp

## Description
Creating a container app with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| identity | IdentityType | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this configuration store. Defaults to a system assigned managed identity. <br>For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity).<br>Example:<br>identity: {<br>&nbsp;&nbsp;&nbsp;type: 'None'<br>},<br>identity: {<br>&nbsp;&nbsp;&nbsp;type: 'UserAssigned'<br>&nbsp;&nbsp;&nbsp;userAssignedIdentities: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'/subscriptions/<subscriptionId>/resourcegroups/<resourcegroupname>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<userassignedmanagedidentityname>': {}<br>&nbsp;&nbsp;&nbsp;}<br>} |
| containerAppName | string | <input type="checkbox" checked> | Length between 2-32 | <pre></pre> | The name of the container app. Should be unique per resourcegroup |
| managedEnvironmentName | string | <input type="checkbox" checked> | Length between 2-126 | <pre></pre> | Name of the managed environment the container app should be in. Should be pre-existing. |
| disableIngress | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Bool to disable all ingress traffic for the container app. |
| additionalPortMappings | ingressPortMapping[]? | <input type="checkbox" checked> | None | <pre></pre> | Optional extra tcp ports. Settings to expose additional ports on container app. AdditionalPortMappings must have unique exposedPort and TargetPort.<br>Applications with external additional port mappings can only be deployed to Container App Environments that have a custom VNET<br>Example:<br>additionalPortMappings: [<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;exposedPort: 8081<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;external: true<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;targetPort: 8080<br>&nbsp;&nbsp;&nbsp;}<br>] |
| corsPolicy | corsPolicyType | <input type="checkbox" checked> | None | <pre></pre> | Optional. Object userd to configure CORS policy. |
| clientCertificateMode | string | <input type="checkbox"> | `'accept'` or `'ignore'` or `'require'` | <pre>'ignore'</pre> | Optional. Client certificate mode for mTLS. |
| exposedPort | int | <input type="checkbox"> | None | <pre>0</pre> | Optional. Exposed Port in containers for TCP traffic from ingress. |
| ipSecurityRestrictions | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional. Rules to restrict incoming IP address. |
| stickySessionsAffinity | string | <input type="checkbox"> | `'none'` or `'sticky'` | <pre>'none'</pre> | Optional. Bool indicating if the Container App should enable session affinity. |
| trafficLabel | string | <input type="checkbox"> | None | <pre>'label1'</pre> | Optional. Associates a traffic label with a revision. Label name should be consist of lower case alphanumeric characters or dashes. |
| trafficLatestRevision | bool | <input type="checkbox"> | None | <pre>true</pre> | Optional. Indicates that the traffic weight belongs to a latest stable revision. |
| trafficRevisionName | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. Name of a revision. |
| trafficWeight | int | <input type="checkbox"> | None | <pre>100</pre> | Optional. Traffic weight assigned to a revision. |
| dapr | object | <input type="checkbox"> | None | <pre>{}</pre> | Dapr object. Dapr can be used for state store. This component should be pre-existing.<br>In the Container App resource, the daprId should match the scopes property within the dapr component being defined<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;enabled: true<br>&nbsp;&nbsp;&nbsp;appId: 'nodeapp'<br>&nbsp;&nbsp;&nbsp;appProtocol: 'http'<br>&nbsp;&nbsp;&nbsp;appPort: 3000<br>} |
| activeRevisionsMode | string | <input type="checkbox"> | `'Single'` or `'Multiple'` | <pre>'Single'</pre> | ActiveRevisionsMode controls how active revisions are handled for the Container app:<br>{list}{item}Multiple: multiple revisions can be active.{/item}{item}Single: Only one revision can be active at a time.Revision weights can not be used in this mode. |
| registries | array | <input type="checkbox"> | None | <pre>[]</pre> | Collection of private container registry credentials for containers used by the Container app.<br>If you want to use a public image you do not need to specify any registries, it will be pulled from DockerHub automatically.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;server: myacr.azurecr.io<br>&nbsp;&nbsp;&nbsp;username: azureContainerRegistryUsername<br>&nbsp;&nbsp;&nbsp;passwordSecretRef: 'containerregistrypasswordref'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| secrets | object | <input type="checkbox"> | None | <pre>{}</pre> | Collection of secrets used by a Container app. Use with @secure() decorator in modules i.c.w variables, parameters or keyvault.<br>Examples:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'containerregistrypasswordref'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: azureContainerRegistryPassword<br>&nbsp;&nbsp;&nbsp;}<br>],<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;server: 'index.docker.io'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;username: dockerContainerRegistryUsername<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;passwordSecretRef: 'containerregistrypasswordref'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| revisionSuffix | string | <input type="checkbox"> | None | <pre>''</pre> | User friendly suffix that is appended to the revision name |
| volumes | array | <input type="checkbox"> | None | <pre>[]</pre> | List of volume definitions for the Container App.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'azurefilemount'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/child-resource-name-type#within-parent-resource<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;storageName: environment::azurefilestorage.name<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;storageType: 'AzureFile'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| ingressAllowInsecure | bool | <input type="checkbox"> | None | <pre>false</pre> | Bool indicating if HTTP connections to is allowed.<br>If set to false HTTP connections are automatically redirected to HTTPS connections |
| ingressCustomDomains | array | <input type="checkbox"> | None | <pre>[]</pre> | Custom domain bindings for Container Apps' hostnames.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;bindingType: 'string'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;certificateId: 'string'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'string'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| ingressExternal | bool | <input type="checkbox"> | None | <pre>true</pre> | Bool indicating if app exposes an external http endpoint.<br>For applications that need to be accessed from external clients (eg., browsers, other clients, applications hosted somewhere else)<br>&nbsp;&nbsp;- set external in ingress to true |
| ingressTargetPort | int | <input type="checkbox"> | Value between 1-65535 | <pre>80</pre> | Target incoming Port in containers for incoming traffic (ingress). This will be the exposed port for the Docker Image.<br>The ingress section of the container app must have a targetPort specified. TargetPort must be in the range of [1,65535]. |
| ingressTransport | string | <input type="checkbox"> | `'auto'` or `'http'` or `'http2'` or `'tcp'` | <pre>'auto'</pre> | Ingress transport protocol |
| workloadProfileName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the existing container app workload profile. If used, it should be pre-existing in the managed environment. |
| includeAddOns | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Toggle to include the service configuration. |
| service | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. Dev ContainerApp service type. |
| maxInactiveRevisions | int | <input type="checkbox"> | None | <pre>0</pre> | Optional. Max inactive revisions a Container App can have. |
| containers | container[] | <input type="checkbox" checked> | None | <pre></pre> | Required. List of container definitions for the Container App.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;image: 'nginx'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'nginxcontainerapp'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;resources: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cpu: '0.5'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;memory: '1.0Gi'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;},<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;image: 'myacr.azurecr.io/customimagecontainerapp:latest'<br>&nbsp;&nbsp;&nbsp;name: 'customimagecontainerapp'<br>&nbsp;&nbsp;&nbsp;resources: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cpu: '0.5'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;memory: '1.0Gi'<br>&nbsp;&nbsp;&nbsp;}<br>},<br>{<br>&nbsp;&nbsp;&nbsp;image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'<br>&nbsp;&nbsp;&nbsp;name: 'simple-hello-world-container'<br>&nbsp;&nbsp;&nbsp;resources: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cpu: '0.5'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;memory: '1.0Gi'<br>&nbsp;&nbsp;&nbsp;}<br>},<br>{<br>&nbsp;&nbsp;&nbsp;image: '&#36;{dockerContainerRepository}/someprivatedockerhubimage:tag'<br>&nbsp;&nbsp;&nbsp;volumeMounts: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;mountPath: '/azurefiles'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;volumeName: 'azurefilemount'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;env: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'KEY_VAULT_NAME'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: keyVaultName<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'SECRET_NAME'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: secretName<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'AZURE_CLIENT_ID'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: reference(resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', userAssignedIdentity.name)).clientId<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;name: 'someprivatedockerhubimage'<br>&nbsp;&nbsp;&nbsp;resources: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cpu: '0.5'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;memory: '1.0Gi'<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;}<br>] |
| initContainersTemplate | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional. List of specialized containers that run before app containers. |
| scaleMaxReplicas | int | <input type="checkbox"> | None | <pre>3</pre> | Optional. Maximum number of container replicas. Defaults to 3 if not set. |
| scaleMinReplicas | int | <input type="checkbox"> | None | <pre>1</pre> | Optional. Minimum number of container replicas. Defaults to 1 if not set. |
| scaleRules | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional. Scaling rules.<br>Example:<br>scaleRules: [<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'http-requests'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;http: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;metadata: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;concurrentRequests: '10'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;}<br>] |
| serviceBinds | serviceBind[]? | <input type="checkbox" checked> | None | <pre></pre> | Optional. List of container app services bound to the app. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| containerAppFQDN | string | Output of the FQDN of the container App. |
| systemAssignedMIPrincipalId | string | The principal ID of the system assigned identity. |

## Examples
<pre>
module containerApp 'br:contosoregistry.azurecr.io/app/containerapps.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 51), 'containerapp')
  params: {
    managedEnvironmentName: managedEnvironment.outputs.managedEnvironmentName
    identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {
        '/subscriptions/8c89ea18-8578-4898-b51e-a4f45f502b0b/resourcegroups/cae-dev/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-kxjo5b6wmgva6': {}
      }
    }
    containerAppName: 'containerapp1'
    containers: [
      {
        name: 'container1'
        image: 'nginx'
        resources: {
          cpu: 1
          memory: '2Gi'
        }
        env: [
          {
            name: 'ENV1'
            value: 'VALUE1'
          }
        ]
      }
    ]
  }
}
</pre>
<p>Creates a container app with the name ca-nginxcontainerapp'</p>

## Links
- [Bicep Microsoft.App containerApps](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep)
