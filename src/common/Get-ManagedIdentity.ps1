function Get-ManagedIdentity {
    [CmdletBinding(DefaultParameterSetName = 'webapp')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'functionapp')]
        [switch] $Functionapp,

        [Parameter(Mandatory, ParameterSetName = 'appconfig')]
        [switch] $Appconfig,

        [Parameter(Mandatory, ParameterSetName = 'webapp')]
        [Parameter(Mandatory, ParameterSetName = 'functionapp')]
        [Parameter(Mandatory, ParameterSetName = 'appconfig')]
        [String] $Name,

        [Parameter(Mandatory, ParameterSetName = 'webapp')]
        [Parameter(Mandatory, ParameterSetName = 'functionapp')]
        [Parameter(Mandatory, ParameterSetName = 'appconfig')]
        [String] $ResourceGroup,

        [Parameter(ParameterSetName = 'webapp')]
        [Parameter(ParameterSetName = 'functionapp')]
        [String] $SlotName
    )

    #region ===BEGIN IMPORTS===
    . "$PSScriptRoot\Invoke-Executable.ps1"
    #endregion ===END IMPORTS===

    $appType = $PSCmdlet.ParameterSetName
    $additionalParameters = @()
    $fullAppName = $AppServiceName

    if ($AppServiceSlotName) {
        $additionalParameters += '--slot' , $AppServiceSlotName
        $fullAppName += "[$AppServiceSlotName]"
    }

    $identityId = (Invoke-Executable az $appType identity show --resource-group $AppServiceResourceGroupName --name $AppServiceName @additionalParameters | ConvertFrom-Json).principalId
    if (-not $identityId) {
        throw "Could not find identity for $fullAppName"
    }
    Write-Host "Identity for $fullAppName : $identityId"
    return $identityId
}