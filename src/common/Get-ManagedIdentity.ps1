function Get-ManagedIdentity {
    [CmdletBinding(DefaultParameterSetName = 'webapp')]
    param (
        # Switches for which resource we are talking about
        [Parameter(Mandatory, ParameterSetName = 'webapp')][switch] $AppService,
        [Parameter(Mandatory, ParameterSetName = 'functionapp')][switch] $FunctionApp,
        [Parameter(Mandatory, ParameterSetName = 'appconfig')][switch] $AppConfig,
        # Parameters
        [Parameter(Mandatory)][string] $ResourceName,
        [Parameter(Mandatory)][string] $ResourceGroupName,
        [Parameter(ParameterSetName = 'webapp')][Parameter(ParameterSetName = 'functionapp')][string] $AppServiceSlotName
    )
    #region ===BEGIN IMPORTS===
    . "$PSScriptRoot\Write-HeaderFooter.ps1"
    . "$PSScriptRoot\Invoke-Executable.ps1"
    #endregion ===END IMPORTS===

    Write-Header

    $appType = $PSCmdlet.ParameterSetName
    $additionalParameters = @()
    $fullAppName = $ResourceName

    if ($AppServiceSlotName) {
        $additionalParameters += '--slot' , $AppServiceSlotName
        $fullAppName += "[$AppServiceSlotName]"
    }

    $identityId = (Invoke-Executable az $appType identity show --resource-group $ResourceGroupName --name $ResourceName @additionalParameters | ConvertFrom-Json).principalId
    if (-not $identityId) {
        throw "Could not find identity for $fullAppName"
    }
    Write-Host "Identity for $fullAppName : $identityId"

    Write-Output $identityId

    Write-Footer
}