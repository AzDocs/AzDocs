[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $ResourceGroupName,

    [Parameter(Mandatory)]
    [string] $AppServiceName,

    [Parameter(Mandatory)]
    [string] $RuleName,

    [Parameter(Mandatory)]
    [ValidatePattern('^(?:(?:\d{1,3}.){3}\d{1,3})\/(?:\d{1,2})$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")]
    [string] $IpRangeToWhitelist
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

# please note because of a bug, the SCM part should be first whitelisted and then the regular website (https://github.com/Azure/azure-cli/issues/14862)
Invoke-Executable az webapp config access-restriction add --resource-group $ResourceGroupName --name $AppServiceName --priority 10 --description $RuleName --rule-name $RuleName --ip-address  $IpRangeToWhitelist --scm-site $true

Invoke-Executable az webapp config access-restriction add --resource-group $ResourceGroupName --name $AppServiceName --priority 10 --description $RuleName --rule-name $RuleName --ip-address  $IpRangeToWhitelist --scm-site $false