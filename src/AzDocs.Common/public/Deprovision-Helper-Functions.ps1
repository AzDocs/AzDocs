
function Remove-LinkedApplicationsFromSubnet
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $ResourceGroupName
    )

    # Because of bug https://docs.microsoft.com/en-us/answers/questions/140197/unable-to-delete-vnet-due-to-serviceassociationlin.html, 
    # this helper is introduced to first unlink the appservice from the subnet

    Write-Header -ScopedPSCmdlet $PSCmdlet

    # Make sure to disconnect app services from subnet
    $applications = Invoke-Executable az resource list --resource-group $ResourceGroupName --query "[?type=='Microsoft.Web/sites']" | ConvertFrom-Json
    foreach ($application in $applications)
    {
        $applicationType = $application.kind.split(',')[0]
        switch ($applicationType)
        {
            "app" { Remove-VNetIntegrationFromResource -ResourceGroupName $ResourceGroupName -ResourceName $application.name -AppType 'webapp' }
            "functionapp" { Remove-VNetIntegrationFromResource -ResourceGroupName $ResourceGroupName -ResourceName $application.name -AppType 'functionapp' }
        }
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Remove-VNetIntegrationFromResource
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $ResourceGroupName,
        [Parameter(Mandatory)][string] $ResourceName,
        [Parameter(Mandatory)][ValidateSet("webapp", "functionapp")][string] $AppType
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $slots = Invoke-Executable az $AppType deployment slot list --resource-group $ResourceGroupName --name $ResourceName | ConvertFrom-Json
    foreach ($slot in $slots)
    {
        # remove vnet-integration for each slot
        Invoke-Executable az $AppType vnet-integration remove --resource-group $ResourceGroupName --name $ResourceName --slot $slot.Name
    }

    Invoke-Executable az $AppType vnet-integration remove --resource-group $ResourceGroupName --name $ResourceName

    Write-Footer -ScopedPSCmdlet $PSCmdlet

}