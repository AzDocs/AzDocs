[CmdletBinding()]
param (
    [Alias("ResourceGroupName")]
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Alias("RuleName")]
    [Parameter(Mandatory)][string] $AccessRestrictionRuleName,
    [Parameter()][string] $AppServiceDeploymentSlotName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\Whitelisting-Helper-Functions.ps1"
#endregion ===END IMPORTS===

Write-Header

Remove-AccessRestriction -AppType webapp -ResourceGroupName $AppServiceResourceGroupName -ResourceName $AppServiceName -AccessRestrictionRuleName $AccessRestrictionRuleName -DeploymentSlotName $AppServiceDeploymentSlotName

Write-Footer