[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $WafPolicyName, 
    [Parameter(Mandatory)][string] $WafPolicyResourceGroup, 
    [Parameter(Mandatory)][string][ValidateSet('Classic_AzureFrontDoor', 'Premium_AzureFrontDoor', 'Standard_AzureFrontDoor')] $WafPolicySku,
    [Parameter()][string][ValidateSet('Detection', 'Prevention')] $WafPolicyFirewallMode = "Detection",
    [Parameter()][System.Object[]] $ResourceTags
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Add extension for front-door
Invoke-Executable az config set extension.use_dynamic_install=yes_without_prompt

$wafPolicyId = (Invoke-Executable az network front-door waf-policy create --name $WafPolicyName --resource-group $WafPolicyResourceGroup --sku $WafPolicySku | ConvertFrom-Json).id

# Update Tags
if ($ResourceTags)
{
    Set-ResourceTagsForResource -ResourceId $wafPolicyId -ResourceTags ${ResourceTags}
}

Write-Footer -ScopedPSCmdlet $PSCmdlet