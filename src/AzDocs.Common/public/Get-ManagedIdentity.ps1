function Get-ManagedIdentity
{
    [CmdletBinding(DefaultParameterSetName = 'webapp')]
    param (
        # Switches for which resource we are talking about
        [Parameter(Mandatory, ParameterSetName = 'webapp')][switch] $AppService,
        [Parameter(Mandatory, ParameterSetName = 'functionapp')][switch] $FunctionApp,
        [Parameter(Mandatory, ParameterSetName = 'appconfig')][switch] $AppConfig,
        # Parameters
        [Parameter(Mandatory)][string] $ResourceName,
        [Parameter(Mandatory)][string] $ResourceGroupName,
        [Parameter(ParameterSetName = 'webapp')][Parameter(ParameterSetName = 'functionapp')][string] $AppServiceSlotName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $appType = $PSCmdlet.ParameterSetName
    $additionalParameters = @()
    $fullAppName = $ResourceName
    if ($AppServiceSlotName)
    {
        $additionalParameters += '--slot' , $AppServiceSlotName
        $fullAppName += "[$AppServiceSlotName]"
    }

    $identityId = (Invoke-Executable az $appType identity show --resource-group $ResourceGroupName --name $ResourceName @additionalParameters | ConvertFrom-Json).principalId
    if (-not $identityId)
    {
        throw "Could not find identity for $fullAppName"
    }
    Write-Host "Identity for $fullAppName : $identityId"

    Write-Output $identityId

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Set-ManagedIdentityForSlot
{
    [CmdletBinding(DefaultParameterSetName = 'webapp')]
    param (
        [Parameter(Mandatory)][ValidateSet('functionapp', 'webapp')][string] $AppType,
        [Parameter(Mandatory)][string] $ManagedIdentityResourceName,
        [Parameter(Mandatory)][string] $ManagedIdentityResourceGroupName,
        [Parameter(Mandatory)][string] $TargetResourceName,
        [Parameter(Mandatory)][string] $TargetResourceGroupName,
        [Parameter(Mandatory)][string] $TargetResourceType,
        [Parameter(Mandatory)][string] $TargetResourceNamespace,
        [Parameter()][string] $TargetResourceParentPath,
        [Parameter(Mandatory)][string] $RoleToAssign
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $slots = (Invoke-Executable az $AppType deployment slot list --name $ManagedIdentityResourceName --resource-group $ManagedIdentityResourceGroupName | ConvertFrom-Json).name
    foreach ($slot in $slots)
    {
        Write-Host "Adding assignment to slot $slot"

        $principalIdSlot = Get-ManagedIdentity -AppService -ResourceName $ManagedIdentityResourceName -ResourceGroupName $ManagedIdentityResourceGroupName -AppServiceSlotName $slot
        Add-ScopedRoleAssignment -Resource -ResourceName $TargetResourceName -ResourceGroup $TargetResourceGroupName -ResourceType $TargetResourceType -ResourceNamespace $TargetResourceNamespace -ParentResourcePath $TargetResourceParentPath -RoleToAssign $RoleToAssign -AssigneeObjectId $principalIdSlot  
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}