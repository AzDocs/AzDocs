[[_TOC_]]

# Deprovisioning
From a conceptual point of view, you want to keep your costs as low as possible. This means that somehow we need to make sure we don't run resources which we simply don't need. An easy way to do this, is to deprovision non-prod resource(s/groups) whenever you don't need them. We've created a way to deprovisioning your resourcegroups at the end of the workday whenever they have been spun up.

One way is to use a scheduled pipeline in which you would deprovision a resourcegroup.

Another way would be to integrate this deletion as a separate stage in your regression pipeline.
## YAML Pipelines

### Integrate deprovisioning in your regression pipeline
The idea is that you spin up all the resources in your regression pipeline, do the automated checks (unittests, functional tests), publish the results and then deprovision the resources where you can decide to leave or remove the resources depending on the results.

For this we created the Remove ResourceGroup script in AzDocs [Click here to download this script](../../../src/Resourcegroup/Remove-ResourceGroup.ps1) and added this script as a separate stage to the pipeline-release.yml

``` yaml

 #new stage with the deletion of the resourcegroup
  - stage: DeleteRG
    displayName: ${{ format('Delete RG from {0}', parameters.EnvironmentName) }}
    pool:
      vmImage: $(Stage.Pool)
    variables:
      # Basic
      - name: Location
        value: westeurope
      - name: DeployInfra
        value: "${{ parameters.DeployInfra }}"
      - name: ResourceBaseName
        value: $(CompanyName)-$(ProjectName)
      - name: ResourceGroupName
        value: $(ResourceBaseName)-${{ parameters.EnvironmentName }}

    jobs:
      - deployment: DeployDeleteRG
        displayName: Delete Resource Group
        environment:
          name: ${{ parameters.EnvironmentName }}
        timeoutInMinutes: 360
        cancelTimeoutInMinutes: 1
        strategy:
          runOnce:
            deploy:
              steps:
                # ========================================= DOWNLOAD AZDOCS =========================================
                - task: DownloadPipelineArtifact@2
                  displayName: Download AzDocs
                  condition: eq(variables['ResourceDeletion.ResourceGroup.Enabled'], 'true')
                  inputs:
                    buildType: specific
                    project: $(AzDocsTeamProjectId)
                    definition: $(AzDocsBuildDefinitionId)
                    buildVersionToDownload: latestFromBranch
                    branchName: "refs/heads/feature/deprovision"
                    artifactName: azdocs-src
                    targetPath: $(Pipeline.Workspace)/AzDocs
                # ========================================= DELETE RESOURCEGROUP =========================================
                - task: AzureCLI@2
                  displayName: "Delete ResourceGroup"
                  condition: eq(variables['ResourceDeletion.ResourceGroup.Enabled'], 'true')
                  inputs:
                    azureSubscription: "${{ parameters.SubscriptionName }}"
                    scriptType: pscore
                    scriptPath: "$(Pipeline.Workspace)/AzDocs/Resourcegroup/Remove-ResourceGroup.ps1"
                    arguments: "-ResourceGroupName '$(ResourceGroupName)'"
```

### Use a scheduled pipeline
As said, one way to do deprovisioning is to simply delete the resourcegroup in your `dev` or `acc` environment. To achieve this in YAML pipelines, add the following template to run it every day. Find more information on how to [create scheduled pipelines here](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/scheduled-triggers).
The downside is that you need to know which resourcegroup name you used for the resources that have been spun up in your regression pipeline.

```yaml
name: $(date:yyyy.MM.dd)$(rev:.r)-$(Build.SourceBranchName)
trigger: none

#Schedules must be specified in the main YAML file and not in template files.
schedules:
- cron: "00 00 * * Mon,Tue,Wed,Thu,Fri,Sat,Sun" # schedule is UTC
  displayName: Delete ResourceGroup on schedule
  branches:
    #include: [ string ] # which branches the schedule applies to. If you specify an exclude clause without an include clause for branches, it is equivalent to specifying * in the include clause.
    exclude:
      - nonexistingbranch
  always: true #whether to always run the pipeline or only if there have been source code changes since the last successful scheduled run. The default is false.

pool:
  vmImage: ubuntu-latest

variables:
  ResourceGroupName: 'myResourceGroupDev' #You cannot use pipeline variables when specifying schedules.

steps:
- task: AzureCLI@1
  displayName: 'Remove Resource Group'
  inputs:
    azureSubscription: 'MySubscription'
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Resourcegroup/Remove-ResourceGroup.ps1"
    arguments: "-ResourceGroupName '$(ResourceGroupName)'"
```

## Classic Release Pipelines
To create a classic pipeline which triggers at the end of the day, you can use the `Schedule set` option in the `Pipeline` tab when editing your release definition to set the schedule. See the screenshot below (*NOTE: make sure to set the `Only schedule releases if the source or pipeline has changes` to avoid it running unnecessary*):

![Set scheduled release trigger](../../../../wiki_images/classic_pipeline_scheduled_deprovision_trigger.png)
