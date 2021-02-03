[CmdletBinding()]
param (
    [Alias("ResourceGroupName")]
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Alias("RuleName")]
    [Parameter(Mandatory)][string] $AccessRestrictionRuleName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az webapp config access-restriction remove --resource-group $AppServiceResourceGroupName --name $AppServiceName --rule-name $AccessRestrictionRuleName --scm-site $true
Invoke-Executable az webapp config access-restriction remove --resource-group $AppServiceResourceGroupName --name $AppServiceName --rule-name $AccessRestrictionRuleName --scm-site $false

Write-Footer