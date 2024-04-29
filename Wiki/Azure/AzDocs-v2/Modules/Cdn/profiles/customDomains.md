# customDomains

Target Scope: resourceGroup

## Synopsis
Create a custom domain in an existing frontdoor CDN profile.

## Description
Create a custom domain in an existing frontdoor CDN profile.<br>
<pre><br>
module customdomain 'br:contosoregistry.azurecr.io/cdn/profiles/customDomains.bicep' = {<br>
    name: format('{0}-{1}', take('${deployment().name}', 51), 'customdomain')<br>
  params: {<br>
    customDomainName: 'my.perfect.site.company.org'<br>
    frontDoorName: frontDoorProfile.outputs.frontDoorName<br>
    customDomainCertificateType: 'CustomerCertificate'<br>
    frontDoorSecretName: frontdoorsecret.outputs.secretName<br>
  }<br>
}<br>
</pre><br>
<p>Creates a custom domain called my.perfect.site.company.org in an existing Frontdoor Cdn Profile.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| customDomainName | string | <input type="checkbox" checked> | None | <pre></pre> | The custom domain name to associate with your Front Door endpoint (for example, `www.contoso.com`) |
| frontDoorName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing Front Door Cdn profile. |
| frontDoorSecretName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the existing Front Door secret when used. |
| customDomainResourceName | string | <input type="checkbox"> | None | <pre>replace(customDomainName, '.', '-')</pre> | The name of the custom domain resource. This is a valid resource name and does not include periods. |
| customDomainCertificateType | string | <input type="checkbox" checked> | `'AzureFirstPartyManagedCertificate'` or `'CustomerCertificate'` or `'ManagedCertificate'` | <pre></pre> | The type of certificate. If the type "CustomerCertificate" is used, there must be a valid Secret Resource Reference Id.<br>Your domain will need to be validated before traffic is delivered to it. This can be done by creating a DNS TXT record with the name and value provided in the outputs. |
| azureDNSZoneId | string | <input type="checkbox"> | None | <pre>''</pre> | Resource reference to the Azure DNS zone |
| preValidatedCustomDomainResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | Resource reference to the Azure pre-validated domain |
| customDomainTLSVersion | string | <input type="checkbox"> | None | <pre>'TLS12'</pre> | The minimum TLS version required for this domain. TLS protocol version that will be used for Https.<br>Example:<br>'TLS10'<br>'TLS12' |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| customDomainValidationDnsTxtRecordName | string | The name of the DNS TXT record to create to validate the domain. This is only required if you are using Azure DNS. |
| customDomainValidationDnsTxtRecordValue | string | The value of the DNS TXT record to create to validate the domain. This is only required if you are using Azure DNS. |
| customDomainValidationExpiry | string | The expiration date of the DNS TXT record. This is only required if you are using Azure DNS. |
| customDomainId | string | The ID of the custom domain. |

## Links
- [Bicep Microsoft.Cdn profiles custom domain](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/customdomains?pivots=deployment-language-bicep)
