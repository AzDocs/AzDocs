# containerApps

Target Scope: resourceGroup

## Synopsis
Creating a Azure ContainerApp

## Description
Creating a container app with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Sets the identity property for the vault<br>Examples:<br>{<br>&nbsp;&nbsp;&nbsp;type: 'UserAssigned'<br>&nbsp;&nbsp;&nbsp;userAssignedIdentities: {}<br>},<br>{<br>&nbsp;&nbsp;&nbsp;type: 'SystemAssigned'<br>} |
| containerAppName | string | <input type="checkbox" checked> | Length between 2-32 | <pre></pre> | The name of the container app. Should be unique per resourcegroup |
| managedEnvironmentName | string | <input type="checkbox" checked> | Length between 2-126 | <pre></pre> | Name of the managed environment the container app should be in. Should be pre-existing. |
| dapr | object | <input type="checkbox"> | None | <pre>{}</pre> | Dapr object. Dapr can be used for state store. This component should be pre-existing.<br>In the Container App resource, the daprId should match the scopes property within the dapr component being defined<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;enabled: true<br>&nbsp;&nbsp;&nbsp;appId: 'nodeapp'<br>&nbsp;&nbsp;&nbsp;appProtocol: 'http'<br>&nbsp;&nbsp;&nbsp;appPort: 3000<br>} |
| containerAppContainers | array | <input type="checkbox" checked> | None | <pre></pre> | The containers you want to run in your container app.<br>Examples:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;image: 'myacr.azurecr.io/customimagecontainerapp:latest'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'customimagecontainerapp'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;resources: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cpu: '0.5'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;memory: '1.0Gi'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;}<br>],<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'simple-hello-world-container'<br>&nbsp;&nbsp;&nbsp;}<br>],<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;image: '${dockerContainerRepository}/someprivatedockerhubimage:tag'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;volumeMounts: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;mountPath: '/azurefiles'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;volumeName: 'azurefilemount'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;env: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'KEY_VAULT_NAME'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: keyVaultName<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'SECRET_NAME'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: secretName<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'AZURE_CLIENT_ID'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: reference(resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', userAssignedIdentity.name)).clientId<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'someprivatedockerhubimage'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;resources: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cpu: '0.5'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;memory: '1.0Gi'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;}<br>] |
| containerAppScale | object | <input type="checkbox"> | None | <pre>{<br>  minReplicas: 1<br>  maxReplicas: 1<br>}</pre> | The scaling for the containers in the container app.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;minReplicas: minReplica<br>&nbsp;&nbsp;&nbsp;maxReplicas: maxReplica<br>&nbsp;&nbsp;&nbsp;rules: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'http-requests'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;http: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;metadata: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;concurrentRequests: '10'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;]<br>} |
| activeRevisionsMode | string | <input type="checkbox"> | `'Single'` or  `'Multiple'` | <pre>'Single'</pre> | ActiveRevisionsMode controls how active revisions are handled for the Container app:<br>{list}{item}Multiple: multiple revisions can be active.{/item}{item}Single: Only one revision can be active at a time.Revision weights can not be used in this mode. |
| registries | array | <input type="checkbox"> | None | <pre>[]</pre> | Collection of private container registry credentials for containers used by the Container app.<br>If you want to use a public image you do not need to specify any registries, it will be pulled from DockerHub automatically.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;server: myacr.azurecr.io<br>&nbsp;&nbsp;&nbsp;username: azureContainerRegistryUsername<br>&nbsp;&nbsp;&nbsp;passwordSecretRef: 'containerregistrypasswordref'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| secrets | array | <input type="checkbox"> | None | <pre>[]</pre> | Examples:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'containerregistrypasswordref'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value: azureContainerRegistryPassword<br>&nbsp;&nbsp;&nbsp;}<br>],<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;server: 'index.docker.io'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;username: dockerContainerRegistryUsername<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;passwordSecretRef: 'containerregistrypasswordref'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| revisionSuffix | string | <input type="checkbox"> | None | <pre>''</pre> | User friendly suffix that is appended to the revision name |
| volumes | array | <input type="checkbox"> | None | <pre>[]</pre> | List of volume definitions for the Container App.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'azurefilemount'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/child-resource-name-type#within-parent-resource<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;storageName: environment::azurefilestorage.name<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;storageType: 'AzureFile'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| ingressAllowInsecure | bool | <input type="checkbox"> | None | <pre>false</pre> | Bool indicating if HTTP connections to is allowed.<br>If set to false HTTP connections are automatically redirected to HTTPS connections |
| ingressCustomDomains | array | <input type="checkbox"> | None | <pre>[]</pre> | Custom domain bindings for Container Apps' hostnames.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;bindingType: 'string'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;certificateId: 'string'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'string'<br>&nbsp;&nbsp;&nbsp;}<br>] |
| ingressExternal | bool | <input type="checkbox"> | None | <pre>true</pre> | Bool indicating if app exposes an external http endpoint.<br>For applications that need to be accessed from external clients (eg., browsers, other clients, applications hosted somewhere else)<br>&nbsp;&nbsp;- set external in ingress to true |
| ingressTargetPort | int | <input type="checkbox"> | Value between 1-65535 | <pre>80</pre> | Target incoming Port in containers for incoming traffic (ingress). This will be the exposed port for the Docker Image.<br>The ingress section of the container app must have a targetPort specified. TargetPort must be in the range of [1,65535]. |
| ingressTraffic | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    weight: 100<br>    latestRevision: true<br>  }<br>]</pre> | Traffic weights for app's revisions.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;label: 'mylabel'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;latestRevision: true<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;weight: 100<br>&nbsp;&nbsp;&nbsp;}<br>] |
| ingressTransport | string | <input type="checkbox"> | `'auto'` or  `'http'` or  `'http2'` | <pre>'auto'</pre> | Ingress transport protocol |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| containerAppFQDN | string | Output of the FQDN of the container App. |
## Examples
<pre>
module containerApp '../../AzDocs/src-bicep/App/containerApps.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'containerapp')
  params: {
    containerAppName: 'nginxcontainerapp'
    dapr: {}
    managedEnvironmentName: managedEnvironment.outputs.managedEnvironmentName
    ingressTargetPort: 80
    location: location
    containerAppContainers: [
      {
        image: 'nginx'
        name: 'nginxcontainerapp' //name of the container in the container app.
        resources: {
          cpu: '0.5'
          memory: '1.0Gi'
        }
      }
    ]
    containerAppScale: {
      minReplicas: 1
      maxReplicas: 1
    }
  }
}
</pre>
<p>Creates a container app with the name nginxcontainerapp'</p>

## Links
- [Bicep Microsoft.App containerApps](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep)


