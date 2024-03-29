[[_TOC_]]

# Regression Tests

_NOTE: This is not the final version of Regression Test chapter. Several basic components are in place, but it is not feature complete yet. Our roadmap contains epics to straighten this out._

When creating a boilerplate like this, you want a way to test the changes you make. We faced the same question and created a fitting answer. We've created a pipeline which tests all the resources & configurations automatically after each AzDocs change. It is designed in a way that you can use this pipeline in your own environment and, with a few variables you have to add to the pipeline, create your own test environment.

As said we've created a pipeline which calls all of the scripts we have (WIP). This repository also contains a C# API project which has a few features like "testing connections to databases", "testing storage accounts" and "testing cache providers". The idea is that we not only test the scripts, but also the connectivity & features of the created resources from other resources. This way we can verify that the resources and their connectivity works as designed.

## Setup the regression test pipeline in your environment

It's fairly easy to setup the regression test pipeline in your own environment. Theres a few things you have to do to get it running.

### Setup the AZDOCSREGRESSIONTESTSUBSCRIPTION service connection

First of all you need to add a `Azure Resource Manager` service connection to your AzDocs teamproject. This service connection will be a reference to your Azure Subscription where you want to deploy the regression tests. Please refer to [this link](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml) for details on how to setup such a service connection. Important note is that for this service connection, the `service connection name` has to be `AZDOCSREGRESSIONTESTSUBSCRIPTION`. Unfortunately we had to statically name this is due to a technical limitation in Azure DevOps. It's technically impossible to enter a pipeline variable to be used as your subscription name in Azure CLI steps.

### Application Gateway certificate information

