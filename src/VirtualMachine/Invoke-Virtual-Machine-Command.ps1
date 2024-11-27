[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $VirtualMachineResourceGroupName,
    [Parameter(Mandatory)][ValidateLength(1, 15)][string] $VirtualMachineBaseName,
    [Parameter(Mandatory)][Validateset('Windows', 'Linux')][string] $VirtualMachineOS,
    [Parameter(Mandatory)][string] $CommandToExecuteOnVirtualMachine
)
#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$existingVirtualMachines = Get-AzVM -ResourceGroupName $VirtualMachineResourceGroupName | Where-Object Name -Like "$VirtualMachineBaseName*"

$existingVirtualMachines.Name | ForEach-Object -Parallel {
    Set-Location $using:PWD
    Import-Module "$using:PSScriptRoot\..\AzDocs.Common" -Force

    $virtualMachineName = $_

    Write-Host "Executing command on  $virtualMachineName"
    $tempFile = New-TemporaryFile  
    try
    {
        $using:CommandToExecuteOnVirtualMachine | Out-File -FilePath $tempFile
        $commandId = ''
        switch ($using:VirtualMachineOS)
        {
            'Windows'
            {
                $commandId = 'RunPowerShellScript'
            }
            'Linux'
            {
                $commandId = 'RunShellScript'
            }
            Default { throw "Virtual Machine os is not properly set: '$using:VirtualMachineOS'" }
        }
        Invoke-AzVMRunCommand -ResourceGroupName $using:VirtualMachineResourceGroupName -VMName $virtualMachineName -ScriptPath $tempFile -CommandId $commandId 

        Write-Host "Command executed on $virtualMachineName"
    }
    finally
    {
        if ($tempFile.Exists)
        {
            $tempFile.Delete()
        } 
    }
}


Write-Footer -ScopedPSCmdlet $PSCmdlet