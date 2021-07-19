[[_TOC_]]

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

![Set scheduled release trigger](../../../../wiki_images/classic_pipeline_scheduled_deprovision_trigger.png)
