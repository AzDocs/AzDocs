[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter(Mandatory)][string] $DomainNameToBind,
    [Parameter()][string] $AppServiceSlotName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$optionalParameters = @()
if ($AppServiceSlotName)
{
    $optionalParameters += "--slot", "$AppServiceSlotName"
}

# Add binding
Invoke-Executable az webapp config hostname add --hostname $DomainNameToBind --resource-group $AppServiceResourceGroupName --webapp-name $AppServiceName @optionalParameters


Write-Footer -ScopedPSCmdlet $PSCmdlet