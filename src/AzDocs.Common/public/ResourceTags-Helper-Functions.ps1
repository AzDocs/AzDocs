
function Set-ResourceTagsForResource
{
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $ResourceId,
        [Parameter(Mandatory)][System.Object[]] $ResourceTags
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    Invoke-Executable az tag create --resource-id $ResourceId --tags @ResourceTags

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Update-ResourceTagsForResourceGroup
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string[]] $ResourceTags,
        [Parameter(Mandatory)][ValidateSet('merge', 'replace', 'delete')] $Operation,
        [Parameter(Mandatory)][string] $ResourceGroupName
    )
    
    Write-Header -ScopedPSCmdlet $PSCmdlet

    Write-Host "Updating resourcegroup $ResourceGroupName"
    $resourceGroup = (Invoke-Executable az group show --name $ResourceGroupName | ConvertFrom-Json)
    Invoke-Executable az tag update --resource-id $resourceGroup.id --tags @ResourceTags --operation $Operation    

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Update-ResourceTagsForResource
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string[]] $ResourceTags,
        [Parameter(Mandatory)][ValidateSet('merge', 'replace', 'delete')] $Operation,
        [Parameter(Mandatory, ParameterSetName = 'Single')][Parameter(Mandatory, ParameterSetName = 'Multiple')][string] $ResourceGroupName,
        [Parameter(Mandatory, ParameterSetName = 'Single')][string] $ResourceName,
        [Parameter(ParameterSetName = 'Single')][switch] $IncludeResourceGroup,
        [Parameter(ParameterSetName = 'Multiple')][switch] $IncludeResourcesInResourceGroup
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet
    
    if ($ResourceName)
    {
        if ($IncludeResourceGroup)
        {
            Update-ResourceTagsForResourceGroup -Resourcetags $ResourceTags -Operation $Operation -ResourceGroupName $ResourceGroupName
        }
    
        $resources = Invoke-Executable az resource list --resource-group $ResourceGroupName --name $ResourceName --query [].id --output tsv
        if ($resources.Count -ne 1)
        {
            throw 'Found multiple resources with the same name in the same resource group. Stopping..'
        }
    }
    else
    {
        Update-ResourceTagsForResourceGroup -Resourcetags $ResourceTags -Operation $Operation -ResourceGroupName $ResourceGroupName
        
        if ($IncludeResourcesInResourceGroup)
        {
            Write-Host "Getting resources for $ResourceGroupName"
            $resources = Invoke-Executable az resource list --resource-group $ResourceGroupName --query [].id --output tsv
        }
    }

    if ($resources)
    {
        foreach ($resourceId in $resources)
        {
            Write-Host "Running $Operation operation for tags for $resourceId"
            Invoke-Executable az tag update --resource-id $resourceId --tags @ResourceTags --operation $Operation
        }
    }
    else
    {
        Write-Host 'No resources found to update. Continueing..'
    }
    
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}