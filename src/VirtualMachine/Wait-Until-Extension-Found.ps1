[CmdletBinding()]
param (
    [Parameter(Mandatory)][string]$VirtualMachineResourceGroupName,
    [Parameter(Mandatory)][string]$VirtualMachineBaseName,
    [Parameter(Mandatory)][string]$VirtualMachineExtensionName,
    [Parameter()][string]$VirtualMachineExtensionState = 'Succeeded'
)
#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$existingVirtualMachines = Invoke-Executable az vm list --resource-group $VirtualMachineResourceGroupName | ConvertFrom-Json | Where-Object Name -Like "$VirtualMachineBaseName*"
$existingVirtualMachines.Name | ForEach-Object -parallel {
    Set-Location $using:PWD
    Import-Module "$using:PSScriptRoot\..\AzDocs.Common" -Force

    $virtualMachineName = $_
    $found = $false
    while (!$found)
    {
        Write-Host "Checking '$virtualMachineName' for Extension '$using:VirtualMachineExtensionName'"
        $response = Invoke-Executable az vm extension list --resource-group $using:VirtualMachineResourceGroupName --vm-name $virtualMachineName | ConvertFrom-Json
        $extensionResponse = $response | Where-Object Name -eq $using:VirtualMachineExtensionName
        if ($extensionResponse)
        {
            Write-Host "Extension found for '$virtualMachineName' in state '$($extensionResponse.provisioningState)'"
            if ($extensionResponse.provisioningState -eq $using:VirtualMachineExtensionState)
            {
                Write-Host "Extension found for '$virtualMachineName' in the correct state"
                $found = $true
            }
            else
            {
                Write-Host "Extension '$using:VirtualMachineExtensionName' in state '$($extensionResponse.provisioningState)', waiting for getting in the '$using:VirtualMachineExtensionState'state'"
            }
        }
        else
        {
            Write-Host 'No extension found'
        }
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet