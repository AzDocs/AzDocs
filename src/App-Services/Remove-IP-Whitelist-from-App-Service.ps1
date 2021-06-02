[CmdletBinding()]
param (
    [Alias("ResourceGroupName")]
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Alias("RuleName")]
    [Parameter()][string] $AccessRestrictionRuleName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToRemoveFromWhitelist,
    [Parameter()][string] $AppServiceDeploymentSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false,
    [Parameter()][bool] $ApplyToMainEntrypoint = $true,
    [Parameter()][bool] $ApplyToScmEntrypoint = $true
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if(!$CIDRToRemoveFromWhitelist -and !$AccessRestrictionRuleName)
{
    $response  = Invoke-WebRequest 'https://ipinfo.io/ip'
    $CIDRToRemoveFromWhitelist = $response.Content.Trim() + '/32'
}

if ($ApplyToAllSlots)
{
    $availableSlots = Invoke-Executable -AllowToFail az webapp deployment slot list --name $AppServiceName --resource-group $AppServiceResourceGroupName | ConvertFrom-Json
    if($AppServiceDeploymentSlotName)
    {
        $availableSlots = $availableSlots | Where-Object { $_.name -ne $AppServiceDeploymentSlotName }
    }
}

Remove-AccessRestriction -AppType webapp -ResourceGroupName $AppServiceResourceGroupName -ResourceName $AppServiceName -AccessRestrictionRuleName $AccessRestrictionRuleName -CIDRToRemove $CIDRToRemoveFromWhitelist -DeploymentSlotName $AppServiceDeploymentSlotName -ApplyToMainEntrypoint $ApplyToMainEntrypoint -ApplyToScmEntrypoint $ApplyToScmEntrypoint

# Apply to all slots if desired
foreach($availableSlot in $availableSlots)
{
    Remove-AccessRestriction -AppType webapp -ResourceGroupName $AppServiceResourceGroupName -ResourceName $AppServiceName -AccessRestrictionRuleName $AccessRestrictionRuleName -CIDRToRemove $CIDRToRemoveFromWhitelist -DeploymentSlotName $availableSlot.name -ApplyToMainEntrypoint $ApplyToMainEntrypoint -ApplyToScmEntrypoint $ApplyToScmEntrypoint
}

Write-Footer -ScopedPSCmdlet $PSCmdlet