[CmdletBinding()]
param (

    # Name of the web app resource group
    [Parameter(Mandatory)]
    [string] $appServiceResourceGroupName,

    # Name of the webapp
    [Parameter(Mandatory)]
    [string] $appServiceName,

    # Source slot to swap from
    [Parameter()]
    [string]
    $SourcesSlot = 'staging',

    # Target slot to swap to
    [Parameter()]
    [string]
    $TargetSlot = 'production'
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Invoke-Executable az webapp deployment slot swap  --resource-group $appServiceResourceGroupName --name $appServiceName --slot $SourcesSlot --target-slot $TargetSlot