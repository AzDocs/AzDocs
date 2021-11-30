<#
.SYNOPSIS
    Create a template from a dashboard.
.DESCRIPTION
    Create a template from a dashboard. The TagValueDictionary parameter should contain a list of regex names with a value to replace with. See also the examples
.EXAMPLE
    PS C:\> .\Get-DashboardTemplate.ps1 -ResourceGroupNameDashboard 'MyResourceGroup' -DashboardName 'MyFirstDashboard' -TemplateFilePath 'Template.json' -TagValueDictionary ([ordered]@{'###SubscriptionId###'='f5b5eb5d-f95a-49ed-bde3-c5ad5f6c4c43'})
    This command stores the selected Dashboard to the file Template.json. The selected dashboard is from  the Azure ResourceGroup 'MyResourceGroup' with the dashboard name 'MyFirstDashboard'. It replaces all occurences of 'f5b5eb5d-f95a-49ed-bde3-c5ad5f6c4c43' to '###SubscriptionId###'.
    The last bit is for creating a dashboard from this template. Then you need to replace '###SubscriptionId###' with the subscription id that you want to use.
.INPUTS
    Inputs (if any)
.OUTPUTS
    Path of the template file
#>
[CmdletBinding()]
param (
    [Parameter()][System.Collections.Specialized.OrderedDictionary] $TagValueDictionary,
    [Parameter(Mandatory)][string] $DashboardResourceGroupName,
    [Parameter(Mandatory)][string] $DashboardName,
    [Parameter(Mandatory)][string] $TemplateFilePath
)
#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Write-Host 'Check if the portal extension is installed'
$portalExtension = az extension list | ConvertFrom-Json | Where-Object name -EQ 'portal'
if (!$portalExtension)
{
    Write-Host 'Need to install the portal extension'
    Invoke-Executable az extension add --upgrade --name portal --yes
    Write-Host 'Portal extension installed'
}

Write-Host 'Fetching dashboard from Azure'
$fileContent = Invoke-Executable az portal dashboard show --name $DashboardName --resource-group $DashboardResourceGroupName | Out-String
Write-Host 'Dashboard fetched'

Write-Host 'Creating template from dashboard'
$TagValueDictionary.Keys | ForEach-Object {       
    $key = $_
    $value = $TagValueDictionary[$key]
    Write-Debug "Replacing $value with $key"
    $fileContent = $fileContent -creplace $value, $key
}
Write-Host 'Template Created'

Write-Host 'Writing template to file'
$fileContent | Out-File $TemplateFilePath
Write-Output $TemplateFilePath
Write-Host 'Template complete'

Write-Footer -ScopedPSCmdlet $PSCmdlet