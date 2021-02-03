[CmdletBinding()]
param (
    [Alias("ResourceGroupName")]
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Alias("RuleName")]
    [Parameter(Mandatory)][string] $AccessRestrictionRuleName,
    [Alias("IpRangeToWhitelist")]
    [Parameter(Mandatory)][ValidatePattern('^(?:(?:\d{1,3}.){3}\d{1,3})\/(?:\d{1,2})$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

# please note because of a bug, the SCM part should be first whitelisted and then the regular website (https://github.com/Azure/azure-cli/issues/14862)
Invoke-Executable az webapp config access-restriction add --resource-group $AppServiceResourceGroupName --name $AppServiceName --priority 10 --description $AccessRestrictionRuleName --rule-name $AccessRestrictionRuleName --ip-address $CIDRToWhitelist --scm-site $true
Invoke-Executable az webapp config access-restriction add --resource-group $AppServiceResourceGroupName --name $AppServiceName --priority 10 --description $AccessRestrictionRuleName --rule-name $AccessRestrictionRuleName --ip-address $CIDRToWhitelist --scm-site $false

Write-Footer