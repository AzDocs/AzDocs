[CmdletBinding()]
param (
    [Alias("ResourceGroupName")]
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter()][string] $AccessRestrictionRuleName,
    [Parameter()][string] $AccessRestrictionRuleDescription,
    [Alias("IpRangeToWhitelist")]
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})\/(?:\d{1,2})$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist,
    [Parameter()][string] $AppServiceDeploymentSlotName,
    [Parameter()][string] $AccessRestrictionAction = "Allow",
    [Parameter()][string] $Priority = 10,
    [Parameter()][bool] $ApplyToAllSlots = $false,
    [Parameter()][bool] $ApplyToMainEntrypoint = $true,
    [Parameter()][bool] $ApplyToScmEntrypoint = $true
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if(!$CIDRToWhitelist)
{
    $response  = Invoke-WebRequest 'https://ipinfo.io/ip'
    $CIDRToWhitelist = $response.Content.Trim() + '/32'
}

if ($ApplyToAllSlots)
{
    $availableSlots = Invoke-Executable -AllowToFail az webapp deployment slot list --name $AppServiceName --resource-group $AppServiceResourceGroupName | ConvertFrom-Json
    if($AppServiceDeploymentSlotName)
    {
        $availableSlots = $availableSlots | Where-Object { $_.name -ne $AppServiceDeploymentSlotName }
    }
}

if(!$AccessRestrictionRuleName)
{
    $AccessRestrictionRuleName = ($CIDRToWhitelist -replace "\.", "-") -replace "/", "-"
}

Add-AccessRestriction -AppType webapp -ResourceGroupName $AppServiceResourceGroupName -ResourceName $AppServiceName -AccessRestrictionRuleName $AccessRestrictionRuleName -CIDRToWhiteList $CIDRToWhiteList -AccessRestrictionAction $AccessRestrictionAction -Priority $Priority -DeploymentSlotName $AppServiceDeploymentSlotName -AccessRestrictionRuleDescription $AccessRestrictionRuleDescription -ApplyToMainEntrypoint $ApplyToMainEntrypoint -ApplyToScmEntrypoint $ApplyToScmEntrypoint

# Apply to all slots if desired
foreach($availableSlot in $availableSlots)
{
    Add-AccessRestriction -AppType webapp -ResourceGroupName $AppServiceResourceGroupName -ResourceName $AppServiceName -AccessRestrictionRuleName $AccessRestrictionRuleName -CIDRToWhiteList $CIDRToWhiteList -AccessRestrictionAction $AccessRestrictionAction -Priority $Priority -DeploymentSlotName $availableSlot.name -AccessRestrictionRuleDescription $AccessRestrictionRuleDescription -ApplyToMainEntrypoint $ApplyToMainEntrypoint -ApplyToScmEntrypoint $ApplyToScmEntrypoint
}

Write-Footer -ScopedPSCmdlet $PSCmdlet