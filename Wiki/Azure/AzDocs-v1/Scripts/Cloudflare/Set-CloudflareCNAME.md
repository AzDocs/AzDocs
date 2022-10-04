[[_TOC_]]

# Description

This snippet will create a CNAME record in the Cloudflare API for you. You can enable or disable the proxy feature from Cloudflare.

If you are using this to expose your AppService, make sure to run this script twice. You will need a proxied record for your website,for example `mysubdomain.mydomain.com` which leads to `mywebsite.azurewebsites.net`. Next to this you will also need a, so called, "awverify" record so Azure can verify you are the owner. With the example just mentioned, you will need a non-proxied cname from `awverify.mysubdomain.mydomain.com` to `awverify.mywebsite.azurewebsites.net`. It is important that this record will NOT be proxied or it will fail.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter          | Required                        | Example Value                                                        | Description                                                                                                                                                                                      |
| ------------------ | ------------------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| CloudflareApiToken | <input type="checkbox" checked> | `D3gS5jFcDzYjkELeh33q8KVHDtXdHKg3cruqeETc`                           | 40-character API token from Clouflare. Scope needs to be `All zones` and permissions should be set to `Zone:Read` & `DNS:Edit`                                                                   |
| RootDomain         | <input type="checkbox" checked> | `example.com`                                                        | The [top level domainname](https://en.wikipedia.org/wiki/Top-level_domain) (`example.com`)                                                                                                       |
| SubDomain          | <input type="checkbox">         | `mysubdomain`                                                        | The subdomain which you want to use for this record. This is optional. If you leave this blank, your root record will be updated. This field matches the `Name` field in the Cloudflare console. |
| CloudflareProxied  | <input type="checkbox" checked> | `$true`/`$false`                                                     | True if you want Cloudflare to act as a reverse proxy. False if you want DNS only.                                                                                                               |
| TargetCName        | <input type="checkbox" checked> | `mywebsite.azurewebsites.net`/`awverify.mywebsite.azurewebsites.net` | The target domainname where you want to send this DNS record to. This field matches the `Content` field in the Cloudflare console.                                                               |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Set Cloudflare CNAME"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Cloudflare/Set-CloudflareCNAME.ps1"
    arguments: "-CloudflareApiToken '$(CloudflareApiToken)' -RootDomain '$(RootDomain)' -SubDomain '$(SubDomain)' -CloudflareProxied '$(CloudflareProxied)' -TargetName '$(TargetCName)'"
```

# Code

[Click here to download this script](../../../../src/Cloudflare/Set-CloudflareCNAME.ps1)
