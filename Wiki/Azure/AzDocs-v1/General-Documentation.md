[[_TOC_]]

# Intoduction

In this folder you will find the general documentation for AzDocs v1.

# Resource naming best practises

Make sure that when you start using this boilerplate you come up with a good naming convention for your implementation. There are a few general rules of thumb which you can follow to get a good naming scheme.

- Use the same naming structure for all of your resourcegroups. For example `<Teamname>-<ApplicationStackName>-<EnvironmentName>` or simply ` <ApplicationStackName>-<EnvironmentName>`.
- It's extremely recommended to use the Environment name in your resource names for easy understanding & easy automation. This allows you to name all environments you create the same, except for the environment name. For example; a webapp will be called `myteam-myapp-dev` in dev and `myteam-myapp-prd` in production.
  - For YAML pipelines you can use `$(Environment.Name)` to use the current stage name for spinning up resources in your Azure platform. This means that if you name your stages `dev`, `acc` and `prd` that you can use `$(Environment.Name)` in your resources names which will cause the resources to include those `dev`, `acc` and `prd` references. In Azure DevOps (Classic) Release pipelines you can use `$(Release.EnvironmentName)` the same way.
- If you have only 1 instance of a specific resourcetype (now and in the future) in each resourcegroup, its recommended to just simply name the resource the same as your resourcegroup.
  - For example: you want 1 application insights resource per application stack. Just give the same name to the appinsights and the resourcegroup for simplicity sake.

# Azure CLI unless

In this boilerplate we investigated ARM templates, Azure PowerShell & Azure CLI. We choose to have the following order:

1.  Azure CLI
2.  Azure PowerShell
3.  ARM Templates

The reason for this is that Azure CLI is extremely simple to learn for new developers. This has currently been battle tested at multiple companies who all said CLI was the easiest to learn. We try to avoid ARM Templates because of 2 main reasons: it's the most complex & fiddly to work with and also the reusability of arm templates is suboptimal (yes we tried linked & nested templates but they don't suit our needs). Also ARM templates doesn't give us the freedom in making choices based on the user input. We use Azure PowerShell as a backup whenever CLI isn't cut for the task or the CLI version of the task is missing. There is no big reason against using Azure PowerShell other than the agreement we made to primarily do everything in Azure CLI.

# Pipelines

The idea is that one or more of the scripts from this library will form your pipeline which actually spins up the infra for your software. Please refer to [How to use the scripts](/Azure/AzDocs-v1/General-Documentation/How-to-use-the-scripts) for more information.

# [Which components are available & when to use them?](/Azure/AzDocs-v1/General-Documentation/Which-components-are-available-and-when-to-use-them)

_Please click the above link to go to this chapter_

# [Setup Azure DevOps & GIT](/Azure/AzDocs-v1/General-Documentation/Setup-Azure-DevOps-and-GIT)

_Please click the above link to go to this chapter_

# [How to use the scripts](/Azure/AzDocs-v1/General-Documentation/How-to-use-the-scripts)

_Please click the above link to go to this chapter_

# [Guidelines for creating new scripts](/Azure/AzDocs-v1/General-Documentation/Guidelines-for-creating-new-scripts)

_Please click the above link to go to this chapter_

# [Regression Tests](/Azure/AzDocs-v1/General-Documentation/Regression-Tests)

_Please click the above link to go to this chapter_

# [Clearing unintended whitelists](/Azure/AzDocs-v1/General-Documentation/Clearing-unintended-whitelists)

_Please click the above link to go to this chapter_
