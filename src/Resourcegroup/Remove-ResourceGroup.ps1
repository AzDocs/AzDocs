[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ResourceGroupName,
    [Parameter][int] $RetryDeletionCount = 3
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$resourcegroupId = (Invoke-Executable -AllowToFail az group show --resource-group $ResourceGroupName | ConvertFrom-Json).id
if ($resourcegroupId)
{
    # Because of bug https://docs.microsoft.com/en-us/answers/questions/140197/unable-to-delete-vnet-due-to-serviceassociationlin.html we first have to remove the link between the subnet and the application
    Remove-LinkedApplicationsFromSubnet -ResourceGroupName $ResourceGroupName

    # Added retry mechanism
    $retryCount = 0;
    while ($resourceGroupId -and $retryCount -lt $RetryDeletionCount)
    {
        Write-Host "Deleting resourcegroup $ResourceGroupName"
        Invoke-Executable -AllowToFail az group delete --name $ResourceGroupName --yes

        $retryCount++
        $resourcegroupId = (Invoke-Executable -AllowToFail az group show --resource-group $ResourceGroupName | ConvertFrom-Json).id
    }
}
else
{
    Write-Host "No resourcegroup found matching name: '$ResourceGroupName'."
}

Write-Footer -ScopedPSCmdlet $PSCmdlet