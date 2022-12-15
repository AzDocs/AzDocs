[[_TOC_]]

# Core Concepts

There are a few core concept in this boilerplate which are essential for a successful implementation. In this chapter those core concepts are described.

- CICD is leading --> The platform in Azure should be able to get deleted at all times and you should still be good to go.
  - This means your resources, variables & secrets etc. are provisioned from your CICD pipelines towards the Azure platform.
  - Ofcourse the exception is persistent data. You should always make backups for data you can't afford to lose.
- Backwards compatible; scripts which are created should not break previous versions unless it's absolutely not possible to create backwards compatibility.
- You want to create a resourcegroup per application stack
  - This means your API, portal, database etc. which are needed for running your application are all in the same resourcegroup, but another application stack is in it's own resource group.
- There are one or more shared resourcegroups for shared components
  - For example if you use an application gateway to expose multiple application stacks to the internet, this will be in a shared ResourceGroup (RG) with for example the VNET which is shared between your platforms.
  - Those shared resources are mainly done for cost reductions. You dont want to host an Application Gateway for each application because it's simply unnecessary.
- Any HTTPS service exposed outside of Azure is exposed through an Azure Application Gateway. This is also true for services which are being exposed to your on-premises network. The reason is that the Application Gateway has some extra security measures in place which reduces your attack surface. This complies with the [Zero trust architecture](#zero-trust-architecture).

## Zero trust architecture

We follow the [zero trust architecture](https://en.wikipedia.org/wiki/Zero_trust_security_model) principle. We recommend you doing the same thing. The biggest reason we are mentioning this is because we see in the field that a lot of companies think that IP whitelisting is enough security. In short: Do not IP whitelist a calling service and think this is plenty of security. Always check the requests on multiple levels.

## SaaS --> PaaS --> Containers --> IaaS

The ideology we follow is that we'd rather have SaaS, then PaaS, then Containers and last IaaS. Simply because of the lack of maintenance in SaaS and the heaviest maintenance in IaaS.
For the same reason we try to avoid containers, since we still need to update our runtimes in these (JRE/.NET/other base-image versions etc).

To be clear, we categorize apps as such:

- SaaS --> We don't have to manage anything. We simply use software from a 3rd party. The code & infra are not ours.
- PaaS --> We don't have to manage the platform (we don't do updates or maintenance on the infra), but we are in control over which features we use (For example: App Services). Also we are still responsible for our own code which runs on this managed platform. So we still need to update our dependencies in our software and keep the .NET version of our software up to date. NOTE: Support for those different .NET versions on the platform level are being managed by the PaaS provider, we simply have to select the right one.
- IaaS --> We have to manage some or all of the platform (we have to do updates & do maintenance on the infra) and we are responsible for our code (we still need to update & maintain dependencies & .net versions etc.).

## Identity Management within Azure

To avoid registering secrets & maintaining usernames & passwords ourselves, we chose to use managed identities (MI's) as much as possible. This basically means that if a resource supports using a MI, we will automatically enable this in the AzDocs. This also means, for example, you can grant your appservice MI permissions on your underlying data layer (storage accounts etc.). We recommend avoiding storing secrets & user information as much as possible.

There is a generic role assignment script which can assign roles on resources to your managed identity. You can find the script here: [Grant-Permissions-to-ManagedIdentity-on-Resource.ps1](../../src/Roles/Grant-Permissions-to-ManagedIdentity-on-Resource.ps1)

### Service Principal Setup

To deploy from Azure DevOps you need a service connection to your Azure environment. There are multiple authentication/authorization options. We created this using a service principal (manual). We recommend creating this first in Azure and assigning it the `Owner` for your subscription (make at least one service principal per subscription).
Find the documentation on how to create service principals & assign roles [here](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#register-an-application-with-azure-ad-and-create-a-service-principal).

# Prerequisites before starting with this boilerplate

- An Azure DevOps instance (you are probably reading this inside one right now).
- One or more azure subscriptions

# [Recommended Architecture](/Azure/General-Documentation/Recommended-Architecture)

_Please click the above link to go to this chapter_

# [Application Gateway](/Azure/General-Documentation/Application-Gateway)

_Please click the above link to go to this chapter_

# [Networking](/Azure/General-Documentation/Networking)

_Please click the above link to go to this chapter_

# [Logging & Monitoring](/Azure/General-Documentation/Logging-and-monitoring)

_Please click the above link to go to this chapter_

# [Deprovisioning](/Azure/General-Documentation/Deprovisioning)

_Please click the above link to go to this chapter_
