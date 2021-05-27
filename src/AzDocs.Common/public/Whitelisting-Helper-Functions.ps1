#region Helper functions

<#
.SYNOPSIS
    Add Access restriction to app service and/or function app
.DESCRIPTION
    Add Access restriction to app service and/or function app
#>
function Add-AccessRestriction
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] [ValidateSet('functionapp', 'webapp')]$AppType,
        [Parameter(Mandatory)][string] $ResourceGroupName,
        [Parameter(Mandatory)][string] $ResourceName,
        [Parameter(Mandatory)][string] $AccessRestrictionRuleName,
        [Parameter()][string] $AccessRestrictionRuleDescription,
        [Parameter()][string] $DeploymentSlotName,
        [Parameter()][string] $AccessRestrictionAction = "Allow",
        [Parameter()][string] $Priority = 10,
        [Parameter(ParameterSetName = 'cidr', Mandatory)][string] $CIDRToWhitelist,
        [Parameter(ParameterSetName = 'myIp', Mandatory)][switch] $WhiteListMyIp,
        [Parameter()][bool] $ApplyToMainEntrypoint = $true,
        [Parameter()][bool] $ApplyToScmEntrypoint = $true
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $optionalParameters = @()
    if ($DeploymentSlotName)
    {
        $optionalParameters += "--slot", "$DeploymentSlotName"
    }

    if($AccessRestrictionRuleDescription)
    {
        $optionalParameters += "--description", "$AccessRestrictionRuleDescription"

    }

    # SCM
    if($ApplyToScmEntrypoint)
    {
        if (Confirm-AccessRestriction -AppType $AppType -ResourceGroupName $ResourceGroupName -ResourceName $ResourceName -AccessRestrictionRuleName $AccessRestrictionRuleName -SecurityRestrictionObjectName "scmIpSecurityRestrictions" -DeploymentSlotName $DeploymentSlotName)
        {
            Invoke-Executable az $AppType config access-restriction remove --resource-group $ResourceGroupName --name $ResourceName --rule-name $AccessRestrictionRuleName --scm-site $true @optionalParameters
        }
        Invoke-Executable az $AppType config access-restriction add --resource-group $ResourceGroupName --name $ResourceName --action $AccessRestrictionAction --priority $Priority --rule-name $AccessRestrictionRuleName --ip-address $CIDRToWhitelist --scm-site $true @optionalParameters
    }

    # Normal WebApp
    if($ApplyToMainEntrypoint)
    {
        if (Confirm-AccessRestriction -AppType $AppType -ResourceGroupName $ResourceGroupName -ResourceName $ResourceName -AccessRestrictionRuleName $AccessRestrictionRuleName -SecurityRestrictionObjectName "ipSecurityRestrictions" -DeploymentSlotName $DeploymentSlotName)
        {
            Invoke-Executable az $AppType config access-restriction remove --resource-group $ResourceGroupName --name $ResourceName --rule-name $AccessRestrictionRuleName --scm-site $false @optionalParameters
        }
        Invoke-Executable az $AppType config access-restriction add --resource-group $ResourceGroupName --name $ResourceName --action $AccessRestrictionAction --priority $Priority --rule-name $AccessRestrictionRuleName --ip-address $CIDRToWhitelist --scm-site $false @optionalParameters
    }
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

<#
.SYNOPSIS
    Remove Access restriction from app service and/or function app
.DESCRIPTION
    Remove Access restriction from app service and/or function app
#>
function Remove-AccessRestriction
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] [ValidateSet('functionapp', 'webapp')]$AppType,
        [Parameter(Mandatory)][string] $ResourceGroupName,
        [Parameter(Mandatory)][string] $ResourceName,
        [Parameter()][string] $AccessRestrictionRuleName,
        [Parameter()][string] $CIDRToRemove,
        [Parameter()][string] $DeploymentSlotName,
        [Parameter()][bool] $ApplyToMainEntrypoint = $true,
        [Parameter()][bool] $ApplyToScmEntrypoint = $true
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $optionalParameters = @()
    if ($DeploymentSlotName)
    {
        $optionalParameters += "--slot", "$DeploymentSlotName"
    }
 
    if($AccessRestrictionRuleName)
    {
        $optionalParameters += "--rule-name", "$AccessRestrictionRuleName"
    }
    else
    {
        $optionalParameters += "--ip-address", "$CIDRToRemove"
    }

    if($ApplyToScmEntrypoint)
    {
        Invoke-Executable az $AppType config access-restriction remove --resource-group $ResourceGroupName --name $ResourceName --scm-site $true @optionalParameters 
    }
    
    if($ApplyToMainEntrypoint)
    {
        Invoke-Executable az $AppType config access-restriction remove --resource-group $ResourceGroupName --name $ResourceName --scm-site $false @optionalParameters
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

<#
.SYNOPSIS
    Check if Access restrictions exist on app service and/or function app
.DESCRIPTION
    Check if Access restrictions exist on app service and/or function app
#>

function Confirm-AccessRestriction
{  
    [OutputType([boolean])]
    param (
        [Parameter(Mandatory)][string] [ValidateSet('functionapp', 'webapp')]$AppType,
        [Parameter(Mandatory)][string] $ResourceGroupName,
        [Parameter(Mandatory)][string] $ResourceName,
        [Parameter(Mandatory)][string] $AccessRestrictionRuleName,
        [Parameter(Mandatory)][ValidateSet("ipSecurityRestrictions", "scmIpSecurityRestrictions")][string] $SecurityRestrictionObjectName,
        [Parameter()][string] $DeploymentSlotName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $optionalParameters = @()
    if ($DeploymentSlotName)
    {
        $optionalParameters += "--slot", "$DeploymentSlotName"
    }

    $accessRestrictions = Invoke-Executable az $AppType config access-restriction show --resource-group $ResourceGroupName --name $ResourceName @optionalParameters | ConvertFrom-Json
    if ($accessRestrictions.$SecurityRestrictionObjectName.Name -contains $AccessRestrictionRuleName)
    {
        Write-Host "Access restriction for type $SecurityRestrictionObjectName already exists, continueing"
        Write-Output $true
    }
    else
    {
        Write-Host "Access restriction for type $SecurityRestrictionObjectName does not exist. Creating."
        Write-Output $false
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

#endregion