[CmdletBinding()]
param (
    [Alias('Location')]
    [Parameter(Mandatory)][string] $ResourceGroupLocation,
    [Parameter(Mandatory)][string] $ResourceGroupName,
    [Parameter()][string[]] $ResourceTags
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet
$response = Invoke-Executable az group create --location $ResourceGroupLocation --name $ResourceGroupName --tags @ResourceTags 
$resourceGroupId = ( $response | ConvertFrom-Json).id

if (!$resourceGroupId)
{
    throw 'Could not create the resource group'
}
# Update Tags
Set-ResourceTagsForResource -ResourceId $resourceGroupId -ResourceTags ${ResourceTags}

Write-Footer -ScopedPSCmdlet $PSCmdlet