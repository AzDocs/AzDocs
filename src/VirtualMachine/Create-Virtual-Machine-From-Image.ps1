[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $VirtualMachineResourceGroupName,
    [Parameter(Mandatory)][ValidateLength(1, 13)][string] $VirtualMachineBaseName,
    [Parameter(Mandatory)][ValidateRange(1, 99)][int] $VirtualMachineTotalCount,
    [Parameter(Mandatory)][string] $VirtualMachineImageName,
    [Parameter(Mandatory)][string] $VirtualMachineAdminUsername,
    [Parameter(Mandatory)][string] $VirtualMachineAdminPassword,

    [Parameter(Mandatory)][string] $VirtualMachineVnetResourceGroupName,
    [Parameter(Mandatory)][string] $VirtualMachineVnetName,
    [Parameter(Mandatory)][string] $VirtualMachineSubnetName,

    [Parameter()][string] $VirtualMachineAvailabilitySetName,
    [Parameter()][string] $VirtualMachineSizeSku = 'Standard_DS1_v2',
    [Parameter()][ValidateSet('Standard_LRS', 'Premium_LRS', 'StandardSSD_LRS', 'UltraSSD_LRS', 'Premium_ZRS', 'StandardSSD_ZRS')][string] $VirtualMachineStorageSku = 'Standard_LRS',
    [Parameter()][System.Object[]] $ResourceTags = @(), 
    [Parameter()][string] $ResourceTagForVirtualMachineName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($VirtualMachineAvailabilitySetName)
{
    Write-Host "Using availability set '$VirtualMachineAvailabilitySetName'"
    Invoke-Executable az vm availability-set create --resource-group $VirtualMachineResourceGroupName --name $VirtualMachineAvailabilitySetName
}

$existingVirtualMachines = Invoke-Executable az vm list --resource-group $VirtualMachineResourceGroupName | ConvertFrom-Json | Where-Object Name -Like "$VirtualMachineBaseName*" 
$virtualMachinesNamesToCreate = @()
for ($i = 1; $i -le $VirtualMachineTotalCount; $i++)
{
    $virtualMachinesName = '{0}{1:d2}' -f $VirtualMachineBaseName, $i 
    if ($existingVirtualMachines.Name -notcontains $virtualMachinesName )
    {
        Write-Host "Need to create '$virtualMachinesName'"
        $virtualMachinesNamesToCreate += $virtualMachinesName
    }
}

Write-Host "Number of Virtual Machines to create $($virtualMachinesNamesToCreate.Length)"

$virtualMachinesNamesToCreate | ForEach-Object -Parallel {
    Set-Location $using:PWD
    Import-Module "$using:PSScriptRoot\..\AzDocs.Common" -Force
    
    $virtualMachineName = $_
    Write-Host "Creating Virtual Machine: '$virtualMachineName'"
    $optionalParameters = $()
    if ($using:VirtualMachineAvailabilitySetName)
    {
        $optionalParameters += '--availability-set' , $using:VirtualMachineAvailabilitySetName
    }

    $subnetIdentifier = (Invoke-Executable az network vnet subnet show --resource-group $using:VirtualMachineVnetResourceGroupName --vnet-name $using:VirtualMachineVnetName --name $using:VirtualMachineSubnetName | ConvertFrom-Json).Id
    $nic = Invoke-Executable az network nic create --resource-group $using:VirtualMachineResourceGroupName --name "$virtualMachineName-NIC" --subnet $subnetIdentifier | ConvertFrom-Json
    $ResourceTags = $using:ResourceTags
    if ($using:ResourceTagForVirtualMachineName)
    {
        $ResourceTags += "$using:ResourceTagForVirtualMachineName=$virtualMachineName"
    }

    Invoke-Executable az vm create --resource-group $using:VirtualMachineResourceGroupName --name $virtualMachineName --image $using:VirtualMachineImageName --size $using:VirtualMachineSizeSku --storage-sku $using:VirtualMachineStorageSku --admin-username $using:VirtualMachineAdminUsername --admin-password $using:VirtualMachineAdminPassword --authentication-type password --nics $nic.NewNIC.id --assign-identity [system] --enable-agent $true @optionalParameters --only-show-errors --tags ${$ResourceTags}

    Write-Host "Virtual Machine created: '$virtualMachineName'"
}
Write-Footer -ScopedPSCmdlet $PSCmdlet