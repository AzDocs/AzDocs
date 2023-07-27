# versions

Target Scope: resourceGroup

## Synopsis
Create an azure VM Image Version.

## Description
Create an  azure VM Image Version.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| galleryName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | Name of the gallery. |
| imageName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | Name of the image definition. |
| version | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | Name of the image definition. Like 1.0.0 |
| sourceId | string | <input type="checkbox" checked> | None | <pre></pre> | The id of the gallery artifact version source. Can specify a disk uri, snapshot uri, user image or storage account resource. |
| excludedFromLatest | bool | <input type="checkbox"> | None | <pre>true</pre> | If set to true, Virtual Machines deployed from the latest version of the Image Definition won\'t use this Image Version. |
| customTargetRegions | array | <input type="checkbox"> | None | <pre>[]</pre> | The target regions where the Image Version is going to be replicated to. See [here](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries/images/versions?pivots=deployment-language-bicep#targetregion) for the syntax. |
| defaultTargetRegions | array | <input type="checkbox"> | `'eastus'` or `'eastus2'` or `'southcentralus'` or `'westus2'` or `'westus3'` or `'australiaeast'` or `'southeastasia'` or `'northeurope'` or `'swedencentral'` or `'uksouth'` or `'westeurope'` or `'centralus'` or `'southafricanorth'` or `'centralindia'` or `'eastasia'` or `'japaneast'` or `'koreacentral'` or `'canadacentral'` or `'francecentral'` or `'germanywestcentral'` or `'norwayeast'` or `'polandcentral'` or `'switzerlandnorth'` or `'uaenorth'` or `'brazilsouth'` or `'centraluseuap'` or `'qatarcentral'` or `'brazilus'` or `'eastusstg'` or `'northcentralus'` or `'westus'` or `'jioindiawest'` or `'eastus2euap'` or `'southcentralusstg'` or `'westcentralus'` or `'southafricawest'` or `'australiacentral'` or `'australiacentral2'` or `'australiasoutheast'` or `'japanwest'` or `'jioindiacentral'` or `'koreasouth'` or `'southindia'` or `'westindia'` or `'canadaeast'` or `'francesouth'` or `'germanynorth'` or `'norwaywest'` or `'switzerlandwest'` or `'ukwest'` or `'uaecentral'` or `'brazilsoutheast'` | <pre>[<br>  'westeurope'<br>]</pre> | The target regions where the Image Version is going to be replicated to. It uses the default settings of the version. |
| storageAccountType | string | <input type="checkbox"> | `'Premium_LRS'` or `'StandardSSD_LRS'` or `'Standard_LRS'` or `'Standard_ZRS'` | <pre>'Standard_LRS'</pre> | Specifies the storage account type to be used to store the image |
| replicaCount | int | <input type="checkbox"> | Value between 1-* | <pre>1</pre> | The number of replicas of the Image Version to be created per region. This property would take effect for a region when regionalReplicaCount is not specified. |
| replicationMode | string | <input type="checkbox"> | `'Full'` or `'Shallow'` | <pre>'Full'</pre> | Specifies the mode to be used for replication. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Resource location |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
## Examples
<pre>

param currentDateString string = utcNow('yyyyMMdd-HHmm')
param location string = resourceGroup().location
param excludedFromLatest bool = true

var imageSource = {
  subscriptionId : '704256d6-906c-4812-a2d2-918164231086'
  resourceGroupName : 'my-gallery-rg'
  galleryName : 'gal.myteam.agents'
  imageDefinitionName : 'ubuntu22'
  imageVersionName : '2023.07.16'
}
var imageDestination = {
  galleryname : 'gal.shared.agents'
  imageDefinitionName : 'ubuntu22'
  imageVersionName : '2023.07.16'
}

resource sourceGallery 'Microsoft.Compute/galleries@2022-03-03' existing = {
  name: imageSource.galleryName
  scope: resourceGroup(imageSource.subscriptionId, imageSource.resourceGroupName)
}

resource sourceImageDefinition 'Microsoft.Compute/galleries/images@2022-03-03' existing = {
  name: imageSource.imageDefinitionName
  parent: sourceGallery
}
resource sourceImageVersion 'Microsoft.Compute/galleries/images/versions@2022-03-03' existing = {
  name: imageSource.imageVersionName
  parent: sourceImageDefinition
}

module destinationImageVersion 'Azure.PlatformProvisioning/src-bicep/Compute/galleries/images/versions.bicep' = {
  name: 'copy-image-${currentDateString}'
  params: {
    location: location
    sourceId: sourceImageVersion.id
    galleryName: imageDestination.galleryname
    imageName: imageDestination.imageDefinitionName
    version: imageDestination.imageVersionName
    excludedFromLatest: excludedFromLatest
  }
}
</pre>
<p>copy a image from another gallery to the destination gallery </p>

## Links
- [Bicep Microsoft.Compute galleries](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries?pivots=deployment-language-bicep)<br>
- [Bicep Microsoft.Compute galleries/images](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries/images?pivots=deployment-language-bicep)<br>
- [Bicep Microsoft.Compute galleries/images/versions](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries/images/versions?pivots=deployment-language-bicep)


