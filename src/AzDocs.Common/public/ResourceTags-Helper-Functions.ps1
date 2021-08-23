
function Set-ResourceTagsForResource
{
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $ResourceId,
        [Parameter(Mandatory)][System.Object[]] $ResourceTags
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    # Update Tags
    Invoke-Executable az tag create --resource-id $ResourceId --tags @ResourceTags

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}