/*
.SYNOPSIS
Create an azure compute gallery
.DESCRIPTION
Create an azure compute gallery.
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

</pre>
<p>Create a gallery that can host image and a application definition</p>
.LINKS
- [Bicep Microsoft.Compute galleries](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries?pivots=deployment-language-bicep)
*/

@description('Gallery Name')
@minLength(1)
@maxLength(80)
param galleryName string

@description('The description of this Shared Image Gallery resource. This property is updatable.')
param galleryDescription string = ''

@description('Enables soft-deletion for resources in this gallery, allowing them to be recovered within retention time.')
param isSoftDeleteEnabled bool = false

@description('This property allows you to specify the permission of sharing gallery')
@allowed([
  'Private'
  'Groups'
  'Community'
])
param permissions string = 'Private'

@description('Information of community gallery if current gallery is shared to community. [See docs](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries?pivots=deployment-language-bicep#communitygalleryinfo).')
param communityGalleryInfo object = {
  eula: ''
  publicNamePrefix: ''
  publisherContact: ''
  publisherUri: ''
}

@description('Resource location')
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

resource gallery 'Microsoft.Compute/galleries@2022-03-03' = {
  name: galleryName
  location: location
  tags: tags
  properties: union(
    {
      description: galleryDescription
      identifier: {}
    },
    permissions != 'Private'
      ? {
          sharingProfile: {
            communityGalleryInfo: communityGalleryInfo
            permissions: permissions
          }
        }
      : {},
    isSoftDeleteEnabled
      ? {
          softDeletePolicy: {
            isSoftDeleteEnabled: isSoftDeleteEnabled
          }
        }
      : {}
  )
}

@description('Identifier of the gallery')
output galleryId string = gallery.id

@description('Name of the gallery')
output galleryName string = gallery.name
