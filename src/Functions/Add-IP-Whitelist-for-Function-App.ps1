[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Parameter(Mandatory)][string] $AccessRestrictionRuleName,
    [Parameter(Mandatory, ParameterSetName = 'cidr')][ValidatePattern('^(?:(?:\d{1,3}.){3}\d{1,3})\/(?:\d{1,2})$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist,
    [Parameter(Mandatory, ParameterSetName = 'myIp')][switch] $WhiteListMyIp,
    [Parameter()][string] $FunctionAppDeploymentSlotName,
    [Parameter()][string] $AccessRestrictionAction = "Allow",
    [Parameter()][string] $Priority = 10
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

switch ($PSCmdlet.ParameterSetName)
{
    'cidr'
    {
        Add-AccessRestriction -AppType functionapp -ResourceGroupName $FunctionAppResourceGroupName -ResourceName $FunctionAppName -AccessRestrictionRuleName $AccessRestrictionRuleName `
            -CIDRToWhiteList $CIDRToWhiteList -AccessRestrictionAction $AccessRestrictionAction -Priority $Priority -DeploymentSlotName $FunctionAppDeploymentSlotName
    }
    'myIp'
    {
        Add-AccessRestriction -AppType functionapp -ResourceGroupName $FunctionAppResourceGroupName -ResourceName $FunctionAppName -AccessRestrictionRuleName $AccessRestrictionRuleName `
            -DeploymentSlotName $FunctionAppDeploymentSlotName -AccessRestrictionAction $AccessRestrictionAction -Priority $Priority -WhiteListMyIp
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet