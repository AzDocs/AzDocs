[CmdletBinding()]
param (
    [Alias]("ResourceGroupName")]
    [Parameter(Mandatory)][string] $ResourceGroupName,
    [Alias("StorageAccountName")]
    [Parameter(Mandatory)][string] $BlobStorageAccountName,
    [Alias("QueueName")]
    [Parameter(Mandatory)][string] $QueueName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

#$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
#$ctx = $storageAccount.Context
#New-AzStorageQueue –Name $queueName -Context $ctx

Write-Footer -ScopedPSCmdlet $PSCmdlet