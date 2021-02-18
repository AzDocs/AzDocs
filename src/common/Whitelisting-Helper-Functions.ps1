#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

#region Helper functions

<#
.SYNOPSIS
    Add Access restriction to app service and/or function app
.DESCRIPTION
    Add Access restriction to app service and/or function app
#>
function Add-AccessRestriction {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] [ValidateSet('functionapp', 'webapp')]$AppType,
        [Parameter(Mandatory)][string] $ResourceGroupName,
        [Parameter(Mandatory)][string] $ResourceName,
        [Parameter(Mandatory)][string] $AccessRestrictionRuleName,
        [Parameter()][string] $DeploymentSlotName,
        [Parameter()][string] $AccessRestrictionAction = "Allow",
        [Parameter()][string] $Priority = 10,
        [Parameter(ParameterSetName = 'cidr', Mandatory)][string] $CIDRToWhitelist,
        [Parameter(ParameterSetName = 'myIp', Mandatory)][switch] $WhiteListMyIp
    )

    Write-Header

    $optionalParameters = @()
    if ($DeploymentSlotName) {
        $optionalParameters += "--slot", "$DeploymentSlotName"
    }

    if ($WhiteListMyIp) {
        $CIDRToWhitelist = Invoke-RestMethod -Uri 'https://ipinfo.io/ip'
    }
 
    Invoke-Executable az $AppType config access-restriction add --resource-group $ResourceGroupName --name $ResourceName --action $AccessRestrictionAction --priority $Priority --description $AccessRestrictionRuleName --rule-name $AccessRestrictionRuleName --ip-address $CIDRToWhitelist --scm-site $true @optionalParameters
    Invoke-Executable az $AppType config access-restriction add --resource-group $ResourceGroupName --name $ResourceName --action $AccessRestrictionAction --priority $Priority --description $AccessRestrictionRuleName --rule-name $AccessRestrictionRuleName --ip-address $CIDRToWhitelist --scm-site $false @optionalParameters

    Write-Footer
}

<#
.SYNOPSIS
    Remove Access restriction from app service and/or function app
.DESCRIPTION
    Remove Access restriction from app service and/or function app
#>
function Remove-AccessRestriction {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] [ValidateSet('functionapp', 'webapp')]$AppType,
        [Parameter(Mandatory)][string] $ResourceGroupName,
        [Parameter(Mandatory)][string] $ResourceName,
        [Parameter(Mandatory)][string] $AccessRestrictionRuleName,
        [Parameter()][string] $DeploymentSlotName
    )

    Write-Header

    $optionalParameters = @()
    if ($DeploymentSlotName) {
        $optionalParameters += "--slot", "$DeploymentSlotName"
    }
 
    Invoke-Executable az $AppType config access-restriction remove --resource-group $ResourceGroupName --name $ResourceName --rule-name $AccessRestrictionRuleName --scm-site $true @optionalParameters 
    Invoke-Executable az $AppType config access-restriction remove --resource-group $ResourceGroupName --name $ResourceName --rule-name $AccessRestrictionRuleName --scm-site $false @optionalParameters

    Write-Footer
}

#endregion