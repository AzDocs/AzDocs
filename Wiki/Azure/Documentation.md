[[_TOC_]]

# Introduction to AzDocs
Welcome on the AzDocs (Azure Documentation) Wiki.

The AzDocs are a boilerplate & knowledgebase to get you and your team started with Azure in no time while keeping Security & Compliancy in place. The goal is to have snippets for creating Azure resources that are secure & compliant to the highest level of requirements along with examples and best practices. This library does have a bias about certain things which, in our experience, gets your team started faster.

> NOTE: This is a **Work In Progress** effort. Multiple (larger and smaller) companies are currently backing, contributing & using this for their business critical production environments.

Go straight to the scripts: [Azure CLI](/Azure/Azure-CLI-Snippets)

# Why use this boilerplate
The idea behind this boilerplate is that everyone wants a secure stack without having to do the whole compliancy & security setup yourself. A good example is that in 2021 it's not acceptable that you use non SSL HTTP connections. This means that, in all the scripts we write, HTTPS will be enforced. You get these general sense choices for free in your application stack. Another good example is that we strive to enable full logging for all components to a central Log Analytics Workspace, so that if you need logging at some point, you will have it.

> TLDR; you don't want to figure out everything by yourself and build secure & compliant platforms :).

Another major reason/benefit to use this boilerplate is because we fixed Azure CLI in Azure DevOps Pipelines. By default, whenever a CLI statement crashes, your pipeline does not always break. We've wrapped all of our statements into the so called `Invoke-Executable` statement which manages this behaviour for you. Next to this huge benefit, it adds another huge benefit: logging. Don't you hate the way of logging within our pipelines? We do too! So we've improved the logging when using this boilerplate. Let me simply show you by a screenshot:

![AzDocs - Invoke Executable](../../wiki_images/azdocs_invoke_executable.png)

As you can see, all parameters get printed (secrets will be hidden ofcourse!) and and all actual CLI statements that are being done by the scripts are printed as well. This allows you to quickly debug & fix things going wrong in your pipelines!

And last but certainly not least: we've unified the way to enable debug information in your pipeline & Azure CLI. It's as simple as setting the default `System.Debug` to `true` in your pipeline variables. The `Invoke-Executable` wrapper will make sure the CLI statements will be appended with `--debug`!

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

## Resource naming best practises
Make sure that when you start using this boilerplate you come up with a good naming convention for your implementation. There are a few general rules of thumb which you can follow to get a good naming scheme.
- Use the same naming structure for all of your resourcegroups. For example `<Teamname>-<ApplicationStackName>-<EnvironmentName>` or simply ` <ApplicationStackName>-<EnvironmentName>`.
- It's extremely recommended to use the Environment name in your resource names for easy understanding & easy automation. This allows you to name all environments you create the same, except for the environment name. For example; a webapp will be called `myteam-myapp-dev` in dev and `myteam-myapp-prd` in production.
  - For YAML pipelines you can use `$(Environment.Name)` to use the current stage name for spinning up resources in your Azure platform. This means that if you name your stages `dev`, `acc` and `prd` that you can use `$(Environment.Name)` in your resources names which will cause the resources to include those `dev`, `acc` and `prd` references. In Azure DevOps (Classic) Release pipelines you can use `$(Release.EnvironmentName)` the same way.
- If you have only 1 instance of a specific resourcetype (now and in the future) in each resourcegroup, its recommended to just simply name the resource the same as your resourcegroup.
  - For example: you want 1 application insights resource per application stack. Just give the same name to the appinsights and the resourcegroup for simplicity sake.

