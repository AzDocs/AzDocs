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

![AzDocs - Invoke Executable](../wiki_images/azdocs_invoke_executable.png)

As you can see, all parameters get printed (secrets will be hidden ofcourse!) and and all actual CLI statements that are being done by the scripts are printed as well. This allows you to quickly debug & fix things going wrong in your pipelines!

And last but certainly not least: we've unified the way to enable debug information in your pipeline & Azure CLI. It's as simple as setting the default `System.Debug` to `true` in your pipeline variables. The `Invoke-Executable` wrapper will make sure the CLI statements will be appended with `--debug`!

# Core Concepts
There are a few core concept in this boilerplate which are essential for a successful implementation. In this chapter those core concepts are described.
- CICD is leading --> The platform in Azure should be able to get deleted at all times and you should still be good to go (this counts for everything except persistent data ofcourse).
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

## Azure CLI unless
In this boilerplate we investigated ARM templates, Azure PowerShell & Azure CLI. We choose to have the following order:
 1. Azure CLI
 2. Azure PowerShell
 3. ARM Templates

The reason for this is that Azure CLI is extremely simple to learn for new developers. This has currently been battle tested at multiple companies who all said CLI was the easiest to learn. We try to avoid ARM Templates because of 2 main reasons: it's the most complex & fiddly to work with and also the reusability of arm templates is suboptimal (yes we tried linked & nested templates but they don't suit our needs). Also ARM templates doesn't give us the freedom in making choices based on the user input. We use Azure PowerShell as a backup whenever CLI isn't cut for the task or the CLI version of the task is missing. There is no big reason against using Azure PowerShell other than the agreement we made to primarily do everything in Azure CLI.

