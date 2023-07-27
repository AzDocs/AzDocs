/*
.SYNOPSIS
Create an azure VM Image Version.
.DESCRIPTION
Create an  azure VM Image Version.
.EXAMPLE
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
param sourceId string

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
  'StandardSSD_LRS'
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


var targetRegions = [for region in defaultTargetRegions: {
  name: region
}]
var unionTargetRegions = union(targetRegions,customTargetRegions)


resource gallery 'Microsoft.Compute/galleries@2022-03-03' existing = {
  name: galleryName
}

resource galleryImage 'Microsoft.Compute/galleries/images@2022-03-03' existing = {
  name: imageName
  parent: gallery
}

resource galleryName_imageDefinitionName_version 'Microsoft.Compute/galleries/images/versions@2021-10-01' = {
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
    storageProfile: {
      source: {
        id: sourceId
      }
    }
  }
}
