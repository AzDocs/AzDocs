[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] [ValidateSet('functionapp', 'webapp')]$AppType,
    [Parameter(Mandatory)][string] $ResourceGroupName,
    [Parameter(Mandatory)][string] $ResourceName,
    [Parameter(Mandatory)][string] $AccessRestrictionRuleName,
    [Parameter(Mandatory)][string] $ServiceTag, 
    [Parameter()][string] $ServiceTagHttpHeaders,
    [Parameter()][string] $AccessRestrictionRuleDescription,
    [Parameter()][string] $DeploymentSlotName,
    [Parameter()][string] $AccessRestrictionAction = 'Allow',
    [Parameter()][string] $Priority = 10,
    [Parameter()][bool] $ApplyToMainEntrypoint = $true,
    [Parameter()][bool] $ApplyToScmEntrypoint = $true,
    [Parameter()][bool] $ApplyToAllSlots = $true
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Check apply to all slots
if ($ApplyToAllSlots)
{
    Write-Host 'Applying the whitelist to all slots'
    $availableSlots = Invoke-Executable -AllowToFail az $AppType deployment slot list --name $ResourceName --resource-group $ResourceGroupName | ConvertFrom-Json
    if ($DeploymentSlotName)
    {
        $availableSlots = $availableSlots | Where-Object { $_.name -ne $DeploymentSlotName }
    }
}

Add-AccessRestriction -AccessRestrictionRuleName $AccessRestrictionRuleName -AppType $AppType -ResourceGroupName $ResourceGroupName -ResourceName $ResourceName -AutoGeneratedAccessRestrictionRuleName $false -ServiceTag $ServiceTag -ServiceTagHttpHeaders $ServiceTagHttpHeaders -ApplyToMainEntrypoint $ApplyToMainEntrypoint -ApplyToScmEntrypoint $ApplyToScmEntrypoint

# Apply to all slots if desired
foreach ($availableSlot in $availableSlots)
{
    Add-AccessRestriction -AccessRestrictionRuleName $AccessRestrictionRuleName -AppType $AppType -ResourceGroupName $ResourceGroupName -ResourceName $ResourceName -AutoGeneratedAccessRestrictionRuleName $false -ServiceTag $ServiceTag -ServiceTagHttpHeaders $ServiceTagHttpHeaders -DeploymentSlotName $availableSlot.name -ApplyToMainEntrypoint $ApplyToMainEntrypoint -ApplyToScmEntrypoint $ApplyToScmEntrypoint
}

Write-Footer -ScopedPSCmdlet $PSCmdlet