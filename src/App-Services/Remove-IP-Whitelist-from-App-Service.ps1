[CmdletBinding()]
param (
    [Alias("ResourceGroupName")]
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter()][string] $AccessRestrictionRuleName,
    [Parameter()][ValidatePattern('^(?:(?:\d{1,3}.){3}\d{1,3})\/(?:\d{1,2})$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToRemoveFromWhitelist,
    [Parameter()][string] $AppServiceDeploymentSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if(!$CIDRToRemoveFromWhitelist)
{
    $response  = Invoke-WebRequest 'https://ipinfo.io/ip'
    $CIDRToRemoveFromWhitelist = $response.Content.Trim() + '/32'
}

if ($ApplyToAllSlots)
{
    $availableSlots = Invoke-Executable -AllowToFail az webapp deployment slot list --name $AppServiceName --resource-group $AppServiceResourceGroupName | ConvertFrom-Json
}

if(!$AccessRestrictionRuleName)
{
    $AccessRestrictionRuleName = ($CIDRToRemoveFromWhitelist -replace "\.", "-") -replace "/", "-"
}

Remove-AccessRestriction -AppType webapp -ResourceGroupName $AppServiceResourceGroupName -ResourceName $AppServiceName -AccessRestrictionRuleName $AccessRestrictionRuleName -DeploymentSlotName $AppServiceDeploymentSlotName

foreach($availableSlot in $availableSlots)
{
    Remove-AccessRestriction -AppType webapp -ResourceGroupName $AppServiceResourceGroupName -ResourceName $AppServiceName -AccessRestrictionRuleName $AccessRestrictionRuleName -DeploymentSlotName $availableSlot.name
}

Write-Footer -ScopedPSCmdlet $PSCmdlet