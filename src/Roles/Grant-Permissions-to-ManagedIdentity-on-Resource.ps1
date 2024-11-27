[CmdletBinding()]
param (
    # Switches for which MSI resource we are talking about
    [Parameter(Mandatory, ParameterSetName = 'webapp')][switch] $AppServiceManagedIdentity,
    [Parameter(Mandatory, ParameterSetName = 'functionapp')][switch] $FunctionAppManagedIdentity,
    [Parameter(Mandatory, ParameterSetName = 'appconfig')][switch] $AppConfigManagedIdentity,
    [Parameter(Mandatory, ParameterSetName = 'other')][switch] $OtherIdentity,
    # Parameters
    [Parameter(Mandatory, ParameterSetName = 'webapp')][Parameter(Mandatory, ParameterSetName = 'functionapp')][Parameter(Mandatory, ParameterSetName = 'appconfig')][string] $ManagedIdentityResourceName,
    [Parameter(Mandatory, ParameterSetName = 'webapp')][Parameter(Mandatory, ParameterSetName = 'functionapp')][Parameter(Mandatory, ParameterSetName = 'appconfig')][string] $ManagedIdentityResourceGroupName,
    [Parameter(ParameterSetName = 'webapp')][Parameter(ParameterSetName = 'functionapp')][string] $ManagedIdentityAppServiceSlotName,
    [Parameter(ParameterSetName = 'webapp')][Parameter(ParameterSetName = 'functionapp')][bool] $ApplyToAllSlots = $false,
    [Parameter(ParameterSetName = 'other')][ValidateNotNullOrEmpty()][string] $PrincipalId,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $TargetResourceName,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $TargetResourceGroupName,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $TargetResourceType,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $TargetResourceNamespace,
    [Parameter()][ValidateNotNullOrEmpty()][string] $TargetResourceParentPath,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $RoleToAssign
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($AppServiceManagedIdentity)
{
    $PrincipalId = Get-ManagedIdentity -AppService -ResourceName $ManagedIdentityResourceName -ResourceGroupName $ManagedIdentityResourceGroupName -AppServiceSlotName $ManagedIdentityAppServiceSlotName

    if ($ApplyToAllSlots)
    {
        $parametersForSlot = @{
            AppType                          = 'webapp'
            ManagedIdentityResourceName      = $ManagedIdentityResourceName
            ManagedIdentityResourceGroupName = $ManagedIdentityResourceGroupName
            TargetResourceName               = $TargetResourceName
            TargetResourceGroupName          = $TargetResourceGroupName
            TargetResourceType               = $TargetResourceType
            TargetResourceNamespace          = $TargetResourceNamespace
            TargetResourceParentPath         = $TargetResourceParentPath
            RoleToAssign                     = $RoleToAssign
        }
        
        Set-ManagedIdentityForSlot @parametersForSlot
    }
}
elseif ($FunctionAppManagedIdentity)
{
    $PrincipalId = Get-ManagedIdentity -FunctionApp -ResourceName $ManagedIdentityResourceName -ResourceGroupName $ManagedIdentityResourceGroupName -AppServiceSlotName $ManagedIdentityAppServiceSlotName

    if ($ApplyToAllSlots)
    {
        $parametersForSlot = @{
            AppType                          = 'functionapp'
            ManagedIdentityResourceName      = $ManagedIdentityResourceName
            ManagedIdentityResourceGroupName = $ManagedIdentityResourceGroupName
            TargetResourceName               = $TargetResourceName
            TargetResourceGroupName          = $TargetResourceGroupName
            TargetResourceType               = $TargetResourceType
            TargetResourceNamespace          = $TargetResourceNamespace
            TargetResourceParentPath         = $TargetResourceParentPath
            RoleToAssign                     = $RoleToAssign
        }
    
        Set-ManagedIdentityForSlot @parametersForSlot
    }
}
elseif ($AppConfigManagedIdentity)
{
    $PrincipalId = Get-ManagedIdentity -AppConfig -ResourceName $ManagedIdentityResourceName -ResourceGroupName $ManagedIdentityResourceGroupName -AppServiceSlotName $ManagedIdentityAppServiceSlotName
}

Add-ScopedRoleAssignment -Resource -ResourceName $TargetResourceName -ResourceGroup $TargetResourceGroupName -ResourceType $TargetResourceType -ResourceNamespace $TargetResourceNamespace -ParentResourcePath $TargetResourceParentPath -RoleToAssign $RoleToAssign -AssigneeObjectId:$PrincipalId

Write-Footer -ScopedPSCmdlet $PSCmdlet