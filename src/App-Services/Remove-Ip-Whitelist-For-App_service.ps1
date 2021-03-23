[CmdletBinding()]
param (
    [Alias("ResourceGroupName")]
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Alias("RuleName")]
    [Parameter(Mandatory)][string] $AccessRestrictionRuleName,
    [Parameter()][string] $AppServiceDeploymentSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($ApplyToAllSlots)
{
    $availableSlots = Invoke-Executable -AllowToFail az webapp deployment slot list --name $AppServiceName --resource-group $AppServiceResourceGroupName | ConvertFrom-Json
}

Remove-AccessRestriction -AppType webapp -ResourceGroupName $AppServiceResourceGroupName -ResourceName $AppServiceName -AccessRestrictionRuleName $AccessRestrictionRuleName -DeploymentSlotName $AppServiceDeploymentSlotName

foreach($availableSlot in $availableSlots)
{
    Remove-AccessRestriction -AppType webapp -ResourceGroupName $AppServiceResourceGroupName -ResourceName $AppServiceName -AccessRestrictionRuleName $AccessRestrictionRuleName -DeploymentSlotName $availableSlot.name
}

Write-Footer -ScopedPSCmdlet $PSCmdlet