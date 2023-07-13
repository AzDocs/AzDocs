# images

Target Scope: resourceGroup

## Synopsis
Create an azure compute gallery image definition

## Description
Create an azure compute gallery image definition.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| imageName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | Name of the image definition. |
| galleryName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | Name of the gallery. |
| galleryDescription | string | <input type="checkbox"> | None | <pre>''</pre> | The description of this gallery image definition resource. This property is updatable. |
| architecture | string | <input type="checkbox"> | `'x64'` or `'Arm64'` | <pre>'x64'</pre> | The architecture of the image. Applicable to OS disks only. |
| hyperVGeneration | string | <input type="checkbox"> | `'V1'` or `'V2'` | <pre>'V2'</pre> | The hypervisor generation of the Virtual Machine. Applicable to OS disks only. Difference between V1 and v2 can be [found here](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/plan/should-i-create-a-generation-1-or-2-virtual-machine-in-hyper-v). |
| osState | string | <input type="checkbox"> | `'Generalized'` or `'Specialized'` | <pre>'Generalized'</pre> | This property allows the user to specify whether the virtual machines created under this image are 'Generalized' or 'Specialized'. |
| osType | string | <input type="checkbox"> | `'Linux'` or `'Windows'` | <pre>'Linux'</pre> | This property allows you to specify the type of the OS that is included in the disk when creating a VM from a managed image. |
| endOfLifeDate | string | <input type="checkbox"> | None | <pre>''</pre> | The end of life date of the gallery image definition. This property can be used for decommissioning purposes. This property is updatable. Should be in the following format: "DD-MM-YYYY". |
| identifierOffer | string | <input type="checkbox" checked> | Length between 0-64 | <pre></pre> | The name of the gallery image definition offer. |
| identifierPublisher | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the gallery image definition publisher. |
| identifierSku | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the gallery image definition SKU.	 |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Resource location |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| galleryImageId | string | Id of the gallery image definition |
| galleryImageName | string | Name of the gallery image definition |
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

## Links
- [Bicep Microsoft.Compute galleries](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries?pivots=deployment-language-bicep)<br>
- [Bicep Microsoft.Compute galleries/images](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries/images?pivots=deployment-language-bicep)


