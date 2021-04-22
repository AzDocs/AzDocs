[[_TOC_]]

# Introduction
Welcome on the azure documentation site of the Azure Platform Provisioning scripts (AzDocs).

The goal is to have snippets for creating Azure resources that are secure & compliant to the highest level of requirements.

Please note that this is a **Work In Progress** effort. Multiple companies are currently backing, contributing & using this for their production environments.

[Azure CLI](/Azure/Azure-CLI-Snippets)

# Why use this boilerplate
The idea behind this boilerplate is that everyone wants a secure stack without having to do the whole compliancy & security setup yourself. A good example is that in 2021 it's not acceptable that you use non SSL HTTP connections. This means that, in all the scripts we write, HTTPS will be enforced. You get these general sense choices for free in your application stack. Another good example is that we strive to enable full logging for all components to a central Log Analytics Workspace, so that if you need logging at some point, you will have it.

> TLDR; you don't want to figure out everything by yourself :).

# Core Concepts / Architecture
There are a few core concept in this boilerplate which are essential for a successful implementation. In this chapter those core concepts are described.
 - CICD is leading --> Your platform should be able to burn and we should be good to go.
    - This means your resources, variables & secrets etc. are provisioned from your CICD pipelines towards the Azure platform.
 - Backwards compatible; scripts which are created should not break previous versions unless it's absolutely not possible to create backwards compatibility.
 - You want to create a resourcegroup per application stack
    - This means your API, portal, database etc. which are needed for running your application are all in the same resourcegroup, but another application stack is in it's own resource group.
 - There is one or more shared resourcegroups for shared components
    - For example if you use an application gateway to expose multiple application stacks to the internet, this will be in a shared RG with for example the VNET which is shared between your platforms.
    - Those shared resources are mainly done for cost reductions. You dont want to host an Application Gateway for each application because it's simply unnecessary.

## Resource naming best practises
Make sure that when you start using this boilerplate you come up with a good naming convention for your implementation. There are a few general rules of thumb which you can follow to get a good naming scheme.
 - Use the same naming structure for all of your resourcegroups. For example `<Teamname>-<ApplicationStackName>-<EnvironmentName>` or simply ` <ApplicationStackName>-<EnvironmentName>`.
 - It's extremely recommended to use the Environment name in your resource names for easy understanding & easy automation.
    - In Azure DevOps Release pipelines you can use the `$(Release.EnvironmentName)` to use the current stage name for spinning up resources in your Azure platform. This means that if you name your stages `dev`, `acc` and `prd` that you can use `$(Release.EnvironmentName)` in your resources names which will cause the resources to include those `dev`, `acc` and `prd` references.
 - If you have only 1 instance of a specific resourcetype (now and in the future) in each resourcegroup, its recommended to just simply name the resource the same as your resourcegroup.
    - For example: you want 1 application insights resource per application stack. Just give the same name to the appinsights and the resourcegroup for simplicity sake.

## Zero trust architecture
TODO

## SaaS --> PaaS --> IaaS
TODO

## Azure CLI unless
TODO

## Pipelines
TODO

### Service Principal Setup
TODO

# Which components are available & when to use them?
TODO

# Prerequisites
TODO

# How to use the scripts
TODO

# Guidelines for creating new scripts
TODO

## Coding Convention
TODO

### Naming
TODO

# How to keep your repositories in sync with upstream
TODO

# Networking
There are different ways of doing networking within Azure. By default resources will either be public or have an IP Whitelist. By design we don't want to use public resources or use IP whitelists because of the potential insecurities in this. We made the choice to use two different ways of supporting connectivity; VNet whitelisting & Private Endpoint.
The general rule of thumb should be to use VNet whitelisting where applicable. If thats not possible we use private endpoints. If that is unavailable aswell, we fallback to public access with plain IP whitelists.
Another rule of thumb is to keep in mind that we don't want to use methods of vnet connectivity where we have to sacrifice a whole subnet due to a delegation (vnet integration for appservices have this problem) unless there is no other way. The reason for this is that this costs a lot of private IP's. If you have a tight private IP space, don't waste them on delegations :).

## VNet whitelisting
As mentioned, VNet whitelisting is the desired way of connecting your resources within Azure. The description we'd like to use is that VNet whitelisting means you allow a subnet in your VNet to connect to your Azure resource. Microsoft does some nice public/private network translation magic for this. The benefit is that you can choose any vnet/subnet combination to be whitelisted without the vnets actually [peered](https://docs.microsoft.com/en-US/azure/virtual-network/virtual-network-peering-overview), where private endpoints will limit you to stuff which is in the same vnet as the private endpoint. Technically this means that your public endpoint will be enabled. However Microsoft allows you to define which private resources (resources from within a vnet) can reach this public endpoint. By default this method will block all public traffic to the Azure resource, which is desired in our eyes.

