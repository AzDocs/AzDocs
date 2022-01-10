[[_TOC_]]

# Setup Dependabot in Azure Devops

Dependabot is a tool that can be used to be able to automatically check the dependencies of your projects on updates.
If there are updates, dependabot will notify you and create a pull request with the updated dependencies.

This README.md will give you instructions on how to add a dependabot integration to your Azure Devops organization.
For the github implementation, go to: [Github dependabot](https://docs.github.com/en/code-security/supply-chain-security/keeping-your-dependencies-updated-automatically/enabling-and-disabling-dependabot-version-updates)

## Getting Started

To be able to run Dependabot with Azure Devops, we've made use of two extensions:

### Dependabot extension

Install this [extension](https://marketplace.visualstudio.com/items?itemName=tingle-software.dependabot) into your Azure Devops organization.

### Workitem extension

This is an optional extension that can be used to automatically create workitems on the board you've specified.
If you want to make use of this, install this [extension](https://marketplace.visualstudio.com/items?itemName=mspremier.CreateWorkItem)

### Setup

After you've installed the above extensions, create a new repository in your project and copy the files from `Tools/Dependabot/dependabot-orchestrator.yml` and `Tools/Dependabot/dependabot-pipeline.yml`.

### OPTIONAL: Workitem

This task is optional and if used, will create a workitem for you on your azure devops board.
When using this extension, make sure to update the values `area-path` and `iteration-path`:

```yaml
- task: CreateWorkItem@1
  displayName: "Create User Story for Dependabot"
  inputs:
    workItemType: "User Story"
    title: "Update Dependencies"
    fieldMappings: |
      Tags=dependabot; dependencies
    areaPath: "<area-path>"
    iterationPath: "<iteration-path>"
    preventDuplicates: true
    keyFields: |
      System.AreaPath
      System.IterationPath
      System.Title
    createOutputs: true
    outputVariables: |
      workItemId=ID
```

Both values can be found by going to your project and choosing `Project Settings` > `Project configuration` > `Iterations` and `Project Settings` > `Project configuration` > `Areas`.

### Environment variables

Add the following environment variables:

- `PATForAzureDevops`- Generate a PAT with the permissions: Code (Full) and Pull Requests Threads (Read & Write).
- If using a private nuget feed, add `PATForNugetFeed`. Generate a PAT with Read permissions for Packaging. The PAT should be generated with a user that has permissions to access the feed either directly or via a group. _As mentioned in the pipeline, the ':' at the end of the token is deliberate. Please see ticket: https://github.com/tinglesoftware/dependabot-azure-devops/issues/50_

### Private Nuget Feed

If your projects makes use of your own private nuget feeds (Azure Artifacts), make sure to:

- Add the environment variable defined above (`PATForNugetFeed`).
- Fill in the variable `privateNugetFeedUrl`. Your nuget feed url can be found by going to `Artifacts` > `Connect to feed` > `dotnet`.

### Repositories

At the end of the pipeline, the template `dependabot-pipeline.yml` is being called.

```yaml
       - template: dependabot-pipeline.yml
            parameters:
              Repositories:
                - Repository: "repository-1"
                - Repository: "repository-2"
                  Directory: "/src"
```

This template will be used to run the dependabot against multiple repositories. The repositories can be specified by adding them to Repositories parameter.

If no `Directory` is provided, the root of the repository will be used.

### Debugging

If something goes wrong, be sure to enable debugging for the dependabot task. This can be done by adding the following environment variable to the property `extraEnvironmentVariables` (these are delimited by a `;`):

```yaml
extraEnvironmentVariables: EXCON_DEBUG=1;
```

Extra logging will be provided in the pipeline, which can help you to figure out what is wrong.

# Links

These pipelines have been based on the below link from Rick Roché:

- [Azure pipelines and dependabot](https://www.rickroche.com/2021/05/azure-pipelines-and-dependabot/)

The github for the dependabot extension:

- [Dependabot Azure Devops](https://github.com/tinglesoftware/dependabot-azure-devops)
