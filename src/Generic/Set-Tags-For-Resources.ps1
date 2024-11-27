
[CmdletBinding(DefaultParameterSetName = 'Single')]
param (
    [Parameter(Mandatory)][ValidateSet('merge', 'replace', 'delete')][string] $Operation,
    [Parameter(Mandatory)][string[]] $ResourceTags,
    [Parameter(Mandatory, ParameterSetName = 'Single')][string] $ResourceGroupName,
    [Parameter(Mandatory, ParameterSetName = 'Single')][string] $ResourceName,
    [Parameter(ParameterSetName = 'Single')][switch] $IncludeResourceGroup,
    [Parameter(Mandatory, ParameterSetName = 'Multiple')][string[]] $ResourceGroupNames,
    [Parameter(ParameterSetName = 'Multiple')][switch] $IncludeResourcesInResourceGroup

)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($PSCmdlet.ParameterSetName -eq 'Single')
{
    Update-ResourceTagsForResource -ResourceGroupName $ResourceGroupName -ResourceName $ResourceName -ResourceTags $ResourceTags -Operation $Operation -IncludeResourceGroup:$IncludeResourceGroup
}
else
{
    foreach ($resourceGroupName in $ResourceGroupNames)
    {
        Update-ResourceTagsForResource -ResourceGroupName $resourceGroupName -ResourceTags $ResourceTags -Operation $Operation -IncludeResourcesInResourceGroup:$IncludeResourcesInResourceGroup
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet