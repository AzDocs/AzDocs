[CmdletBinding()]
param (
    [Alias('Namespace')]
    [Parameter(Mandatory)][string] $ResourceProviderNamespace
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$registrationState = (Invoke-Executable az provider show --namespace $ResourceProviderNameSpace | ConvertFrom-Json).registrationState
if ($registrationState -eq 'NotRegistered' -or $registrationState -eq 'Unregistered')
{
    Invoke-Executable az provider register --namespace $ResourceProviderNamespace
    while ($registrationState -ne 'Registered')
    {
        $registrationState = (Invoke-Executable az provider show --namespace $ResourceProviderNameSpace | ConvertFrom-Json).registrationState
        Write-Host $registrationState

        Write-Host "Waiting for the provider: $ResourceProviderNameSpace to register."
        Start-Sleep -Seconds 20
    }

}
Write-Host "The provider $ResourceProviderNameSpace is registered."

Write-Footer -ScopedPSCmdlet $PSCmdlet