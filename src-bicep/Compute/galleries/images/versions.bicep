/*
.SYNOPSIS
Create an azure VM Image Version.
.DESCRIPTION
Create an  azure VM Image Version.
.EXAMPLE
<pre>

param currentDateString string = utcNow('yyyyMMdd-HHmm')
param location string = resourceGroup().location

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
  excludedFromLatest: true
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

module destinationImageVersion 'br:contosoregistry.azurecr.io/compute/galleries/images/versions:latest' = {
  name: 'copy-image-${currentDateString}'
  params: {
    location: location
    sourceId: sourceImageVersion.id
    galleryName: imageDestination.galleryname
    imageName: imageDestination.imageDefinitionName
    version: imageDestination.imageVersionName
    excludedFromLatest: imageDestination.excludedFromLatest
  }
}
</pre>
<p>copy a image from another gallery to the destination gallery </p>

.EXAMPLE
<pre>

param location string = resourceGroup().location
param currentDateString string = utcNow('yyyyMMdd-HHmm')

var imageSource = {
  subscriptionId : '704256d6-906c-4812-a2d2-918164231086'
  resourceGroupName : 'my-gallery-rg'
  storageAccountName : 'storageaccount'
  vhdUrl: 'https://storageaccount.blob.core.windows.net/system/Microsoft.Compute/Images/images/packer-osDisk.ec54d178-90c3-4525-a552-a35fe167b666.vhd'
}

var imageDestination = {
  galleryname : 'gal.shared.agents'
  imageDefinitionName : 'ubuntu22'
  imageVersionName : '2023.07.16'
  excludedFromLatest: true
}

var storageAccountId = resourceId(imageSource.subscriptionId,imageSource.resourceGroupName,'Microsoft.Storage/storageAccounts',imageSource.storageAccountName )

module imageVersion 'br:contosoregistry.azurecr.io/compute/galleries/images/versions:latest' = {
  name: 'copy-image-${currentDateString}'
  params: {
    location: location
    sourceStorageAccountId: storageAccountId
    sourceStorageAccountVhdUri: imageSource.vhdUrl
    galleryName: imageDestination.galleryname
    imageName: imageDestination.imageDefinitionName
    version: imageDestination.imageVersionName
    excludedFromLatest: imageDestination.excludedFromLatest
  }
}

</pre>
<p>copy a vhd in a storage account to the destination gallery </p>

.LINKS
- [Bicep Microsoft.Compute galleries](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries?pivots=deployment-language-bicep)
- [Bicep Microsoft.Compute galleries/images](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries/images?pivots=deployment-language-bicep)
- [Bicep Microsoft.Compute galleries/images/versions](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries/images/versions?pivots=deployment-language-bicep)
*/

@description('Name of the gallery.')
@minLength(1)
@maxLength(80)
param galleryName string

@description('Name of the image definition.')
@minLength(1)
@maxLength(80)
param imageName string

@description('Name of the image definition. Like 1.0.0')
@minLength(1)
@maxLength(80)
param version string

@description('The id of the gallery artifact version source. Can specify a disk uri, snapshot uri, user image or storage account resource.')
param sourceId string = ''

@description('The storage account id, that is used in combination with **sourceStorageAccountVhdUri**.')
param sourceStorageAccountId string = ''

@description('Uri of the VHD image in a storage account. Need to be used with **sourceStorageAccountId**')
param sourceStorageAccountVhdUri string = ''

@description('''
You can adjust the host caching to match your workload requirements for each disk. You can set your host caching to be:

Read-only: For workloads that only do read operations
Read/write: For workloads that do a balance of read and write operations
''')
@allowed([
  'None'
  'ReadOnly'
  'ReadWrite'
])
param osDiskHostCaching string = 'ReadOnly'

@description('If set to true, Virtual Machines deployed from the latest version of the Image Definition won\'t use this Image Version.')
param excludedFromLatest bool = true

@description('The target regions where the Image Version is going to be replicated to. See [here](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries/images/versions?pivots=deployment-language-bicep#targetregion) for the syntax.')
param customTargetRegions array = []

// ( az account list-locations |convertfrom-json | where { $_.metadata.regionType -eq 'Physical'} ).name | foreach { "'$_'" }
@description('The target regions where the Image Version is going to be replicated to. It uses the default settings of the version.')
@allowed([
  'eastus'
  'eastus2'
  'southcentralus'
  'westus2'
  'westus3'
  'australiaeast'
  'southeastasia'
  'northeurope'
  'swedencentral'
  'uksouth'
  'westeurope'
  'centralus'
  'southafricanorth'
  'centralindia'
  'eastasia'
  'japaneast'
  'koreacentral'
  'canadacentral'
  'francecentral'
  'germanywestcentral'
  'norwayeast'
  'polandcentral'
  'switzerlandnorth'
  'uaenorth'
  'brazilsouth'
  'centraluseuap'
  'qatarcentral'
  'brazilus'
  'eastusstg'
  'northcentralus'
  'westus'
  'jioindiawest'
  'eastus2euap'
  'southcentralusstg'
  'westcentralus'
  'southafricawest'
  'australiacentral'
  'australiacentral2'
  'australiasoutheast'
  'japanwest'
  'jioindiacentral'
  'koreasouth'
  'southindia'
  'westindia'
  'canadaeast'
  'francesouth'
  'germanynorth'
  'norwaywest'
  'switzerlandwest'
  'ukwest'
  'uaecentral'
  'brazilsoutheast'
])
param defaultTargetRegions array = [
  'westeurope'
]

@description('Specifies the storage account type to be used to store the image')
@allowed([
  'Premium_LRS'
  'Standard_LRS'
  'Standard_ZRS'
])
param storageAccountType string = 'Standard_LRS'

@description('The number of replicas of the Image Version to be created per region. This property would take effect for a region when regionalReplicaCount is not specified.')
@minValue(1)
param replicaCount int = 1

@description('Specifies the mode to be used for replication.')
@allowed([
  'Full'
  'Shallow'
])
param replicationMode string = 'Full'

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Resource location')
param location string = resourceGroup().location

var targetRegions = [
  for region in defaultTargetRegions: {
    name: region
  }
]
var unionTargetRegions = union(targetRegions, customTargetRegions)

resource gallery 'Microsoft.Compute/galleries@2022-03-03' existing = {
  name: galleryName
}

resource galleryImage 'Microsoft.Compute/galleries/images@2022-03-03' existing = {
  name: imageName
  parent: gallery
}

@description('https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries/images/versions?pivots=deployment-language-bicep')
resource galleryName_imageDefinitionName_version 'Microsoft.Compute/galleries/images/versions@2022-03-03' = {
  name: version
  parent: galleryImage
  location: location
  tags: tags
  properties: {
    publishingProfile: {
      storageAccountType: storageAccountType
      replicaCount: replicaCount
      targetRegions: unionTargetRegions
      excludeFromLatest: excludedFromLatest
      replicationMode: replicationMode
    }
    storageProfile: union(
      {
        osDiskImage: union(
          {
            hostCaching: osDiskHostCaching
          },
          empty(sourceStorageAccountId) || empty(sourceStorageAccountVhdUri)
            ? {}
            : {
                source: {
                  storageAccountId: sourceStorageAccountId
                  uri: sourceStorageAccountVhdUri
                }
              }
        )
      },
      empty(sourceId)
        ? {}
        : {
            source: {
              id: sourceId
            }
          }
    )
  }
}