## Private Endpoints
We see [private endpoints](https://docs.microsoft.com/en-US/azure/private-link/private-endpoint-overview) as a fallback scenario for resources that do not support VNet whitelisting. Also this is the main way of connecting from on-premises to Azure resources. The idea behind private endpoint is that your Azure Resource will get a "leg" for incoming traffic in a subnet within your vnet. Also microsoft offers the option for the DNS entry of your resource to be changed from the public resource IP to the private endpoint ip.

Example:
If you have a SQL server with the name `testserver`, you will get a DNS record out of the box which looks like `testserver.database.windows.net` which resolves to a public ip, lets say `50.20.30.40`. It means that whenever you connect to your SQL Database you will set the connectionstring to `testserver.database.windows.net` and your application will resolve this to `50.20.30.40`.
Whenever we enable the private endpoint feature, microsoft will actually create a new DNS record `testserver.privatelink.database.windows.net` with your private ip, lets say `10.0.0.5`. The next step Microsoft does for you, is that within your VNet context the "public" DNS entry `testserver.database.windows.net` will resolve to a CNAME `testserver.privatelink.database.windows.net` which in its turn resolves to `10.0.0.5`. So within your VNet you will start connecting on a private IP, which allows you to completely disable the public endpoint if desired. If you resolve `testserver.database.windows.net` from outside your VNet, it will keep resolving to `50.20.30.40` (since you don't have connectivity to the private endpoint there).

> NOTE: One of the funny things we noticed is that for AppServices & functions in particular, whenever you add a private endpoint you are unable to get public access working even adding public ip's to your whitelist. You can fix this by using an [Application Gateway](https://docs.microsoft.com/en-US/azure/application-gateway/overview) in front of this App Service/FunctionApp with private endpoint.

### DNS
Whenever you want to use private endpoint there is a few things to know. The first of these things is that you will need a non-default DNS server to resolve your private endpoint DNS entries. The default DNS server from Azure will keep returning the public IP, which is undesired for your private endpoint situation. This means that you will need to define the "private endpoint dns server" in your Virtual Network as being the DNS server to use. The address to resolve your privatelink DNS entries from is `168.63.129.16`.

> OPTIONAL: If you do not want to set this DNS server for the whole VNet, there are ways to set this on a resourcelevel. For example adding `WEBSITE_DNS_SERVER=168.63.129.16` to your [application settings](https://docs.microsoft.com/en-us/azure/app-service/configure-common) in your App Service does this.

### Route your traffic through the VNet
Another thing to know when you use private endpoints is that you need to make sure your resources will route all traffic through the VNet. For example: you need to add an [application setting](https://docs.microsoft.com/en-us/azure/app-service/configure-common) to your AppService that defines that you route this traffic through your VNet integration towards the VNet. For AppServices you can do this adding `WEBSITE_VNET_ROUTE_ALL=1` to your application settings.

### How to deploy to private resources: Azure DevOps Private Agents
A challenge you will be facing when you use private endpoints, is that your Azure DevOps hosted agents are unable to connect to your (now) private resource. This means that, for example, an application deploy to an appservice or adding a file to your storage account will fail. This means that you will have to host a private Azure DevOps agent inside your VNet to connect through the private endpoints. 

## On-premises networks
There are several ways of connecting your resources in azure from & to on-premises resources:
 - Azure ExpressRoute
 - Site-to-site VPN using the Virtual Network Gateway
 - Hybrid connections
Currently this stack has been tested using the ExpressRoute & the Virtual Network Gateway.

When connecting your Azure platform to your onpremises network, make sure that you DO NOT have any overlapping IP's.

We use two flavours of connecting from on-premises resources to Azure:
 - HTTPS traffic --> We make sure to put an Application Gateway in front of the HTTP resource and connect the onprem resources via this Application Gateway.
 - Other resources like SQL databases, storage account, redis cache etc --> You will need to create a private endpoint for your Azure Resource which will be used to connect to from on-premises. This means that your on-premises datacenter has to understand that the DNS entry for those resources don't resolve to the public ip of the azure resource, but the private ip of the private endpoint.

# Logging
TODO

# Monitoring
TODO

# TODO
TLS 1.2 support for App Gateways in older onprem OS's: https://docs.microsoft.com/nl-nl/mem/configmgr/core/plan-design/security/enable-tls-1-2-client