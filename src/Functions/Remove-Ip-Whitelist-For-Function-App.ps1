[CmdletBinding()]
param (
    [Alias("ResourceGroupName")]
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Alias("RuleName")]
    [Parameter(Mandatory)][string] $AccessRestrictionRuleName,
    [Parameter()][string] $FunctionAppDeploymentSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($ApplyToAllSlots)
{
    $availableSlots = Invoke-Executable -AllowToFail az functionapp deployment slot list --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json
}

Remove-AccessRestriction -AppType functionapp -ResourceGroupName $FunctionAppResourceGroupName -ResourceName $FunctionAppName -AccessRestrictionRuleName $AccessRestrictionRuleName -DeploymentSlotName $FunctionAppDeploymentSlotName

# Apply to all slots if desired
foreach($availableSlot in $availableSlots)
{
    Remove-AccessRestriction -AppType functionapp -ResourceGroupName $FunctionAppResourceGroupName -ResourceName $FunctionAppName -AccessRestrictionRuleName $AccessRestrictionRuleName -DeploymentSlotName $availableSlot.name
}

Write-Footer -ScopedPSCmdlet $PSCmdlet