[CmdletBinding()]
param (
    [Alias("ResourceGroupName")]
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Parameter()][string] $AccessRestrictionRuleName,
    [Parameter()][string] $AccessRestrictionRuleDescription,
    [Alias("IpRangeToWhitelist")]
    [Parameter()][ValidatePattern('^(?:(?:\d{1,3}.){3}\d{1,3})\/(?:\d{1,2})$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist,
    [Parameter()][string] $FunctionAppDeploymentSlotName,
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
    $availableSlots = Invoke-Executable -AllowToFail az functionapp deployment slot list --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json
}

if(!$AccessRestrictionRuleName)
{
    $AccessRestrictionRuleName = ($CIDRToWhitelist -replace "\.", "-") -replace "/", "-"
}

Add-AccessRestriction -AppType functionapp -ResourceGroupName $FunctionAppResourceGroupName -ResourceName $FunctionAppName -AccessRestrictionRuleName $AccessRestrictionRuleName -CIDRToWhiteList $CIDRToWhiteList -AccessRestrictionAction $AccessRestrictionAction -Priority $Priority -DeploymentSlotName $FunctionAppDeploymentSlotName -AccessRestrictionRuleDescription $AccessRestrictionRuleDescription -ApplyToMainEntrypoint $ApplyToMainEntrypoint -ApplyToScmEntrypoint $ApplyToScmEntrypoint

# Apply to all slots if desired
foreach($availableSlot in $availableSlots)
{
    Add-AccessRestriction -AppType functionapp -ResourceGroupName $FunctionAppResourceGroupName -ResourceName $FunctionAppName -AccessRestrictionRuleName $AccessRestrictionRuleName -CIDRToWhiteList $CIDRToWhiteList -AccessRestrictionAction $AccessRestrictionAction -Priority $Priority -DeploymentSlotName $availableSlot.name -AccessRestrictionRuleDescription $AccessRestrictionRuleDescription -ApplyToMainEntrypoint $ApplyToMainEntrypoint -ApplyToScmEntrypoint $ApplyToScmEntrypoint
}

Write-Footer -ScopedPSCmdlet $PSCmdlet