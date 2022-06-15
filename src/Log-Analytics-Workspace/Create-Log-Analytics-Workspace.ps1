[CmdletBinding()]
param (
    [Alias("LawResourceGroupName")]
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceGroupName,
    [Alias("LawName")]
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceName,
    [Alias("LawRetentionInDays")]
    [Parameter()][int][ValidateRange(180, 730)] $LogAnalyticsWorkspaceRetentionInDays = 180,
    [Parameter()][switch] $PublicInterfaceIngestionEnabled,
    [Parameter()][switch] $PublicInterfaceQueryAccess,
    [Parameter()][System.Object[]] $ResourceTags,
    [Parameter()][string[]] $LogAnalyticsWorkspaceSolutionTypes
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

#install required extensions
Invoke-Executable az config set extension.use_dynamic_install=yes_without_prompt
Invoke-Executable az extension add --name log-analytics-solution

$scriptArguments = "--workspace-name", "$LogAnalyticsWorkspaceName", "--resource-group", "$LogAnalyticsWorkspaceResourceGroupName", "--retention-time", "$LogAnalyticsWorkspaceRetentionInDays", "--tags", $ResourceTags

if ($PublicInterfaceIngestionEnabled)
{
    $scriptArguments += "--ingestion-access", "Enabled"
}
else
{
    $scriptArguments += "--ingestion-access", "Disabled"
}

if ($PublicInterfaceQueryAccess)
{
    $scriptArguments += "--query-access", "Enabled"
}
else
{
    $scriptArguments += "--query-access", "Disabled"
}

<<<<<<< HEAD
$logAnalyticsWorkspaceId = (Invoke-Executable az monitor log-analytics workspace create @scriptArguments | ConvertFrom-Json -AsHashTable).id
=======
# Added the -AsHashtable because of bugs in the cli with duplicate etag parameters 
$logAnalyticsWorkspaceId = (Invoke-Executable az monitor log-analytics workspace create @scriptArguments | ConvertFrom-Json -AsHashtable).id
>>>>>>> 3e67feb6005d9e42f5b0fdfadfd563fa97587c61

# Update Tags
Set-ResourceTagsForResource -ResourceId $logAnalyticsWorkspaceId -ResourceTags ${ResourceTags}

if ($LogAnalyticsWorkspaceSolutionTypes)
{
<<<<<<< HEAD
    $logAnalyticsWorkspaceResourceId = (Invoke-Executable -AllowToFail az monitor log-analytics workspace show --workspace-name $LogAnalyticsWorkspaceName --resource-group $LogAnalyticsWorkspaceResourceGroupName.ToLower() | ConvertFrom-Json -AsHashTable).Id
=======
    $logAnalyticsWorkspaceResourceId = (Invoke-Executable -AllowToFail az monitor log-analytics workspace show --workspace-name $LogAnalyticsWorkspaceName --resource-group $LogAnalyticsWorkspaceResourceGroupName.ToLower() | ConvertFrom-Json -AsHashtable).Id
>>>>>>> 3e67feb6005d9e42f5b0fdfadfd563fa97587c61
    if ($logAnalyticsWorkspaceResourceId)
    {
        foreach ($type in $LogAnalyticsWorkspaceSolutionTypes)
        {
            Write-Host "Adding the following solutiontype = $type to the log analytics workspace"
            Invoke-Executable az monitor log-analytics solution create --resource-group $LogAnalyticsWorkspaceResourceGroupName.ToLower() --solution-type $type  --workspace $logAnalyticsWorkspaceResourceId
        }
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet