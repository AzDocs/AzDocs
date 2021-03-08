[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppServicePlanName,
    [Parameter(Mandatory)][string] $AppServicePlanResourceGroupName,
    [Parameter(Mandatory)][string] $AppServicePlanSkuName,
    [Parameter()][string] $AppServicePlanNumberOfWorkerInstances = 3,
    [Parameter(Mandatory)][System.Object[]] $ResourceTags
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Create AppService Plan
$appServicePlanId = (Invoke-Executable az appservice plan create --resource-group $AppServicePlanResourceGroupName --per-site-scaling --number-of-workers $AppServicePlanNumberOfWorkerInstances --name $AppServicePlanName --sku $AppServicePlanSkuName --tags ${ResourceTags} | ConvertFrom-Json).id

Write-Footer -ScopedPSCmdlet $PSCmdlet

Write-Output $appServicePlanId