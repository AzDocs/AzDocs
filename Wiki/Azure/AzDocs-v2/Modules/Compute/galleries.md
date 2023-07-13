# galleries

Target Scope: resourceGroup

## Synopsis
Create an azure compute gallery

## Description
Create an azure compute gallery.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| galleryName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | Gallery Name |
| galleryDescription | string | <input type="checkbox"> | None | <pre>''</pre> | The description of this Shared Image Gallery resource. This property is updatable. |
| isSoftDeleteEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Enables soft-deletion for resources in this gallery, allowing them to be recovered within retention time. |
| permissions | string | <input type="checkbox"> | `'Private'` or `'Groups'` or `'Community'` | <pre>'Private'</pre> | This property allows you to specify the permission of sharing gallery |
| communityGalleryInfo | object | <input type="checkbox"> | None | <pre>{<br>  eula: ''<br>  publicNamePrefix: ''<br>  publisherContact: ''<br>  publisherUri: ''<br>}</pre> | Information of community gallery if current gallery is shared to community. [See docs](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries?pivots=deployment-language-bicep#communitygalleryinfo). |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Resource location |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| galleryId | string | Identifier of the gallery |
| galleryName | string | Name of the gallery |
## Examples
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

## Links
- [Bicep Microsoft.Compute galleries](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries?pivots=deployment-language-bicep)


