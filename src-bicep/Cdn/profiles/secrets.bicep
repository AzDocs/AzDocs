/*
.SYNOPSIS
Creating a secret in an existing Front Door Cdn profile which represents a certificate.
.DESCRIPTION
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
</pre>
<p>Creates a representation of a certificate in the form of a secret coming from a keyvault and link it in an existing Frontdoor Cdn Profile.</p>
.INFO
- Check 'Allow trusted Microsoft services to bypass this firewall' for a Keyvault that uses a firewall.
- A Self Signed certificate is not permitted for Bring Your Own Certificate
.LINKS
- [Bicep Microsoft.Cdn profiles endpoint groupname](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/secrets?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of the secret to create')
param frontDoorSecretName string

@description('The name of the existing Front Door Cdn profile')
param frontDoorName string

@description('''
The type of secret to create. Depending on the type, different parameters are required.
see [docs](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/secrets?pivots=deployment-language-bicep).
''')
param secretParameters object = {}


// ===================================== Resources =====================================
@description('The existing FrontDoor Cdn profile to use.')
resource CDNProfile 'Microsoft.Cdn/profiles@2022-11-01-preview' existing = {
  name: frontDoorName
}

@description('The secret to create in the FrontDoor Cdn profile.')
resource frontDoorSecret 'Microsoft.Cdn/profiles/secrets@2022-11-01-preview' = {
  parent: CDNProfile
  name: frontDoorSecretName
  properties: {
    parameters: secretParameters
  }
}

@description('The resource id of the secret created in the FrontDoor Cdn profile.')
output secretId string = frontDoorSecret.id
@description('The name of the secret created in the FrontDoor Cdn profile.')
output secretName string = frontDoorSecret.name
