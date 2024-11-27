[CmdletBinding()]
param (
    [Parameter(Mandatory)][string]$VirtualMachineResourceGroupName,
    [Parameter(Mandatory)][string]$VirtualMachineBaseName,
    [Parameter()][string]$VirtualMachineExtensionState = 'Succeeded'
)
#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$existingVirtualMachines = Invoke-Executable az vm list --resource-group $VirtualMachineResourceGroupName | ConvertFrom-Json | Where-Object Name -Like "$VirtualMachineBaseName*"
$existingVirtualMachines.Name | ForEach-Object -Parallel {
    Set-Location $using:PWD
    Import-Module "$using:PSScriptRoot\..\AzDocs.Common" -Force

    $virtualMachineName = $_
    $ready = $false
    while (!$ready)
    {
        $ready = $true
        Write-Host "Checking '$virtualMachineName' for Extensions"
        $response = Invoke-Executable az vm extension list --resource-group $using:VirtualMachineResourceGroupName --vm-name $virtualMachineName | ConvertFrom-Json
        $response | ForEach-Object {
            $extension = $_
            Write-Host "Found $($extension.name) with state $($extension.provisioningState)"
            if ($extension.provisioningState -ne $using:VirtualMachineExtensionState)
            {
                $ready = $false
                Write-Host "$($extension.name) not in the correct state yet $($extension.provisioningState)"
            }
        }
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet