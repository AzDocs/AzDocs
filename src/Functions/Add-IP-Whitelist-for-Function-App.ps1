[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Parameter(Mandatory)][string] $AccessRestrictionRuleName,
    [Parameter(Mandatory, ParameterSetName = 'cidr')][ValidatePattern('^(?:(?:\d{1,3}.){3}\d{1,3})\/(?:\d{1,2})$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist,
    [Parameter(Mandatory, ParameterSetName = 'myIp')][switch] $WhiteListMyIp,
    [Parameter()][string] $FunctionAppDeploymentSlotName,
    [Parameter()][string] $AccessRestrictionAction = "Allow",
    [Parameter()][string] $Priority = 10,
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

switch ($PSCmdlet.ParameterSetName)
{
    'cidr'
    {
        Add-AccessRestriction -AppType functionapp -ResourceGroupName $FunctionAppResourceGroupName -ResourceName $FunctionAppName -AccessRestrictionRuleName $AccessRestrictionRuleName `
            -CIDRToWhiteList $CIDRToWhiteList -AccessRestrictionAction $AccessRestrictionAction -Priority $Priority -DeploymentSlotName $FunctionAppDeploymentSlotName

        # Apply to all slots if desired
        foreach($availableSlot in $availableSlots)
        {
            Add-AccessRestriction -AppType functionapp -ResourceGroupName $FunctionAppResourceGroupName -ResourceName $FunctionAppName -AccessRestrictionRuleName $AccessRestrictionRuleName `
            -CIDRToWhiteList $CIDRToWhiteList -AccessRestrictionAction $AccessRestrictionAction -Priority $Priority -DeploymentSlotName $availableSlot.name
        }
    }
    'myIp'
    {
        Add-AccessRestriction -AppType functionapp -ResourceGroupName $FunctionAppResourceGroupName -ResourceName $FunctionAppName -AccessRestrictionRuleName $AccessRestrictionRuleName `
            -DeploymentSlotName $FunctionAppDeploymentSlotName -AccessRestrictionAction $AccessRestrictionAction -Priority $Priority -WhiteListMyIp

        # Apply to all slots if desired
        foreach($availableSlot in $availableSlots)
        {
            Add-AccessRestriction -AppType functionapp -ResourceGroupName $FunctionAppResourceGroupName -ResourceName $FunctionAppName -AccessRestrictionRuleName $AccessRestrictionRuleName `
            -DeploymentSlotName $availableSlot.name -AccessRestrictionAction $AccessRestrictionAction -Priority $Priority -WhiteListMyIp
        }
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet