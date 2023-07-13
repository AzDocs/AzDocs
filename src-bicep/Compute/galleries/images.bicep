/*
.SYNOPSIS
Create an azure compute gallery image definition
.DESCRIPTION
Create an azure compute gallery image definition.
.EXAMPLE
<pre>
module gallery 'br:contosoregistry.azurecr.io/compute/galleries:latest' = {
  name: 'Azure-gallery'
  params: {
    galleryName: 'gallery_name'
    galleryDescription: 'useless description that is nowhere shown.'
    location: location
    permissions: 'Private'
    isSoftDeleteEnabled: false
  }
}
module myImageDefinition 'br:contosoregistry.azurecr.io/compute/galleries/images:latest' = {
  name: 'azure-gallery-ubuntu22-image'
  params: {
    location:location
    galleryName: gallery.outputs.galleryName
    identifierOffer: 'ubuntuServer'
    identifierPublisher: 'my-company'
    identifierSku: '22_04-lts-gen2'
    imageName: 'ubuntu22'
    architecture: 'x64'
    osState: 'Generalized'
    osType: 'Linux'
    hyperVGeneration: 'V2'
    galleryDescription: 'vm images for Ubuntu 22.04 LTS (Jammy Jellyfish)'
  }
}

</pre>
<p>Create a gallery and a image definition for ubuntu 22.04</p>
.LINKS
- [Bicep Microsoft.Compute galleries](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries?pivots=deployment-language-bicep)
- [Bicep Microsoft.Compute galleries/images](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries/images?pivots=deployment-language-bicep)
*/

@description('Name of the image definition.')
@minLength(1)
@maxLength(80)
param imageName string

@description('Name of the gallery.')
@minLength(1)
@maxLength(80)
param galleryName string

@description('The description of this gallery image definition resource. This property is updatable.')
param galleryDescription string = ''

@description('The architecture of the image. Applicable to OS disks only.')
@allowed([
  'x64'
  'Arm64'
])
param architecture string = 'x64'

@description('The hypervisor generation of the Virtual Machine. Applicable to OS disks only. Difference between V1 and v2 can be [found here](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/plan/should-i-create-a-generation-1-or-2-virtual-machine-in-hyper-v).')
@allowed([
  'V1'
  'V2'
])
param hyperVGeneration string = 'V2'

@description('''
This property allows the user to specify whether the virtual machines created under this image are 'Generalized' or 'Specialized'.
''')
@allowed([
  'Generalized'
  'Specialized'
])
param osState string = 'Generalized'

@description('This property allows you to specify the type of the OS that is included in the disk when creating a VM from a managed image.')
@allowed([
  'Linux'
  'Windows'
])
param osType string = 'Linux'

@description('The end of life date of the gallery image definition. This property can be used for decommissioning purposes. This property is updatable. Should be in the following format: "DD-MM-YYYY".')
param endOfLifeDate string = ''

@description('The name of the gallery image definition offer.')
@maxLength(64)
param identifierOffer string

@description('The name of the gallery image definition publisher.')
param identifierPublisher string

@description('The name of the gallery image definition SKU.	')
param identifierSku string

@description('This is the gallery image definition identifier.')
var identifier = {
  offer: identifierOffer
  publisher: identifierPublisher
  sku: identifierSku
}

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

resource gallery 'Microsoft.Compute/galleries@2022-03-03' existing = {
  name: galleryName
}

resource galleryImage 'Microsoft.Compute/galleries/images@2022-03-03' = {
  name: imageName
  location: location
  tags: tags
  parent: gallery
  properties: {
    architecture: architecture
    description: galleryDescription
    endOfLifeDate: endOfLifeDate
    hyperVGeneration: hyperVGeneration
    identifier: identifier
    osState: osState
    osType: osType
  }
}

@description('Id of the gallery image definition')
output galleryImageId string = galleryImage.id

@description('Name of the gallery image definition')
output galleryImageName string = galleryImage.name