## Zero trust architecture
We follow the [zero trust architecture](https://en.wikipedia.org/wiki/Zero_trust_security_model) principle. We recommend you doing the same thing. The biggest reason we are mentioning this is because we see in the field that a lot of companies think that IP whitelisting is enough security. In short: Do not IP whitelist a calling service and think this is plenty of security. Always check the requests on multiple levels.

## SaaS --> PaaS --> Containers --> IaaS
The ideology we follow is that we'd rather have SaaS, then PaaS, then Containers and last IaaS. Simply because of the lack of maintenance in SaaS and the heaviest maintenance in IaaS.
For the same reason we try to avoid containers, since we still need to update our runtimes in these (JRE/.NET/other base-image versions etc).

To be clear, we categorize apps as such:
- SaaS --> We don't have to manage anything. We simply use software from a 3rd party. The code & infra are not ours.
- PaaS --> We don't have to manage the platform (we don't do updates or maintenance on the infra), but we are in control over which features we use (For example: App Services). Also we are still responsible for our own code which runs on this managed platform. So we still need to update our dependencies in our software and keep the .NET version of our software up to date. NOTE: Support for those different .NET versions on the platform level are being managed by the PaaS provider, we simply have to select the right one.
- IaaS --> We have to manage some or all of the platform (we have to do updates & do maintenance on the infra) and we are responsible for our code (we still need to update & maintain dependencies & .net versions etc.).


## Azure CLI unless
In this boilerplate we investigated ARM templates, Azure PowerShell & Azure CLI. We choose to have the following order:
 1. Azure CLI
 2. Azure PowerShell
 3. ARM Templates

The reason for this is that Azure CLI is extremely simple to learn for new developers. This has currently been battle tested at multiple companies who all said CLI was the easiest to learn. We try to avoid ARM Templates because of 2 main reasons: it's the most complex & fiddly to work with and also the reusability of arm templates is suboptimal (yes we tried linked & nested templates but they don't suit our needs). Also ARM templates doesn't give us the freedom in making choices based on the user input. We use Azure PowerShell as a backup whenever CLI isn't cut for the task or the CLI version of the task is missing. There is no big reason against using Azure PowerShell other than the agreement we made to primarily do everything in Azure CLI.

## Identity Management within Azure
To avoid registering secrets & maintaining usernames & passwords ourselves, we chose to use managed identities (MI's) as much as possible. This basically means that if a resource supports using a MI, we will automatically enable this in the AzDocs. This also means, for example, you can grant your appservice MI permissions on your underlying data layer (storage accounts etc.). We recommend avoiding storing secrets & user information as much as possible.

There is a generic role assignment script which can assign roles on resources to your managed identity. You can find the script here: [Grant-Permissions-to-ManagedIdentity-on-Resource.ps1](../../src/Roles/Grant-Permissions-to-ManagedIdentity-on-Resource.ps1)

## Pipelines
The idea is that one or more of the scripts from this library will form your pipeline which actually spins up the infra for your software. Please refer to [How to use the scripts](/Azure/Documentation/How-to-use-the-scripts) for more information.

### Service Principal Setup
To deploy from Azure DevOps you need a service connection to your Azure environment. There are multiple authentication/authorization options. We created this using a service principal (manual). We recommend creating this first in Azure and assigning it the `Owner` for your subscription (make at least one service principal per subscription).
Find the documentation on how to create service principals & assign roles [here](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#register-an-application-with-azure-ad-and-create-a-service-principal).

# Prerequisites before starting with this boilerplate
- An Azure DevOps instance (you are probably reading this inside one right now).
- One or more azure subscriptions

# [Recommended Architecture](/Azure/Documentation/Recommended-Architecture)
*Please click the above link to go to this chapter*

# [Which components are available & when to use them?](/Azure/Documentation/Which-components-are-available-and-when-to-use-them)
*Please click the above link to go to this chapter*

# [Setup Azure DevOps & GIT](/Azure/Documentation/Setup-Azure-DevOps-and-GIT)
*Please click the above link to go to this chapter*

# [How to use the scripts](/Azure/Documentation/How-to-use-the-scripts)
*Please click the above link to go to this chapter*

# [Guidelines for creating new scripts](/Azure/Documentation/Guidelines-for-creating-new-scripts)
*Please click the above link to go to this chapter*

# [Application Gateway](/Azure/Documentation/Application-Gateway)
*Please click the above link to go to this chapter*

# [Networking](/Azure/Documentation/Networking)
*Please click the above link to go to this chapter*

# [Logging & Monitoring](/Azure/Documentation/Logging-and-monitoring)
*Please click the above link to go to this chapter*

# [Clearing unintended whitelists](/Azure/Documentation/Clearing-unintended-whitelists)
*Please click the above link to go to this chapter*