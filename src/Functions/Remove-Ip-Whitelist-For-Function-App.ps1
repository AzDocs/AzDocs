[CmdletBinding()]
param (
    [Alias("ResourceGroupName")]
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Alias("RuleName")]
    [Parameter(Mandatory)][string] $AccessRestrictionRuleName,
    [Parameter()][string] $FunctionAppDeploymentSlotName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\Whitelisting-Helper-Functions.ps1"
#endregion ===END IMPORTS===

Write-Header

Remove-AccessRestriction -AppType functionapp -ResourceGroupName $FunctionAppResourceGroupName -ResourceName $FunctionAppName -AccessRestrictionRuleName $AccessRestrictionRuleName -DeploymentSlotName $FunctionAppDeploymentSlotName

Write-Footer