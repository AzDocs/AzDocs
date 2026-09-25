# secrets

Target Scope: resourceGroup

## Synopsis
Creating a secret in an existing Front Door Cdn profile which represents a certificate.

## Description
Creating a secret in an existing Front Door Cdn profile which represents a certificate.
<pre>
module secret 'br:contosoregistry.azurecr.io/cdn/profiles/secrets.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 57), 'secret')
  params: {
    frontDoorName: frontDoorProfile.outputs.frontDoorName
    frontDoorSecretName: 'tst-secretsite-com-latest'
    secretParameters: {
      type: 'CustomerCertificate'
      secretSource: {
        id: '/subscriptions/<subscriptionid>/resourceGroups/<resourcegroupname>/providers/Microsoft.KeyVault/vaults/<keyvaultname>/secrets/tst-secretsite-com'
      }
      secretVersion: ''
      useLatestVersion: true
      subjectAlternativeNames: [
        'my.perfect.web.site.org'
      ]
    }
  }
  dependsOn: [
    MeInKeyvaultAccessPolicy
    frontDoorProfileKeyvaultAccess
  ]
}
</pre><br>
<p>Creates a representation of a certificate in the form of a secret coming from a keyvault and link it in an existing Frontdoor Cdn Profile.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| frontDoorSecretName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the secret to create |
| frontDoorName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing Front Door Cdn profile |
| secretParameters | object | <input type="checkbox"> | None | <pre>{}</pre> | The type of secret to create. Depending on the type, different parameters are required.<br>see [docs](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/secrets?pivots=deployment-language-bicep). |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| secretId | string | The resource id of the secret created in the FrontDoor Cdn profile. |
| secretName | string | The name of the secret created in the FrontDoor Cdn profile. |

## Links
- [Bicep Microsoft.Cdn profiles endpoint groupname](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/secrets?pivots=deployment-language-bicep)