## Identity Management within Azure
To avoid registering secrets & maintaining usernames & passwords ourselves, we chose to use managed identities (MI's) as much as possible. This basically means that if a resource supports using a MI, we will automatically enable this in the AzDocs. This also means, for example, you can grant your appservice MI permissions on your underlying data layer (storage accounts etc.). We recommend avoiding storing secrets & user information as much as possible.

There is a generic role assignment script which can assign roles on resources to your managed identity. You can find the script here: [Grant-Permissions-to-ManagedIdentity-on-Resource.ps1](../src/Roles/Grant-Permissions-to-ManagedIdentity-on-Resource.ps1)

## Pipelines
The idea is that one or more of the scripts from this library will form your pipeline which actually spins up the infra for your software. Please refer to [How to use the scripts](#how-to-use-the-scripts) for more information.

### Service Principal Setup
To deploy from Azure DevOps you need a service connection to your Azure environment. There are multiple authentication/authorization options. We created this using a service principal (manual). We recommend creating this first in Azure and assigning it the `Owner` for your subscription (make at least one service principal per subscription).
Find the documentation on how to create service principals & assign roles [here](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#register-an-application-with-azure-ad-and-create-a-service-principal).

# Recommended Architecture
Of course you are free to do things as you see fit. However, this boilerplate has been tested in the following architecture. That is why we will recommend it this way.

![Recommended architecture](../wiki_images/Recommended_Architecture.png)

Key takeaways are:
 - Always use an application gateway to reach HTTPS resources in Azure. This also goes for on-premises to Azure connections. This component has [DDoS mitigation](https://en.wikipedia.org/wiki/DDoS_mitigation) and a [web application firewall](https://en.wikipedia.org/wiki/Web_application_firewall).
 - Always use managed identities (if possible. if not: use another way of auth) to handle authentication & authorization between layers & apps. This avoids apps calling the wrong data componenents etc.
 - Always use VNet integration in combination with [VNet whitelisting](#vnet-whitelisting) if possible. This is the recommended way of connecting apps within Azure. If this is not possible, use private endpoints and only if both the former are unavailable, start IP whitelisting.
 - Split your networklayers at least into the edge (gateway) layer, app layer & data layer. Feel free to add more layers where you see fit. This more or less still counts for the resources you use VNet whitelisting for. You dont want to place something in your gateway subnet which you whitelist on your database directly. Also make sure to use [Network Security Groups](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview) to only allow the network connections you need between the layers.
 
This example architecture has a few extra's which you might not want or need:
 - We added a DNS proxy. This is needed whenever you want to use private endpoints in Azure but already have an on-premises DNS server which you dont have control over. In case you have control over your on-premises DNS server, you want to configure it to having the Azure Private Endpoint DNS Server as it's upstream DNS server. There is however a limitation for this Azure Private Endpoint DNS server; You will need a (recursive) DNS proxy which redirects every DNS request to the azure [private endpoint dns](#dns) server from inside your VNet. This is due to the fact that the Azure Private Endpoint DNS Server only accepts DNS requests from inside the VNet itself.
 - We added an Azure DevOps private agent which does the deploying to your resources for you. This is to eliminate the necessary whitelist- & dewhitelist-actions for public ip's in your pipeline before you can deploy from a hosted agent. If you dont use this private agent, make sure you whitelist the hosted agent before deploying to the resources (deploy your app or files to storage for example), and remove them after you are done. The scripts needed for this are inside the CLI scripts (`Add-Network-Whitelist-for-<resourcename>.ps1` and `Remove-Network-Whitelist-for-<resourcename>.ps1`)
 - Next to the public gateway (which is shown in gateway-subnet-1 in the image above), we also added a private facing gateway which will be used to leverage the applications from on-premises. We decided we always want to have an application gateway in front of our app layer, which is compliant with the [zero trust architecture](#zero-trust-architecture).

# Which components are available & when to use them?
Currently we've focussed on the following:
- Some basic network components
- Edge layer --> Application Gateway
- App Layer --> App Services, Function Apps & RedisCache
- Data layer --> Storage Accounts, Multiple relational databases & Keyvault.
- Supporting tools --> Application Insights, Azure Monitor & Azure Log Analytics Workspace
- Some experimental components --> App Configuration & Container Instances

For the most up to date list, please refer to the wikipages under [Azure CLI Snippets](/Azure/Azure-CLI-Snippets)

# Prerequisites
- An Azure DevOps instance (you are probably reading this inside one right now).
- One or more azure subscriptions

# Setup Azure DevOps & GIT
We are using a more-or-less complex GIT setup to fulfil our needs. The generic library you are watching right now should be sharable between companies at all times. This means that no company related data/rules should be implemented in this boilerplate. However, you probably have scripts & documentation which actually does contain logics or information of/for your company. To deal with this, we've created a 2-tier GIT repo. We created a company specific repo with this generic repo, in it, as a GIT submodule. This implies that commiting, pulling & pushing gets a little more complicated. To help you out, this paragraph should tell you how the workflow should work.

So in short:
 - Generic scripts which can be shared between companies --> Upstream/Generic repository
 - Company specific scripts which can't/shouldn't be shared --> Your company repository

## Create a new Azure DevOps Project
We recommend creating an `Azure Documentation` teamproject in your Azure DevOps instance.

1. On the main page click the New Project button in the top right corner.

![Main page](../wiki_images/azdo_create_new_teamproject_1.png)

2. Fill in the name of the new project. We use `Azure Documentation` for this.

![Creating the team project](../wiki_images/azdo_create_new_teamproject_2.png)

3. Create the project and you will be sent to it's landing page.

![Created the team project](../wiki_images/azdo_create_new_teamproject_7.png)

## Mirroring the upstream repo to your own Azure DevOps instance
First of all you need to mirror [the upstream github repo](https://github.com/RobHofmann/Azure.PlatformProvisioning) to your own Azure DevOps instance as a working repo. To do this, follow these steps:

1. Go to the `Repos` section of your TeamProject (in our case we created the teamproject Azure Documentation according to the [Create a new Azure DevOps Project](#create-a-new-azure-devops-project) section of this document).

2. Create a new repository.

![Create new repository](../wiki_images/azdo_create_new_teamproject_3.png)

3. For the name fill in `Upstream.Azure.PlatformProvisioning`. Make sure to disable the `Add a README` option and put `Add a .gitignore` to `none`. Hit the `Create` button.

![Create new repository](../wiki_images/azdo_create_new_teamproject_6.png)

4. In the repo screen, make sure to have your `Upstream.Azure.PlatformProvisioning` repo selected. Hit the `Import` button

![Mirror repo](../wiki_images/azdo_create_new_teamproject_8.png)

5. Import the `upstream` git repo from GitHub (Enter: https://github.com/RobHofmann/Azure.PlatformProvisioning.git).

![Mirror repo](../wiki_images/azdo_create_new_teamproject_4.png)

6. Give it a second to import the repo.

![Mirror repo](../wiki_images/azdo_create_new_teamproject_5.png)

7. You will now have an imported repository.

![Mirror repo](../wiki_images/azdo_create_new_teamproject_9.png)

## Expose the docs as a wiki in your DevOps project
This project also includes documentation next to the scripts. Even better: the document you are reading right now is inside this documentation :). You can publish these docs as a Wiki inside your own Azure DevOps teamproject. Here's how to do it:

1. Go to your teamproject and navigate to `Overview` --> `Wiki`.

![Expose your Docs as Wiki](../wiki_images/azdo_publish_docs_as_wiki_1.png)

2. Next, click the `Publish code as Wiki` button.

![Expose your Docs as Wiki](../wiki_images/azdo_publish_docs_as_wiki_2.png)

3. Fill in the wiki information as shown on the screenshot below and hit the `Publish` button. The wiki is inside the `Generic repository`.

![Expose your Docs as Wiki](../wiki_images/azdo_publish_docs_as_wiki_3.png)

4. You will be redirected to your freshly exposed Wiki which you can now navigate!

![Expose your Docs as Wiki](../wiki_images/azdo_publish_docs_as_wiki_4.png)

## Recommended GIT structure / Company specific repository
As explained in [Setup Azure DevOps & GIT](#setup-azure-devops-%26-git) we have a setup with a company repo which holds this generic repo. We've done this to create 1 starting point for you and your colleagues to work with both company specific wiki's & scripts as well as the generic wiki & scripts. This is how the repository looks:

![Repository structure](../wiki_images/git_howto_repo_structure.png)

To create this repository the same way, follow these steps:

1. Create the new company specific repository next to the generic repo you already made in [Mirroring the upstream repo to your own Azure DevOps instance](#mirroring-the-upstream-repo-to-your-own-azure-devops-instance).

![Create company repo](../wiki_images/git_create_company_repo_1.png)

2. Fill in the information of your company repo (the name in the screenshot is fictional) and click on the `Create` button.

![Create company repo](../wiki_images/git_create_company_repo_2.png)

3. Get the company cloning address by clicking the `Clone` button in your freshly created repository.

![Create company repo](../wiki_images/git_create_company_repo_3.png)

4. Copy the clone address by clicking the copy button.

![Create company repo](../wiki_images/git_create_company_repo_4.png)

5. Open the terminal of your choice (We recommend using Windows Terminal) and navigate to the folder where you want to checkout this repo. Now clone the repo, CD into it, add the submodule & commit & push it back to the server using these commando's (make sure to substitute the variables before running the commands):

```batch
git clone <repo url>
cd <repo folder>
git submodule add <upstream repo url> Azure.PlatformProvisioning
git commit -a -m "Added sub repo"
git push origin main
```
> The upstream repo url is the URL made in the [Mirroring the upstream repo to your own Azure DevOps instance](#mirroring-the-upstream-repo-to-your-own-azure-devops-instance) step.

Congratulations. You now have created a company specific repository with the Generic repository as its submodule!

## Checking out the company specific repository on a new computer
Since your company specific repository has a submodule to the generic AzDocs, you need to do something special to check the whole structure out. You need to tell GIT to also clone the submodules on cloning your company specific repo. So instead of the usual:

`git clone <company specific repo url>`

you need to do:

`git clone --recurse-submodules <company specific repo url>`

> The URL of this repo is the URL to the repo created in this step: [Recommended GIT structure / Company specific repository](#recommended-git-structure-%2F-company-specific-repository)

Et voila! your full repository (or actually repositories) is/are now cloned!

## Working with this setup & GIT
Whenever you work with submodules and you edit something in these submodules (in this case the upstream repo), you need to update the reference in the company specific repo to the new commit of this generic (your copy of the upstream) repo. This is a pretty straightforward process, but it can be a little hard to figure out on your own.

First of all, lets assume you are using Visual Studio Code. This example will make use of VsCode so that we can make it visual:

1. Make your change in the generic repo. Let's assume you already have done this. In this example we changed the `Azure.md` file.

2. In VsCode when you opened the company specific repo with the submodule as a folder (File --> Open Folder), 

![Commit changes](../wiki_images/commit_changes_1.png)

3. Under the `Source Control` tab you will see two repositories. Commit & Push the generic repo content (in our case the `Azure.md` file.). This is the bottom one in the following screenshot.

![Commit changes](../wiki_images/commit_changes_2.png)

4. In the top repo you will see that the submodule file was changed (in the screenshot the file is called `Azure.PlatformProvisioning`). If you click on this change, you will see the following:

![Commit changes](../wiki_images/commit_changes_3.png)

5. In the screenshot you see that the subproject commit id has changed. This is to reference the new version (commit) of your generic repository. Commit & Push this file to update your company specific repo. At this point, your automatic build-pipeline will start to run.

6. After the build-pipeline is done, you will have the new version of the AzDocs at your disposal.

## How to keep your repositories in sync with upstream
*For the next procedure you will need an account at GitHub. Make sure to have this before continuing. You can create a GitHub account [here](https://github.com/join).*

The generic repo will have 2 remote's if you also want to contribute to this project or get new updates from this project. So after mirroring [the upstream github repo](https://github.com/RobHofmann/Azure.PlatformProvisioning) to your own Azure DevOps instance, you want to clone the repository to your local machine.

> NOTE: Next to the working company repository with the generic repository inside (as explained in [the GIT paragraph](#git)) you daily use, we tend to keep the upstream in a separate folder on our computer aswell for syncing our origin with the upstream repo.

First clone the repo to your local disk with:

`git clone <upstream repo url>`

> The upstream repo url is the URL made in the [Mirroring the upstream repo to your own Azure DevOps instance](#mirroring-the-upstream-repo-to-your-own-azure-devops-instance) step.

After doing this you enter the freshly created repo folder and use this command to add the upstream remote to your local repo:

`git remote add upstream https://github.com/RobHofmann/Azure.PlatformProvisioning.git`

Doing so will give you two remotes: `origin` & `upstream`.

### Pulling new changes from upstream (Github) to your origin repo
*Make sure you followed the information from [How to keep your repositories in sync with upstream](#how-to-keep-your-repositories-in-sync-with-upstream) first.*

For this example lets assume that some work has been done by other companies and you want the latest & greatest changes for your company. Since our philosophy is that `upstream` should always be able to merge to `origin` we pull directly into our `origin/main` branch to avoid squash commits over and over between `upstream` & `origin`. Follow these steps to get the latest from `upstream` to your `origin`:

> First navigate to the cloned upstream repo (the repo made in the [Mirroring the upstream repo to your own Azure DevOps instance](#mirroring-the-upstream-repo-to-your-own-azure-devops-instance) step). Then follow these steps:

```batch
git checkout main
git pull upstream main
git push origin main
```

![Updated main branch](../wiki_images/git_how_to_keep_repos_in_sync_with_upstream_5.png)

Your repository is now up to date.

### Commit the work you've done to the upstream (GitHub) repo
*Make sure you followed the information from [How to keep your repositories in sync with upstream](#how-to-keep-your-repositories-in-sync-with-upstream) first.*

Let's assume you've done some work on your `origin` and at some point in time you want to sync this back to the `upstream`. We do this by creating a new branch and pushing it to the upstream. We need to make sure we use the latest version of main to create our PR Branch from:

> First navigate to the cloned upstream repo (the repo made in the [Mirroring the upstream repo to your own Azure DevOps instance](#mirroring-the-upstream-repo-to-your-own-azure-devops-instance) step). Then follow these steps:

```batch
git checkout main
git pull origin main
git checkout -b 20210426
git push upstream 20210426
```

This will create a new branch in the upstream repo. After this you can [create a PR](https://github.com/RobHofmann/Azure.PlatformProvisioning/compare) on github. Select the branch you just created from the "compare" list.

![Select the compare branch](../wiki_images/git_how_to_keep_repos_in_sync_with_upstream_1.png)

Now confirm the selected branch by clicking the green `Create pull request` button.

![Confirm the branch selection](../wiki_images/git_how_to_keep_repos_in_sync_with_upstream_2.png)

Finally enter the name of your PR (I recommend naming it the same as the branch you created).

![Create a PR on GitHub](../wiki_images/git_how_to_keep_repos_in_sync_with_upstream_3.png)

Done! From here multiple people will review this PR. Eventually the PR will be accepted or rejected based on the feedback & discussion. Make sure to reply to questions being asked & actively participate in the discussion revolving your PR.

![Accepted & Merged PR](../wiki_images/git_how_to_keep_repos_in_sync_with_upstream_4.png)

*A merged pullrequest in the `upstream/main` branch*

# How to use the scripts
To use these scripts you simply add a Azure CLI step to your pipeline. Make sure to fill in the right subscription you want to use in the step and select the script from this repo you want to execute. If you are using classic release pipelines, we recommend making a taskgroup per script so you can re-use them easily.

## AzDocs Build
First of all you will need to "build" the scripts. This means you will need a build which gets the repo & submodule, copies the scripts to the `$(Build.ArtifactStagingDirectory)` and publishes the artifact to the internal Azure DevOps repo, so you can use it in your releases. We've provided the following YAML build to get this done.

1. Generate a new [Peronal Access Token](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page#create-a-pat).
2. [Base64 encode](https://www.base64encode.org/) the text `pat:<enterthePATfromstepone>`. For example: `pat:le5jjn4yskffufljovntjjjrtfzqyffvhec2b774a3zqauokbp4a` will give `cGF0OmxlNWpqbjR5c2tmZnVmbGpvdm50ampqcnRmenF5ZmZ2aGVjMmI3NzRhM3pxYXVva2JwNGE=`.
3. Find the repo url for your generic repository.

![Find the generic repo url](../wiki_images/azdocs_build_find_generic_repo_url.png)

4. Go to pipelines and create a `New Pipeline` in the [Azure Documentations team project](#setup-azure-devops-%26-git).

![Create AzDocs Build Pipeline](../wiki_images/azdocs_build_create_new_pipeline_1.png)

5. For your source, select `Azure Repos Git`.

![Create AzDocs Build Pipeline](../wiki_images/azdocs_build_create_new_pipeline_2.png)

6. Select your company specific repository (in the example our company repo is called `Azure.Documentation`).

![Create AzDocs Build Pipeline](../wiki_images/azdocs_build_create_new_pipeline_3.png)

7. Select Started Pipeline (this doesn't really matter, but you need to choose something).

![Create AzDocs Build Pipeline](../wiki_images/azdocs_build_create_new_pipeline_4.png)

8. Replace the default YAML with following YAML in the pipeline:
```yaml
name: $(date:yyyy.MM.dd)$(rev:.r)-$(Build.SourceBranchName)
trigger:
  paths:
    exclude:
    - azure-pipelines.yml

resources:
- repo: self

variables:
  # PLEASE ADD GIT_AUTH_HEADER TO YOUR PIPELINE VARIABLES AS A SECRET (SEE THE DOCS FOR MORE INFO)
  - name: UPSTREAM_REPO_URL
    value: <enter the generic repository url here>
  - name: DECODE_PERCENTS
    value: false

stages:
- stage: Build
  displayName: Create AzDocs Pipeline Artifact
  jobs:
  - job: Build
    displayName: Build
    pool:
      vmImage: ubuntu-latest
    steps:
    - task: Bash@3
      displayName: 'Get Submodule'
      inputs:
        targetType: 'inline'
        script: 'git -c http.$(UPSTREAM_REPO_URL).extraheader="AUTHORIZATION: basic $(GIT_AUTH_HEADER)" submodule update --init --recursive'
    # Generic Wiki
    - task: CopyFiles@2
      displayName: 'Copy Generic Wiki'
      inputs:
        SourceFolder: 'Azure.PlatformProvisioning/Wiki'
        TargetFolder: '$(Build.ArtifactStagingDirectory)/Wiki'
    # Company Specific Wiki
    - task: CopyFiles@2
      displayName: 'Copy Company Wiki'
      inputs:
        SourceFolder: 'Wiki'
        TargetFolder: '$(Build.ArtifactStagingDirectory)/Wiki'
    - task: PublishBuildArtifacts@1
      displayName: 'Publish AzDocs Artifact'
      inputs:
        PathtoPublish: '$(Build.ArtifactStagingDirectory)/Wiki'
        ArtifactName: 'azdocs-wiki'
        publishLocation: 'Container'
    # Generic src
    - task: CopyFiles@2
      displayName: 'Copy Generic src'
      inputs:
        SourceFolder: 'Azure.PlatformProvisioning/src'
        TargetFolder: '$(Build.ArtifactStagingDirectory)/src'
    # Company Specific src
    - task: CopyFiles@2
      displayName: 'Copy Company src'
      inputs:
        SourceFolder: 'src'
        TargetFolder: '$(Build.ArtifactStagingDirectory)/src'
    - task: PublishBuildArtifacts@1
      displayName: 'Publish AzDocs Artifact'
      inputs:
        PathtoPublish: '$(Build.ArtifactStagingDirectory)/src'
        ArtifactName: 'azdocs-src'
        publishLocation: 'Container'
```

![Create AzDocs Build Pipeline](../wiki_images/azdocs_build_create_new_pipeline_5.png)

9. Click on `Variables` and add the `GIT_AUTH_HEADER` variable with the `base64` value from step 2 (So `GIT_AUTH_HEADER=cGF0OmxlNWpqbjR5c2tmZnVmbGpvdm50ampqcnRmenF5ZmZ2aGVjMmI3NzRhM3pxYXVva2JwNGE=`) and mark the variable as `Secret`.

![Create AzDocs Build Pipeline](../wiki_images/azdocs_build_create_new_pipeline_6.png)

10. Click `New Variable`.

![Create AzDocs Build Pipeline](../wiki_images/azdocs_build_create_new_pipeline_7.png)

11. Enter `GIT_AUTH_HEADER` under the name and fill the value with the `base64` value from step 2 (So `GIT_AUTH_HEADER=cGF0OmxlNWpqbjR5c2tmZnVmbGpvdm50ampqcnRmenF5ZmZ2aGVjMmI3NzRhM3pxYXVva2JwNGE=`) and mark the variable as `Secret`. Click `Ok`.

![Create AzDocs Build Pipeline](../wiki_images/azdocs_build_create_new_pipeline_8.png)

12. Replace the `<enter the generic repository url here>` placeholder in the above YAML with the generic repo url from step 3.

13. Save & run the pipeline. Everything should turn green and you will have a build artifact!

![Create AzDocs Build Pipeline](../wiki_images/azdocs_build_create_new_pipeline_9.png)

## Disable "Limit job authorization scope" settings
*Make sure to have followed the steps in [AzDocs Build](#azdocs-build)*

In order to use the [AzDocs Build](#azdocs-build), you will need to disable some security settings in Azure DevOps. By default you cannot use builds from different teamprojects. In our case, we do want to do this on purpose. To correct this, we need to set the setting on 3 places:
 1. The organization level.
 2. The AzDocs TeamProject (you can find how to setup under [Setup Azure DevOps & GIT](#setup-azure-devops-%26-git)).
 3. Your own project's [Azure DevOps TeamProject](https://docs.microsoft.com/en-us/azure/devops/organizations/projects/create-project?view=azure-devops&tabs=preview-page).

### Disable "Limit job authorization scope" on organization level
First of all you need to make sure you disable multiple "limit job authorization scope" toggles on your organization level. To do this follow these steps:

1. Go to the main Azure DevOps overview page & click `Organization settings` in the left bottom.

![Organization settings](../wiki_images/limit_job_scope_organization_1.png)

1. Go to `Settings` under `Pipelines` & Disable the following 3 toggles: `Limit job authorization scope to current project for non-release pipelines`, `Limit job authorization scope to current project for release pipelines`, `Limit job authorization scope to referenced Azure DevOps repositories`.

![Limit job on org lvl](../wiki_images/limit_job_scope_organization_2.png)

### Disable "Limit job authorization scope" on teamproject level
Next you need to make sure you disable multiple "limit job authorization scope" toggles on your TeamProject level. You need to do this for your AzDocs Teamproject & your own teamproject. So make sure to follow these steps for both (or even more of your own) teamprojects:

1. Go to your Azure DevOps Teamproject (or the Azure Documentation teamproject) & click `Project settings` in the left bottom.

![Project settings](../wiki_images/limit_job_scope_teamproject_1.png)

1. Go to `Settings` under `Pipelines` & Disable the following 3 toggles: `Limit job authorization scope to current project for non-release pipelines`, `Limit job authorization scope to current project for release pipelines`, `Limit job authorization scope to referenced Azure DevOps repositories`.

![Limit job on project lvl](../wiki_images/limit_job_scope_teamproject_2.png)


## Adding the subscriptions to your teamproject
To deploy resources in Azure, you need to tell Azure DevOps how to reach the Azure subscription. [Click here](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure?view=azure-devops) to go to the official microsoft documentation on this to add this connection. We strongly recommend to name the connection identical to the subscription name.

## Default variables
To standarize some of the often used variables, we've created a list of these variables. An overview can be found at [Azure CLI Snippets](/Azure/Azure-CLI-Snippets). In a lot of cases you will also see a lot of derrived parameter names. For example for the $(ResourceGroupName) variable you will see the `AppServiceResourceGroupName` parameter inside App Service scripts. And in Keyvault scripts you will see `KeyvaultResourceGroupName`. This is purposely done to make it absolutely clear which resource we are talking about. There are scripts which accept multiple ResourceGroupNames for multiple resources. A good example is the `Create-Web-App-Linux.ps1` script which accepts `AppServiceResourceGroupName` and `AppServicePlanResourceGroupName`. They can both be filled with the $(ResourceGroupName) variable.

Another option is to create variables for each resourcegroupname which defaults to $(ResourceGroupName). In the case of a YAML pipeline this would look something like this:

```yaml
variables:
  # Basic
  - name: AppServiceResourceGroupName
    value: $(ResourceGroupName)
  - name: AppServicePlanResourceGroupName
    value: $(ResourceGroupName)
```

The result is that you have a little more variables, but you can control your whole pipeline solely through variables without having to doubt which resources will be affected.

## Classic Pipelines
*Make sure to have followed the steps in [AzDocs Build](#azdocs-build) and [Adding the subscriptions to your teamproject](#adding-the-subscriptions-to-your-teamproject)*

To create a release pipeline for your app where you can use this boilerplate, there are a few steps you have to do and a few steps which are recommended but not required. Here will be described how to create such a pipeline.
1. Go to the releases page in your teamproject and create a new release pipeline definition.
2. In the `Pipeline` tab, under `Artifacts`, add a new artifact and select the [AzDocs Build](#azdocs-build) (make sure to select the right Project first). It's recommended to assign the Source alias: `Azure.Documentation` to avoid weird characters in the file paths.
3. Add the optional build artifact for your own software.
4. Rename the `Stage 1` *stage*. Let't call it `dev` (later *stages* can be made, reproducing these steps but with `acc` or `prd` as the *Stage*-name.

![Classic pipeline](../wiki_images/classic_pipeline_howto_3.png)

5. Click the `0 jobs, 0 tasks` link in the `dev` *stage*.
6. In the left column, click the `+` in the top right and search for the *Azure CLI* step.

![Azure CLI Step](../wiki_images/classic_pipeline_howto_1.png)

7. Enter these parameters in the *Azure CLI* step
    - Azure Resource Manager connection: *select the connection created in the [Adding the subscriptions to your teamproject](#adding-the-subscriptions-to-your-teamproject) step
    - Script Type: *PowerShell Core*
    - Script Location: *Script Path*
    - Script Path (replace with real values): `$(System.DefaultWorkingDirectory)/Azure.Documentation/drop/<ResourceType>/<Script>.ps1` (you can use the file browser to select your script)
    - Script Arguments: `<insert the needed script arguments from the script you are calling>`
    - Access service principal details in script: <input type="checkbox" checked> (Required in rare cases for some scripts).

![Classic pipeline](../wiki_images/classic_pipeline_howto_2.png)

8. *Save* & *Create Release*. Congratulations, you can now run your pipeline and spin up secure & compliant Azure resources.

> NOTE: However, there are a few more tips & tricks we found useful. The following paragraphs containing tips & tricks are optional.

### Taskgroup all the things
For reusability purposes within your teamproject, it is wise to create a taskgroup for each script you use. This means you can add this taskgroup (even multiple times) to every pipeline you like without having to define the script location & parameters again.

> NOTE: Taskgroups are unfortunately scoped to a Azure DevOps TeamProject. This means that you can't use your taskgroup between projects.

To create a taskgroup per script, follow the following tutorial:

1. Whenever you added the CLI step the first time, right click it and click on `Create task group`.

![Create Taskgroup](../wiki_images/classic_pipeline_taskgroup_1.png)

2. Give your taskgroup a fitting name (we choose to name the taskgroups identical to the scripts).

![Create Taskgroup](../wiki_images/classic_pipeline_taskgroup_2.png)

3. After creating the taskgroup, you can add a new step to your pipeline and search for your taskgroup (make sure to hit the `Refresh` button if you don't see your taskgroup in the list).

![Add Taskgroup](../wiki_images/classic_pipeline_taskgroup_3.png)

4. After you've added the taskgroup, you can fill in the variables with your desired values and run the pipeline.

![Add Taskgroup](../wiki_images/classic_pipeline_taskgroup_4.png)


> NOTE: Known limitation: Taskgroups can not have output parameters. So for anything that uses output parameters, the step needs to be added to the pipeline directly and cannot be in any taskgroup. We strongly recommend to use YAML pipelines to not run into these issues.

> NOTE: Another known limitation is that you can not add optional parameters to taskgroups. You always have to fill in a value to the parameters. To workaround this, we've added a variable to our `Variables` called `EmptyString` which has an empty value. This means that we can simply pass `$(EmptyString)` to these optional parameters and it will no longer give an issue!

### Taskgroup the pipeline itself
Classic Pipelines have the downside that you have to create your pipeline per environment. This can get nasty whenever you have a lot of environments or do a lot of changes on your pipeline. This is why we chose to "taskgroup the pipeline". The result is that you have 1 pipeline taskgroup which is added to each environment. Whenever you change your pipeline taskgroup, this goes for all your environments at once.

1. Go to your classic pipeline & edit it and go to your first environments pipeline (in this example it is `dev`).

![Edit pipeline](../wiki_images/classic_pipeline_taskgroup_the_pipeline_1.png)

2. Select all your tasks in the pipeline and rightclick --> `Create task group`

![Select all the tasks](../wiki_images/classic_pipeline_taskgroup_the_pipeline_2.png)

3. A new window will popup. We chose to name these taskgroups `[PIPELINE] <projectname>`. Now fill in the parameters. It is very likely that you can simply copy the parameter name and paste it as a variable (see screenshot below). This will just proxy your variables to the taskgroup.

![Create the new taskgroup](../wiki_images/classic_pipeline_taskgroup_the_pipeline_3.png)

4. You will now have a single taskgroup in your pipeline.

![Single pipeline taskgroup](../wiki_images/classic_pipeline_taskgroup_the_pipeline_4.png)

5. Switch to your other environment (in this example this is `acc`). Add the same taskgroup you just created to your pipeline.

![Add pipeline taskgroup to your 2nd environment](../wiki_images/classic_pipeline_taskgroup_the_pipeline_5.png)

From now on. Whenever you change something inside your `[PIPELINE]` taskgroup, it will effect all your environments without having to keep track of all the pipeline changes between environments. This will force you into keeping your environments identical (which in our opinion is required for realistic testability).

### Variable groups
In contrast to YAML pipelines, we recommend using variable groups when using classic pipelines. This is so you can organize your variables between pipelines. For example if you have one central Log Analytics Workspace, you don't want 100 references to this resource. You can use a variable group to define the resource id and attach that variable group to all of your pipelines.

In YAML we recommend NOT doing this simply because of the "Infrastructure as Code" principle. This means that all the information needed for your pipeline should be in your repository & under sourcecontrol. Next to that; with YAML pipelines can you actually create pipelines per branch. In this case you can change/add/remove variables in that specific branch. This would not be possible if you use a variable group.

The only exception we make for using variable groups in YAML pipelines is when we are storing secrets. You don't want these in your repository due to security concerns :).

### Variable nesting
We recommend nesting variables and leveraging system variables. This means you will have a more standarized/consistent platform across your environments.
Below you can find an example where we define our Teamname & Projectname and re-use those, along with the `Release.EnvironmentName` systemvariable, to create our resourcegroup name. Note that in the example below the result for your `dev`, `acc`, and `prd` environments will be respectively: `AwesomeTeam-MyFirstProject-dev`, `AwesomeTeam-MyFirstProject-acc` and `AwesomeTeam-MyFirstProject-prd`.

This means you don't have to redefine the resourcegroupname for each environment and that if you, in a later stadium, choose to create a new environment, you don't have to go through your variables again. You can simply clone the environment, rename it & roll out the release.

![Variable nesting](../wiki_images/variable_group_variable_nesting_1.png)

## YAML Pipelines
*Make sure to have followed the steps in [AzDocs Build](#azdocs-build) and [Adding the subscriptions to your teamproject](#adding-the-subscriptions-to-your-teamproject)*

The recommended way of building pipelines is using YAML pipelines. To make using this boilerplate convenient for you, we've added a few ways of using it in your projects.

First of all, and most important, in each wiki page for the scripts we've added a piece of YAML code which you can conveniently copy & paste into your own YAML pipelines. The only thing you need to do is strip the parameters you don't need from this. This means that adding resources to your pipeline is as simple as just copy & paste and managing the parameters!

Next to this we've also made a few examples on how to create a pipeline with two goals in mind:
 - Examples how to setup a pipeline in general which supports multiple environments without having to redefine your pipeline for each environment (to guarantee reproducibility in your platform across environments).
   - Generic/Bare Orchestrator Pipeline (this is the root file which is being imported in your pipelines) - `templates/Examples/General/pipeline-orchestrator.yml`
      - Generic/Bare Build template - `templates/General/pipeline-build.yml`
      - Generic/Bare Release template - `templates/ General/pipeline-release.yml`
 - Examples for specific "often used" resources
   - FunctionApp Orchestrator Pipeline (this is the root file which is being imported in your pipelines) - `templates/Examples/FunctionApp/pipeline-orchestrator.yml`
      - FunctionApp Build template - `templates/Examples/FunctionApp/pipeline-build.yml`
      - FunctionApp Release template -  `templates/Examples/FunctionApp/pipeline-release.yml`
   - WebApp Orchestrator Pipeline (this is the root file which is being imported in your pipelines) - `templates/Examples/WebApp/pipeline-orchestrator.yml`
      - WebApp Build template - `templates/Examples/WebApp/pipeline-build.yml`
      - WebApp Release template - `templates/Examples/WebApp/pipeline-release.yml`

PS. Sorry for not providing links, but the Azure DevOps wiki doesn't allow links to .yml files :(.

### Pipeline structure
As with Classic Pipelines, by default you need to create a pipeline per stage in a YAML pipeline. In our vision you only have one single truth for your platform, which should be reproducable on each environment. This means that you will only need one release pipeline and one build pipeline. To get this done, we've created a setup where we have a so called "orchestrator pipeline" which executes the build & release pipeline on the right moments. The build & release pipeline are written inside a separate yaml file. This way you can simply load the pipelines at the right moment. The pipeline architecture looks like this:

![YAML Pipeline structure](../wiki_images/yaml-pipeline-architecture.png)

To achieve this, your stages in your ochestrator file will look something like this:

```yaml
variables:
  # Basic
  - name: TeamName
    value: TeamRocket
  - name: ProjectName
    value: TestApi

stages:
  - stage: "Build"
    jobs:
      - job: Build
        displayName: "Build"
        steps:
          - template: pipeline-build.yml

  - stage: "dev"
    displayName: "Deploy to dev"
    jobs:
      - template: pipeline-release.yml
        parameters:
          SubscriptionName: "MY DEV SUBSCRIPTION"
          EnvironmentName: dev
          TeamName: $(TeamName)
          ProjectName: $(ProjectName)

  - stage: "acc"
    displayName: "Deploy to acc"
    jobs:
      - template: pipeline-release.yml
        parameters:
          SubscriptionName: "MY ACC SUBSCRIPTION"
          EnvironmentName: acc
          TeamName: $(TeamName)
          ProjectName: $(ProjectName)
```

As you can see, we call the `pipeline-release.yml` twice. Once for `dev` and once for `acc`. This means that you will have identical environments. Inside the `pipeline-release.yml` you can use the parameters to generate the correct naming for your environment. For example, you can generate your resourcegroupname as following:
```yaml
    variables:
      - name: ResourceGroupName
        value: ${{ parameters.TeamName }}-${{ parameters.ProjectName }}-${{ parameters.EnvironmentName }}
```

For the `dev` environment this will be `TeamRocket-TestApi-dev` and for `acc` it will be `TeamRocket-TestApi-acc`. This will also result in a very consistent naming scheme across your environments.

### Unique pipeline for each branch
A good thing to realise is, that since your pipeline is now part of your code, you also have a pipeline per branch. This means that with YAML pipelines (in opposition to classic pipelines) you can have a pipeline for each branch you create. It is perfectly sane to have a new API introduced in your project inside a branch which you want to test on Azure. For this you can, inside your branch, edit your release pipeline and deploy this new API. After testing it all inside your branch, you can pull-request the software & accompanying pipeline to master alltogether, under quality control through your PR!

### Variablemanagement
In YAML pipelines we take a slightly different approach to manage our variables. In opposition to classic pipelines, we consciously choose not to use `variable groups`. We put our variables inside our YAML pipelines itself. This has two major reasons. The first reason is that we want our variables under sourcecontrol, which means pipelines, including variables, will be merged to master using pull-requests. This means that your pipelines are under quality control as well! The second reason is that with YAML pipelines (again in opposition to classic pipelines) you can have a pipeline per branch like described in [Unique pipeline for each branch](#unique-pipeline-for-each-branch).

The only downside to this approach is that you don't have any shared variables between pipelines and that you can get some duplicate variables accross pipelines. This however does have the upside that if you need to change a "shared" variable, it will in this case not affect all pipelines at the same time (so you don't break all of your pipelines at the same time by changing one variable).

### Secretsmanagement
*Make sure you read the information from [Variablemanagement](#variablemanagement) first.*
In opposition to normal variables, the only exception we make is for secrets. Since you don't want your secrets under sourcecontrol or, for that matter, plaintext at all, we need another solution for this. In this case you are pretty much free to use the variable groups in the library or use the variables inside the pipeline itself. Make sure to mark the variables as secret in both those options.

The same also counts for secure files (we use this for certificates for example). Those will NOT be in your repository due to the sensitive nature of those files. You can store them under the `Secure files` tab under the `Libary` tab inside the `Pipelines` module. [For more information aboute `Secure files`, please click here](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/secure-files?view=azure-devops).

### Getting the AzDocs Build Information (ID)
For using the AzDocs Scripts in your YAML pipeline, you will need to include the following step in your pipeline:
```yaml
    - task: DownloadPipelineArtifact@2
      displayName: Download AzDocs Artifact
      inputs:
        buildType: "specific"
        project: "<TeamProjectGuid>"
        definition: "<BuilddefinitionId>"
        buildVersionToDownload: "latestFromBranch"
        branchName: "refs/heads/master"
        artifactName: "azdocs-src"
        targetPath: "$(Pipeline.Workspace)/AzDocs"
```

For this you will need the `TeamProjectGuid` and the `BuilddefinitionId` for the AzDocs build. The easiest way to fetch the `BuilddefinitionId` id is to go to your pipelines overview and get the builddefinition id from your URL bar (see screenshot below).

![Get builddefinition ID](../wiki_images/pipelines_get_builddefinition_id.png)

Next you will need to fetch the `TeamProjectGuid`. The easiest way to do this is to go to the following URL in the same browser where you are logged in to Azure DevOps (this omits you having to fiddle with authentication in a rest call):

`https://dev.azure.com/<organization>/_apis/projects/<projectname>?api-version=6.0`

This pretty much boils down to something like this:

`https://dev.azure.com/mycompany/_apis/projects/Azure%20Documentation?api-version=6.0`

The first part of the response will be something like: `{"id":"57548766-4c42-4526-afb0-86b6aa17ee9c",`. In this case the GUID `57548766-4c42-4526-afb0-86b6aa17ee9c` is your `TeamProjectGuid`.

The final YAML for downloading the AzDocs artifact in this case will look like this:

```yaml
    - task: DownloadPipelineArtifact@2
      displayName: Download AzDocs Artifact
      inputs:
        buildType: "specific"
        project: "57548766-4c42-4526-afb0-86b6aa17ee9c"
        definition: "853"
        buildVersionToDownload: "latestFromBranch"
        branchName: "refs/heads/master"
        artifactName: "azdocs-src"
        targetPath: "$(Pipeline.Workspace)/AzDocs"
```

The scripts will be available like described on the wiki (For example: your `Create-ResourceGroup.ps1` script will be available under `$(Pipeline.Workspace)/AzDocs/Resourcegroup/Create-ResourceGroup.ps1`).

PROTIP: If you want to make your own scripts, you will need to define the AzDocs branch you are working in. You can make this configurable at runtime by changing `branchName: "refs/heads/master"` to `branchName: "refs/heads/$(AzDocsBranchName)"` and while editing your pipeline going to `Variables`, adding the `AzDocsBranchName` with value `master` and enabling the `Let users override this value when running this pipeline` option (See screenshot below):

![Override AzDocs branch](../wiki_images/pipelines_override_azdocs_artifact_branch.png)


### Deploying to Virtual Machines
Sometimes we still need to work with virtual machines (IaaS). Some of us are unlucky enough to work in a hybrid situation where they have Azure on one side, and an on-premises environment on the other side. Sometimes you also want to deploy software from your CICD pipelines to these on-premises machines or Azure VM's. In this case you need to know how to onboard those machines into Azure DevOps. Today is your lucky day, here is a crash course & provided script on how to do this. For YAML pipelines you need to onboard your machines into `Environments`. This is a little different from the old `Deployment Groups` with classic pipelines. 

First of all you will need to onboard your machines into Azure DevOps Environments. Currently we've only documented this for Windows machines. For linux you will need to do something similar to the following procedure:

For windows you can use this oneliner to onboard your machine:

```powershell
$AzureDevOpsOrganizationName='myorganization';$AgentDisk='D';$AzureDevOpsProjectName='MyProject';$EnvironmentName='dev';$VirtualMachineResourceTags='MyApplication,AnotherApplication';$ServiceAccountUserName='MYDOMAIN\svc_SomeUser';$ServiceAccountPassword='MyServicePassword';$PersonalAccessToken='ThisIsMyPersonalAccessToken';$ProxyUrl='';$AgentVersion='2.189.0'; $ErrorActionPreference="Stop";If(-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator")){ throw "Run command in an administrator PowerShell prompt"};If($PSVersionTable.PSVersion -lt (New-Object System.Version("3.0"))){ throw "The minimum version of Windows PowerShell that is required by the script (3.0) does not match the currently running version of Windows PowerShell." };If(-NOT (Test-Path $AgentDisk':\yamlagent')){mkdir $AgentDisk':\yamlagent'}; cd $AgentDisk':\yamlagent'; for($i=1; $i -lt 100; $i++){$destFolder="A"+$i.ToString();if(-NOT (Test-Path ($destFolder))){mkdir $destFolder;cd $destFolder;break;}};Write-Host "Dest folder: $destFolder"; $agentZip="$PWD\agent.zip"; $DefaultProxy=[System.Net.WebRequest]::DefaultWebProxy;$securityProtocol=@();$securityProtocol+=[Net.ServicePointManager]::SecurityProtocol;$securityProtocol+=[Net.SecurityProtocolType]::Tls12;[Net.ServicePointManager]::SecurityProtocol=$securityProtocol;$WebClient=New-Object Net.WebClient; $Uri="https://vstsagentpackage.azureedge.net/agent/$($AgentVersion)/vsts-agent-win-x64-$($AgentVersion).zip";if($ProxyUrl){$WebClient.Proxy=New-Object Net.WebProxy($ProxyUrl, $True);} $WebClient.DownloadFile($Uri, $agentZip);Add-Type -AssemblyName System.IO.Compression.FileSystem;[System.IO.Compression.ZipFile]::ExtractToDirectory($agentZip, "$PWD"); $optionalParameters = @(); if ($ProxyUrl) { $optionalParameters += '--proxyurl', "$ProxyUrl" } ;.\config.cmd --environment --environmentname $EnvironmentName --addvirtualmachineresourcetags --virtualmachineresourcetags $VirtualMachineResourceTags --agent "$($env:COMPUTERNAME)-YAML-$destFolder" --runasservice --windowsLogonAccount $ServiceAccountUserName --work '_work' --url "https://dev.azure.com/$($AzureDevOpsOrganizationName)/" --projectname $AzureDevOpsProjectName --auth PAT --token $PersonalAccessToken --windowsLogonPassword $ServiceAccountPassword @optionalParameters; Remove-Item $agentZip;
```

These variables at the start of this script can be edited:

| Variable | Description |
|---|---|
| $AzureDevOpsOrganizationName | The name of your Azure DevOps organization. This is the name in the URL behind `https://dev.azure.com/`. So in the case of `https://dev.azure.com/myorg` the value will be `myorg` |
| $AgentDisk | Which disk do you want to put the AzDo agent. |
| $AzureDevOpsProjectName | The TeamProject name where you want to onboard these machines. |
| $EnvironmentName | The name of the environment to onboard your machine into. It's likely that you would use `dev`, `acc`, or `prd` here. Make sure you've created the environment before running this script. |
| $VirtualMachineResourceTags | Which tags should the machine get. These tags can be used to select machines while you deploy. For example add the tag `MyApplication`. Later in your release you can simply say: Deploy my software to all machines with the tag `MyApplication`. The expectation is that those tags are identical between environments. `NOTE: this value is comm separated (e.g. MyApplication,AnotherApplication,AnotherTag)`. |
| $ServiceAccountUserName | The user under which the Azure DevOps agent should run. You can also pass `NT AUTHORITY\SYSTEM` and pass a fake password to the `ServiceAccountPassword` parameter (e.g. `somethingsomething`). Make sure this user has the right permissions to do the stuff you want to do in your pipeline. |
| $PersonalAccessToken | The PAT which you can create under your account in Azure DevOps |
| $ProxyUrl | The Proxy URL. This has been tested with using a HTTP proxy. Can be left blank in order to NOT use a proxy at all. |
| $AgentVersion | The version of the agent. Check [Github](https://github.com/microsoft/azure-pipelines-agent/releases) for the latest version. |

After onboarding your machine you can use this machine from your YAML pipeline. You can run a stage on the onboarded machine using the following YAML:

```yaml
- stage: dev
  jobs:
  - deployment: 'Deploy_dev'
    environment: 
      name: dev
      resourceType: VirtualMachine
      tags: MyMachineTag
    strategy:
      runOnce:
        deploy:
          steps:
          - template: pipeline-release.yml
            parameters:
              SomeParameter: myvalue
```

Voilà! You can now deploy to your virtual machines the same way as you deploy to Azure PaaS resources!

# Guidelines for creating new scripts
If you want to create new scripts and PR them into this repo, make sure to follow the [Azure CLI unless](#azure-cli-unless) rule. We make use of creating [powershell advanced functions](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced?view=powershell-7.1). A general advise is to take a look at other scripts and copy those and go from there.

The start of every script should look something like this:
```powershell
[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $FictionalParameter    
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet
```

Note the `Write-Header` which outputs the parameters that were given to this script for easy debugging.

and the end should look something like this:
```powershell
Write-Footer -ScopedPSCmdlet $PSCmdlet
```

## Coding Convention
We use the `Allman` code formatting preset from VSCode. Also we disable the `openBraceOnSameLine` setting in powershell. In theory your VSCode should already do this for you, since we've checked in our [settings.json](../.vscode/settings.json) to the repository.

Another thing we do, is wrap our CLI statements in the `Invoke-Executable` method. This allows us to get better logging for our CLI statements. Next to this it also allows us to set the `System.Debug` variable in our pipeline to `true`, which will enable debug mode for CLI as well (it appends `--debug` to all CLI statements). And the final, maybe most important, thing it does is act accordingly whenever an exitcode is returned by the CLI statements. In short: Vanilla CLI does not always break the pipeline when it should. For example: if you create a resource, and the CLI fails, your pipeline will still turn out to be green and continue the next steps. The `Invoke-Executable` wrapper makes sure it checks the output and breaks the pipeline whenever this is desired. There is also a flag (`-AllowToFail`) which disables this behaviour.

### Naming
- Our script & function parameters are written CamelCase
- Local variables are all lowercase
- Functionnames are written CamelCase
- Names should be logical, recognizable and should avoid confusion (see below).
- We try to follow the [Noun-verb](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.1) naming for functions

We also make sure that there can be no confusion between parameters and the working of these parameters. This means that your parameters should explicitly be named for what it is. For example; in the `Create-Storage-account.ps1` script there are multiple parameters which are "names". To make sure we know exactly which value to put in which parameter, we've named all parameters as following: `StorageAccountName`, `StorageAccountResourceGroupName`, `ApplicationVnetResourceGroupName`, `ApplicationVnetName`, `ApplicationSubnetName` etc. We couldve named `StorageAccountName` simply: `Name` but this might've been confusing. So always be overly explicit with your parameter names.

### Code conventions checklist
Whenever submitting new scripts, please make sure it is checked against the checklist below.

- Using the `Allman` code formatting with `openBraceOnSameLine` set to false.
- All CLI statements are wrapped into `Invoke-Executable`.
- For CLI statements use full parameter names instead of abbreviations. So `--name` instead of `-n` and `--resource-group` instead of `-g`.
- Be explicit with your script parameter names. As described in the previous paragraph.
- Scripts which are created should not break previous versions unless it's absolutely not possible to create backwards compatibility.
- Parameters for scripts that are mandatory, should be marked as such using the `[Parameter(Mandatory)]` notation.
- Use strongly typed parameters for all script parameters.
- ​Comments should be provided if needed to explain certain workings of the script.
- For every resource that can make use of Managed Identities, these should be created and used (see Create-Web-App-Linux.ps1).
- For every resource that can make use of Diagnostic Settings, these should be enabled and send to the correct LAW. 
- For every resource that can make use of VNet whitelisting and/or Private Endpoints, this should be configurable and added to the script. 
- A wiki page should be added with the following information:
   - Description - Short description of the script and what it does.
   - Parameters - A list of parameters that are used in the scripts, their descriptions, example values and if they're required.
   - YAML - A yaml task that can be copied/pasted into a pipeline.
   - Code - Link to download the script.
   - Links - Links that can be used to get more information about the different scripts.
- The script should've been tested (including for every subresource that it could be used for). 

# Application Gateway
When we started this documentation, we promised eachother to not write anything about individual components. However, since we've chosen to only use the Application Gateway (AppGw) as our edge layer component, we decided it is a good idea to say something revolving this component and it's complexity (and our automation in this). Creating an AppGw is easy, but mastering one is a little harder. We've chosen to create our own SSL Policies for our AppGw's and to automate the hell out of this component due to its complexity (see [the create entrypoint script](../src/AzDocs.Common/public/AppGateway-Helper-Functions.ps1) if you want to know what i'm talking about).

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

Use the [Set-Application-Gateway-SSLTLS-Settings.ps1](../src/Application-Gateway/Set-Application-Gateway-SSLTLS-Settings.ps1) script to set the right SSL & TLS settings for your Application Gateway.

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

# Networking
There are different ways of doing networking within Azure. By default resources will either be public or have an IP Whitelist. By design we don't want to use public resources or use IP whitelists because of the potential insecurities in this. We made the choice to use two different ways of supporting connectivity; VNet whitelisting & Private Endpoint.
The general rule of thumb should be to use VNet whitelisting where applicable. If that's not possible we use private endpoints. If that is unavailable as well, we fallback to public access with plain IP whitelists.
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
Another thing to know when you use private endpoints, in combination with the Azure Private DNS, is that you need to make sure your resources will route all traffic through the VNet. For example: you need to add an [application setting](https://docs.microsoft.com/en-us/azure/app-service/configure-common) to your AppService that defines that you route this traffic through your VNet integration towards the VNet. For AppServices you can do this adding `WEBSITE_VNET_ROUTE_ALL=1` to your application settings (this is done by the AzDocs create webapp scripts for you). This setting will route all outbound traffic through your VNet. For more information, refer to [the microsoft documentation for vnet integration](https://docs.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet)

> NOTE: If you are using a recursive DNS server within your VNet in Azure which is on an addressrange defined in the RFC1918 specification, you don't need to explicitly route all traffic through your VNet.

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

### DNS
> NOTE: This part of the documentation is still under construction. We want to offer a 1-click-solution for the DNS servers.

<font color="red">TODO: This needs an update. When having an on-prem DNS, you will get an issue with calling Azure private endpoints from onprem.</font>

Whenever you use an on-premises DNS server in combination with private endpoints there is a challenge to overcome: When do you resolve DNS entries from onpremises and when from the private endpoint DNS server from Azure itself?
The solution we found that worked best is to create a recursive dns server (a DNS proxy which does the querying for you instead of redirecting your DNS query to the target server). The reason why you want the DNS proxy to do the query itself is because if your resource lives on-premises and you do the DNS request from there, the Azure Private Endpoint DNS Server will return the public IP, since it sees you are NOT within the VNet. This will result in connection not being able to be made.
The technical implementation we have been using is to use bind9 as a DNS server with the following script:
```sh
#!/bin/sh
#
#  only doing all the sudos as cloud-init doesn't run as root, likely better to use Azure VM Extensions
#
#  $1 is the forwarder, $2 is the vnet IP range, $3 is the first dns, $4 is the second dns
#

touch /tmp/forwarderSetup_start
echo "$@" > /tmp/forwarderSetup_params

#  Install Bind9
#  https://www.digitalocean.com/community/tutorials/how-to-configure-bind-as-a-caching-or-forwarding-dns-server-on-ubuntu-14-04
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
sudo apt-get update -y
sudo apt-get install bind9 -y

# configure Bind9 for forwarding
sudo cat > named.conf.options << EndOFNamedConfOptions
acl goodclients {
    $2;
    localhost;
    localnets;
};


options {
        directory "/var/cache/bind";

        recursion yes;

        allow-query { goodclients; };

        forwarders {
            $3;
            $4;
        };
        forward only;

        #dnssec-validation auto;

        auth-nxdomain no;    # conform to RFC1035
        listen-on { any; };
};

zone "azconfig.io" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "azmk8s.io" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "azure.com" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "azure.net" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "azure-api.net" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "azure-automation.net" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "azurecontainer.io" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "azurecr.io" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "azure-devices.net" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "azureedge.net" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "azurefd.net" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "azureml.ms" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "azure-mobile.net" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "azurewebsites.net" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "cloudapp.net" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "msecnd.net" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "onmicrosoft.com" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "signalr.net" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "trafficmanager.net" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "visualstudio.com" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "windows.net" IN {
    type forward;
    forwarders {
        $1;
    };
};
zone "windowsazure.com" IN {
    type forward;
    forwarders {
        $1;
    };
};

EndOFNamedConfOptions

sudo cp named.conf.options /etc/bind
sudo service bind9 restart

sudo apt-get upgrade -y
```

# Logging & Monitoring
*NOTE: This is not the final version of Logging & Monitoring. Several basic measures are in place, but it is not feature complete yet. Our roadmap contains epics to straighten this out.*

For both logging & monitoring we envision that this is included, for the bigger part, in the resource creation scripts. So our goal is that, in the future, you will get dashboards, infra logging & monitoring out of the box using the AzDocs. A good example to explain this is that, whenever you run an App Service, you pretty much always want to know how your app service is doing. So the most basic thing to measure is how high or low your error rate is. And especially: whenever it deviates from the baseline. This means that in our app service creation scripts we could, by default, create alerts & dashboards for error rate basline deviation. And with this specific example, there are more examples you can think of which are generic for all platforms you run (CPU usage, memory usage etc). So in future versions this will be setup for you automatically using the AzDocs scripts.

To run a platform in production, you will need to have eyes & ears everywhere inside and around your platform. We know this and we try to solve this for you as painlessly as possible. We are using Log Analytics Workspace (LAW) as our main logging solution. On a conceptual level, we strive to send all the logs we have to a central LAW instance (one LAW for each `DTAP` stage). For example: you will see `az monitor diagnostic-settings create` commands in "create resource" scripts to send diagnostics to the LAW's as well. At the moment of writing, we attached the following components to the centralized LAW:
 - Application Insights (Application Performance Monitoring & insights for your software stack & dependencies. This means that all your APM information is also sent to the centralized LAW)
 - Diagnostics from resources (Infra level logging)
 - Application Logging with Serilog (See [Application logging to Log Analytics Workspace using Serilog](#application-logging-to-log-analytics-workspace-using-serilog))
 - SQL Auditing logs (see who is connecting to your databases and what is happening)
 - Azure Sentinel (see platform auditing and security & enable alerting on auditing)
 - In addition to the above, we've also added several solution types to the LAW so you can log your IaaS logging to the LAW as well. You can use [Log Analytics Workspace Agents](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/log-analytics-agent) for this

Centralizing the logging means that you can view and correlate (where possible ofcourse) all logging, simply because it is centralized. In our case we've decided to setup a LAW resource for each subscription. So all the resources inside a subscription logs towards the central LAW while still keeping stage separation in place.

For monitoring we use a combination of Azure Monitor & (its subproduct) Application Insights (AppInsights). As of yet we have scripts to enable AppInsights codeless into your webapps. However, we strongly recommend to include AppInsights through nuget into your software, because this simply gives more metrics & information than its codeless counterpart. As for Application Insights, we recommend to create an AppInsights per app stack (so all resources you need to run a specific app platform; log to the same AppInsights to see connections between those components). We've also added scripts to setup alerts from Azure Monitor to, for example, OpsGenie. (See [Create Monitor Action Group](/Azure/Azure-CLI-Snippets/Monitor/Create-Monitor-Action-Group) & [Create Log Alert Rule](/Azure/Azure-CLI-Snippets/Monitor/Create-Log-Alert-Rule)).

## Application logging to Log Analytics Workspace using Serilog
As described in [Logging & Monitoring](#logging-%26-monitoring), we are using Log Analytics Workspace (LAW) as our main logging solution. This also counts for our application logging. We use [Serilog](https://serilog.net/) in our .NET Stacks with the [Serilog Azure Analytics sink](https://github.com/saleem-mirza/serilog-sinks-azure-analytics) for logging our application logs to the LAW.

To provision the logging settings from your pipeline, use these appsettings for your function/appservice (make sure to replace the values accordingly):
```
"Serilog__MinimumLevel=Debug"; "Serilog__WriteTo__1__Name=AzureAnalytics"; "Serilog__WriteTo__1__Args__logName=TheNameOfTheLogYouWant"; "Serilog__WriteTo__1__Args__workspaceId=LogAnalyticsWorkspaceGuid"; "Serilog__WriteTo__1__Args__authenticationId=LogAnalyticsPrimaryKey"; "Serilog__WriteTo__2__Args__restrictedToMinimumLevel=Information"; "Serilog__WriteTo__2__Args__telemetryConverter=Serilog.Sinks.ApplicationInsights.Sinks.ApplicationInsights.TelemetryConverters.TraceTelemetryConverter, Serilog.Sinks.ApplicationInsights"; "Serilog__WriteTo__2__Name=ApplicationInsights"; "Serilog__Using__2=Serilog.Sinks.ApplicationInsights"; "Serilog__Using__1=Serilog.Sinks.AzureAnalytics";
```

The above will make sure that your application logging will also be sent to the central LAW.

# Deprovisioning
*NOTE: This is not the final version of Deprovisioning. Our roadmap contains epics to straighten this out.*

From a conceptual point of view, you want to keep your costs as low as possible. This means that somehow we need to make sure we don't run resources which we simply don't need. An easy way to do this, is to deprovision non-prod resource(s/groups) whenever you don't need them. At the point of writing we don't have anything in the AzDocs yet to do this, but we've created some deprovisioning pipelines which throw away resourcegroups at the end of the workday whenever they have been spun up.

Find more information on how to [create scheduled pipelines here](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/scheduled-triggers). In the next subparagraphs we will try to describe this as brief as possible.

## YAML Pipelines
As said, the easiest way to do this is to simply delete the resourcegroup in your `dev` or `acc` environment. To achieve this in YAML pipelines, add the following template to run it every workday (monday to friday) 

```yaml
schedules:
- cron: "0 19 * * Mon-Fri"
  displayName: M-F 19:00 UTC
  branches:
    exclude:
      - nonexistingbranch

pool:
  vmImage: ubuntu-latest

variables:
  ResourceGroupName: 'MyResourceGroup-Dev'

steps:
- task: AzureCLI@1
  displayName: 'Remove Resource Group'
  inputs:
    azureSubscription: 'MySubscription'
    scriptLocation: inlineScript
    inlineScript: 'az group delete --name "$(ResourceGroupName)" --yes'
```

## Classic Release Pipelines
To create a classic pipeline which triggers at the end of the day, you can use the `Schedule set` option in the `Pipeline` tab when editing your release definition to set the schedule. See the screenshot below (*NOTE: make sure to set the `Only schedule releases if the source or pipeline has changes` to avoid it running unnecessary*):

![Set scheduled release trigger](../wiki_images/classic_pipeline_scheduled_deprovision_trigger.png)

# Clearing unintended whitelists
*NOTE: This is not the final version of Clearing unintended whitelists. Our roadmap contains epics to straighten this out.*

To keep security & compliancy in place, we need to make sure that we don't add IP's to our whitelists temporarily, and then forgetting about them. At the point of writing we don't have anything in the AzDocs yet, but we will look into this in the future. So for now, make sure you do check this from time to time.