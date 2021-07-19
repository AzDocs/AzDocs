[[_TOC_]]

# Application Gateway
When we started this documentation, we promised eachother to not write anything about individual components. However, since we've chosen to only use the Application Gateway (AppGw) as our edge layer component, we decided it is a good idea to say something revolving this component and it's complexity (and our automation in this). Creating an AppGw is easy, but mastering one is a little harder. We've chosen to create our own SSL Policies for our AppGw's and to automate the hell out of this component due to its complexity (see [the create entrypoint script](../../../../src/AzDocs.Common/public/AppGateway-Helper-Functions.ps1) if you want to know what i'm talking about).

## Creating an Application Gateway
Creating an application gateway is easy. Simply use the [Create Application Gateway](/Azure/Azure-CLI-Snippets/Application-Gateway/Create-Application-Gateway) script to create the App Gateway.

OPTIONAL: Enable DDoS protection to your VNet (the script can be found in the Networking folder). NOTE: This costs ~4k USD.

## SSL Policy
The next thing you want to do is setup secure SSL policies. By default the Gateway will support TLS 1.2 with a set of ciphers (predefined profile AppGwSslPolicy20170401S). We've found that this default set of ciphers isn't the strongest option available. We've set our Gateway to the following:

Minimal TLS Version: `1.2`

Ciphers in order:
- `TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384` <-- Strong
- `TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256` <-- Strong
- `TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384` <-- Strong
- `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256` <-- Strong
- `TLS_DHE_RSA_WITH_AES_256_GCM_SHA384` <-- Strong
- `TLS_DHE_RSA_WITH_AES_128_GCM_SHA256` <-- Strong
- `TLS_RSA_WITH_AES_256_GCM_SHA384` <-- Fallback. Strong enough, but mainly for backwards compatibility
- `TLS_RSA_WITH_AES_128_GCM_SHA256` <-- Fallback. Strong enough, but mainly for backwards compatibility

The strong ciphers are supported by mainly all devices since 2014.

If you are still using Windows Server 2012 R2 machines, follow [this link](https://docs.microsoft.com/nl-nl/mem/configmgr/core/plan-design/security/enable-tls-1-2-client) to make TLS 1.2 work with this OS. To be able to reach Azure through the application gateways, you will need to add support for TLS 1.2 to Windows Server 2012 R2 machines.

Use the [Set-Application-Gateway-SSLTLS-Settings.ps1](../../../../src/Application-Gateway/Set-Application-Gateway-SSLTLS-Settings.ps1) script to set the right SSL & TLS settings for your Application Gateway.

## Creating Entrypoints
Creating entrypoints can be done using [Create Application Gateway Entrypoint for ContainerInstance](/Azure/Azure-CLI-Snippets/Application-Gateway/Create-Application-Gateway-Entrypoint-for-ContainerInstance) (Azure Container Instances) or [Create Application Gateway Entrypoint for DomainName](/Azure/Azure-CLI-Snippets/Application-Gateway/Create-Application-Gateway-Entrypoint-for-DomainName) (AppServices, FunctionApps). These scripts will more or less do the following for you:
- Handle naming for you based on the ingress domain name you are using
- Handle permissions, identities, authentication & authorization between the Application Gateway & Keyvault
- Handle the certificate (uploading in keyvault,  linking to the application gateway & setting it in your HTTPS listener)
- Update the certificate if you pass a renewed certificate in the keyvault, AppGw & HTTPS listener
- Create the following components for you (again automatically named based on the ingress domainname): Backendpool, Healthprobe, HTTP Setting, HTTPS Listener, routing rules a HTTP listener with autoredirect to HTTPS.
- The script will make sure everything is setup correctly & that your backend is reachable with a healthcheck. Your pipeline will fail if the backend is not reachable.

## Security Headers Automation
*Make sure you followed the information from [Creating Entrypoints](#creating-entrypoints) first.*

By default the Application Gateway will not modify any headers. However, to create a secure environment for your end-users, you want to make sure a few security headers are in place. We've created a script which sets some sensible yet strict security headers in the Application Gateway. With this you can always count on a set of basic, yet important, backup headers from the Application Gateway. This means what if, for whatever reason, the developer forgets or omits to add one of the security headers, included in this script, to his page, the gateway will act as a backup and will override this header. If the developer does add the security header himself, the gateway will leave it untouched and pass the applications security header to the browser. You can choose to override each security header individually, where the ones you don't override will stay in place by the Application Gateway.

After using the script, the following headers will be set by the Application Gateway:

> NOTE: The Content-Security-Policy can be overriden with your own default value through the script.

| Action                                             | Header name                        | Default Value                          |
|----------------------------------------------------|------------------------------------|----------------------------------------|
| Set CSP Policy if missing;                         | Content-Security-Policy;           | "default-src 'self'"          |
| Set X-Frame-Options if missing;                    | X-Frame-Options;                   | "DENY"                                 |
| Set X-Content-Type-Options if missing;             | X-Content-Type-Options;            | "nosniff"                              |
| Set X-Permitted-Cross-Domain-Policies if missing;  | X-Permitted-Cross-Domain-Policies; | "none"                                 |
| Set Referrer-Policy if missing;                    | Referrer-Policy;                   | "no-referrer"                          |
| Set Strict-Transport-Security if missing;          | Strict-Transport-Security;         | "max-age=31536000 ; includeSubDomains" |
| Set Permissions-Policy if missing;                 | Permissions-Policy;                | "microphone=(), camera=()"             |

The following headers will be removed automatically by the Application Gateway:

| Action                                             | Header name                        |
|----------------------------------------------------|------------------------------------|
| Remove Server header;                              | Server                             |
| Remove X-Powered-By header;                        | X-Powered-By                       |
| Remove X-AspNet-Version header;                    | X-AspNet-Version                   |


Use the [Add-Application-Gateway-Security-Headers.ps1](../src/Application-Gateway/Add-Application-Gateway-Security-Headers.ps1) script to add the security headers to your ingresses.
