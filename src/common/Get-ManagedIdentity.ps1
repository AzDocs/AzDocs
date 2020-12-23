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
    . "$PSScriptRoot\Write-HeaderFooter.ps1"
    . "$PSScriptRoot\Invoke-Executable.ps1"
    #endregion ===END IMPORTS===

    Write-Header

    $appType = $PSCmdlet.ParameterSetName
    $additionalParameters = @()
    $fullAppName = $Name

    if ($SlotName) {
        $additionalParameters += '--slot' , $SlotName
        $fullAppName += "[$SlotName]"
    }

    $identityId = (Invoke-Executable az $appType identity show --resource-group $ResourceGroup --name $Name @additionalParameters | ConvertFrom-Json).principalId
    if (-not $identityId) {
        throw "Could not find identity for $fullAppName"
    }
    Write-Host "Identity for $fullAppName : $identityId"

    Write-Output $identityId

    Write-Footer
}