[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $ResourceGroupName,
    
    [Parameter()]
    [string[]]
    $TagsToIgnore = @('OSSupport', 'CreatedOnDate'),

    # In the case of inconsistencies, use this switch to set the resourcegroup values to the resource
    [Parameter()]
    [switch]
    $Force,

    [Parameter()]
    [switch]
    $WhatIf
)
#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===
Write-Header -ScopedPSCmdlet $PSCmdlet

$resourceGroup = az group show --resource-group $ResourceGroupName | ConvertFrom-Json 
$resourceGroupProperties = @($resourceGroup.tags.psobject.Properties)
$resources = az resource list --resource-group $ResourceGroupName | ConvertFrom-Json 

$tagInconsistency = $false 
$workToDo = $resources | ForEach-Object {
    $resource = $_   
    $resourcesProperties = @($resource.tags.psobject.Properties)
    if (!$resourcesProperties)
    {
        Write-Host "start $($resource.Name)"
        $resourceGroupProperties | ForEach-Object {
            Write-Host "$($PSStyle.Foreground.BrightGreen)ResourceGroup tag '$($_.Name)', value '$($_.Value)' not found on resource"
            $work = [PSCustomObject]@{
                Tag      = $_.Name
                Value    = $_.Value
                Name     = $resource.name
                Resource = $resource.id
            
            }
            Write-Output $work
        }
        Write-Host "end $($resource.Name)"
    }
    else
    {
        $comparison = Compare-Object $resourceGroupProperties $resourcesProperties -Property value -PassThru | Where-Object { $TagsToIgnore -notcontains $_.Name } | Select-Object Name, Value, SideIndicator | Sort-Object name
        if ($comparison)
        {
            Write-Host "start $($resource.Name)"
            $groupedComparison = $comparison | Group-Object Name
            $clashedComparison = $groupedComparison | Where-Object Count -GT 1
            if ($clashedComparison)
            {    
                $clashedComparison | ForEach-Object {
            
                    $resourceGroupClash = $_.Group | Where-Object SideIndicator -EQ '<='
                    $resourceClash = $_.Group | Where-Object SideIndicator -EQ '=>'
                    Write-Error "Resource group and Resource with tag '$($_.Name)' have different value, ResourceGroup '$($resourceGroupClash.Value)', Resource '$($resourceClash.Value)'"
                    if ($Force)
                    {
                        $work = [PSCustomObject]@{
                            Tag      = $_.Name
                            Value    = $resourceGroupClash.Value
                            Name     = $resource.name
                            Resource = $resource.id
                    
                        }
                        Write-Output $work
                    }
                }
                $tagInconsistency = $true  
            }

            $groupedComparison | Where-Object Count -EQ 1 | ForEach-Object {
                $singleResourceGroup = $_
                switch ($_.Group.SideIndicator)
                {
                    '<='
                    { 
                        Write-Host "$($PSStyle.Foreground.BrightGreen)ResourceGroup tag '$($singleResourceGroup.Name)', value '$($singleResourceGroup.Group.Value)' not found on resource"
                        $work = [PSCustomObject]@{
                            Tag      = $singleResourceGroup.Name
                            Value    = $singleResourceGroup.Group.Value
                            Name     = $resource.name
                            Resource = $resource.id
                        }
                        Write-Output $work
                    }
                    '=>'
                    {
                        Write-Host "$($PSStyle.Foreground.Yellow)Resource tag '$($singleResourceGroup.Name)', value '$($singleResourceGroup.Group.Value)' not found on resourcegroup"

                    }
                    Default { throw 'Invalid value for SideIndicator' }
                }
            }

            Write-Host "end $($resource.Name)"
        }
        else
        {
            Write-Host "$($PSStyle.Foreground.BrightBlack)No difference found for $($resource.Name)"
        }
    }
}
if (!$Force -and $tagInconsistency)
{
    throw 'Cannot process tags because of inconsistencies'
}
$workToDo | Group-Object Resource | ForEach-Object {
    $work = $_
    Write-Host "For$($PSStyle.Foreground.Yellow) $($work.Group[0].Name) $($PSStyle.Reset)adding tags [" -NoNewline
    $tags = $work.Group | ForEach-Object { 
        $singleWork = $_
        "'$($PSStyle.Foreground.Green)$($singleWork.Tag)$($PSStyle.Reset)':'$($PSStyle.Foreground.Green)$($singleWork.Value)$($PSStyle.Reset)'"
    }
    $line = $tags | Join-String -Separator ',' 
    Write-Host "$line" -NoNewline
    Write-Host ']'

    $tags = $work.Group | ForEach-Object { "$($_.Tag)=$($_.Value)" } 
    Invoke-Executable -WhatIf:$WhatIf az tag update --operation 'Merge' --resource-id $work.Name --tags @tags 
}
Write-Footer -ScopedPSCmdlet $PSCmdlet