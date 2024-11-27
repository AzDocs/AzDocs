
[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $CdnProfileName,
    [Parameter(Mandatory)][string] $CdnResourceGroupName,
    [Parameter()][ValidateSet('Custom_Verizon', 'Premium_Verizon', 'Standard_Akamai', 'Standard_ChinaCdn', 'Standard_Microsoft', 'Standard_Verizon')][string] $Sku = 'Standard_Akamai'
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az cdn profile create --name $CdnProfileName --resource-group $CdnResourceGroupName --sku $Sku

Write-Footer -ScopedPSCmdlet $PSCmdlet