Before starting the next [Import the Regression Tests pipeline](#import-the-regression-tests-pipeline) chapter, make sure you have a domainname you can use for this testpipeline. We will use `something.mycompany.com` as an example. This value will be the `GatewayIngressDomainName`. You will need a matching certificate for this domainname (a wildcard certificate suffices). This certificate (in pfx format) has to be added to the secure files of your AzDocs Azure DevOps Team Project. Please refer to [this page](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/secure-files?view=azure-devops) on how to add such a secure file. The value for the `GatewayCertificateSecureFileName` will be `something.mycompany.com.pfx` in our example. And last but not least, you will need the matching `GatewayCertificatePassword` for this secure file.

### Import the Regression Tests pipeline

_Make sure to have followed the steps in [Setup the AZDOCSREGRESSIONTESTSUBSCRIPTION service connection](#setup-the-azdocsregressiontestsubscription-service-connection) and [Application Gateway certificate information](#application-gateway-certificate-information)_

After setting the above connection up and getting the certificate information ready, we need to import the pipeline from the upstream repo's into our `Pipelines` module in Azure DevOps.

Follow these steps to get it done:

1. In your AzDocs team project, go to `Pipelines` and then click `New Pipeline`.

![Regression pipeline setup](../../../../wiki_images/azdo_regression_pipeline_1.png)

2. Select `Azure Repos Git` as the source provider.

![Regression pipeline setup](../../../../wiki_images/azdo_regression_pipeline_2.png)

3. Select the Generic/Upstream repository.

![Regression pipeline setup](../../../../wiki_images/azdo_regression_pipeline_3.png)

4. Select `Existing Azure Pipelines YAML file`.

![Regression pipeline setup](../../../../wiki_images/azdo_regression_pipeline_4.png)

5. From the `Path` dropdown, select `/tests/Test.Regression/pipeline-orchestrator.yml` and click `Continue`.

![Regression pipeline setup](../../../../wiki_images/azdo_regression_pipeline_5.png)

6. In the next screen, click `Variables` in the right top corner.

![Regression pipeline setup](../../../../wiki_images/azdo_regression_pipeline_6.png)

7. Click the `New Variable` button in the popup.

![Regression pipeline setup](../../../../wiki_images/azdo_regression_pipeline_7.png)

8. For the name enter `AzDocsBranch`. For the value enter `master`. Make sure you enable `Let users override this value when running this pipeline`. This will allow you to select different AzDocs branches to test later when running your pipeline.

![Regression pipeline setup](../../../../wiki_images/azdo_regression_pipeline_8.png)

9. Click the `+` button in the right top corner of the popup.

![Regression pipeline setup](../../../../wiki_images/azdo_regression_pipeline_9.png)

10. For the name enter `AzDocsBuildDefinitionId`. Please refer to [How to use the scripts](/Azure/AzDocs-v1/General-Documentation/How-to-use-the-scripts#getting-the-azdocs-build-information) for getting the correct value. Click `Ok` to add the variable.

![Regression pipeline setup](../../../../wiki_images/azdo_regression_pipeline_10.png)

11. Repeat step 9 and then enter `GatewayCertificatePassword` for the name. For the value, refer to the [Application Gateway certificate information](#application-gateway-certificate-information) chapter. Make sure to enable the `Keep this value secret` checkbox. Click `Ok` to add the variable.

![Regression pipeline setup](../../../../wiki_images/azdo_regression_pipeline_11.png)

12. Repeat steps 9 & 10 for the following variables:

- Name `GatewayIngressDomainName`. For the value, refer to the [Application Gateway certificate information](#application-gateway-certificate-information) chapter.
- Name `GatewayCertificateSecureFileName`. For the value, refer to the [Application Gateway certificate information](#application-gateway-certificate-information) chapter.
- Name `CompanyName` with value `MyCompany` (Replace with your company name. Max 9 characters. Stick to alphanumeric). This company name will avoid collisions with resource namings from other companies, so choose something unique.
- Name `AzDocsTeamProjectId`. Please refer to [How to use the scripts](/Azure/AzDocs-v1/General-Documentation/How-to-use-the-scripts#getting-the-azdocs-build-information) for getting the correct value.

Your variables screen should look like the image below. Click `Save` in the right bottom corner of the popup.

![Regression pipeline setup](../../../../wiki_images/azdo_regression_pipeline_12.png)

13. Click `Run` in the top right corner to start the pipeline run. This will start the full run.

14. Make sure to throw away the resulting resource group to avoid high unnecessary costs.

## Setup Test.Api and Playwright tests

If you have followed above steps and created the regression pipeline and ran the scripts, you have also probably deployed the C# API project (Test.Api) that was included in this repository to the WebApp that you deployed. When all scripts have run and you want to have a quick way of verifying that on a higher level the connectivity & features of the created resources are reachable from other resources, you can use the [Playwright](https://playwright.dev/) tests that are also included in this repository.
The playwright tests will run against the API site you deployed and run tests against a couple of endpoints, eg. a blob storage. In short this is what you need in a classic pipeline to set these tests up:

1. Make sure that in your release, you have the artifact available containing the TestApiTests. In the repository it is in the folder TestApiTests:

![Regression pipeline setup](../../../../wiki_images/azdo_regression_testapi_playwright_1.png)

2. Make sure you have the artifact available for the test.runsettings, attached to your release. In the repository it is in the folder TestApiTests.

![Regression pipeline setup](../../../../wiki_images/azdo_regression_testapi_playwright_2.png)

3. Create an agent job with 3 tasks:

![Regression pipeline setup](../../../../wiki_images/azdo_regression_testapi_playwright_3.png)

4. Contents of the Prepare Playwright env Powershell task:

```
#following the steps in https://playwright.dev/dotnet/docs/intro/

#your path to the artifact TestApiTests
cd $(System.DefaultWorkingDirectory)/Tests/Tests.Regression/TestApiTests/

dotnet tool install --global Microsoft.Playwright.CLI
dotnet add package Microsoft.Playwright
dotnet build

#playwright install

if($isLinux){
  playwright install-deps
  npx playwright install
}else{
  #windows host
  playwright install
}
```

5. Contents of the update test.runsettings file (with your specific evironment details):

```
#path to the test.runsettings file
$path = '$(System.DefaultWorkingDirectory)/Tests/Tests.Regression/testrunsettings/test.runsettings'

$text = Get-Content $path
$newText = $text.replace('admin','your.admin@email.com').Replace('password','yourpassword').Replace('http://localhost','your_BaseUriOfAPI')
$newText | out-file -FilePath $path -Force
```

6. Content of the dotnet test task
   ![Regression pipeline setup](../../../../wiki_images/azdo_regression_testapi_playwright_4.png)

_NOTE: if you want to run the tests on a hosted Linux server you need to run the dotnet test with an extra option --configuration "release"._

7. Save and run the release

8. Find output in Azure DevOps under Test Plans/Runs

![Regression pipeline setup](../../../../wiki_images/azdo_regression_testapi_playwright_5.png)

### Further TODOs

Example of a YAML version of the playwright test steps will follow soon. In the near future we will make sure to extend the amount of scripts being covered by the tests.
