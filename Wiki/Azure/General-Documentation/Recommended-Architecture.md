[[_TOC_]]

# Recommended Architecture

Of course you are free to do things as you see fit. However, this boilerplate has been tested in the following architecture. That is why we will recommend it this way.

![Recommended architecture](../../../wiki_images/Recommended_Architecture.png)

Key takeaways are:

- Always use an application gateway to reach HTTPS resources in Azure. This also goes for on-premises to Azure connections. This component has [DDoS mitigation](https://en.wikipedia.org/wiki/DDoS_mitigation) and a [web application firewall](https://en.wikipedia.org/wiki/Web_application_firewall).
- Always use managed identities (if possible. if not: use another way of auth) to handle authentication & authorization between layers & apps. This avoids apps calling the wrong data componenents etc.
- Always use VNet integration in combination with [VNet whitelisting](/Azure/General-Documentation/Networking#vnet-whitelisting) if possible. This is the recommended way of connecting apps within Azure. If this is not possible, use private endpoints and only if both the former are unavailable, start IP whitelisting.

This example architecture has a few extra's which you might not want or need:

- We added a DNS proxy. This is needed whenever you want to use private endpoints in Azure but already have an on-premises DNS server which you dont have control over. In case you have control over your on-premises DNS server, you want to configure it to having the Azure Private Endpoint DNS Server as it's upstream DNS server. There is however a limitation for this Azure Private Endpoint DNS server; You will need a (recursive) DNS proxy which redirects every DNS request to the azure [private endpoint dns](/Azure/General-Documentation/Networking#dns) server from inside your VNet. This is due to the fact that the Azure Private Endpoint DNS Server only accepts DNS requests from inside the VNet itself.
- We added an Azure DevOps private agent which does the deploying to your resources for you. Instructions for creating such a selfhosted pool agent can be found in [How to use the scripts](/Azure/AzDocs-v1/General-Documentation/How-to-use-the-scripts.md). This is to avoid the whitelist- & dewhitelist-actions for public ip's in your pipeline before you can deploy from a hosted agent. If you dont use this private agent, make sure you whitelist the hosted agent before deploying to the resources (deploy your app or files to storage for example), and remove them after you are done. The scripts needed for this are inside the CLI scripts (`Add-Network-Whitelist-for-<resourcename>.ps1` and `Remove-Network-Whitelist-for-<resourcename>.ps1`)
- Next to the public gateway (which is shown in gateway-subnet-1 in the image above), we also added a private facing gateway which will be used to leverage the applications from on-premises. We decided we always want to have an application gateway in front of our app layer, which is compliant with the [zero trust architecture](/Azure/General-Documentation#zero-trust-architecture).
