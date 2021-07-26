function Set-DiagnosticSettings
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $ResourceId,
        [Parameter(Mandatory)][string] $ResourceName, 
        [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
        [Parameter()][string] $Metrics,
        [Parameter()][string] $Logs
    )

    # Get root path and make sure the right provider is registered
    $RootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    & "$RootPath\Resource-Provider\Register-Provider.ps1" -ResourceProviderNamespace 'Microsoft.Insights'

    # Set the name for the diagnostic setting 
    $diagnosticSettingName = "$ResourceName-diagnostic-setting"

    $optionalParameters = @()
    if ($Metrics)
    {
        $optionalParameters += "--metrics", "$Metrics"
    }
    if ($Logs)
    {
        $optionalParameters += "--logs", "$Logs"
    }

    # For backwards compatibility, remove the old diagnostic settings 
    $oldDiagnosticSettings = Invoke-Executable az monitor diagnostic-settings list --resource $ResourceId | ConvertFrom-Json
    foreach ($oldDiagnosticSetting in $oldDiagnosticSettings)
    {
        # oldDiagnosticEtting.value
        if ($oldDiagnosticSetting.value.name -and $oldDiagnosticSetting.value.name -ne $diagnosticSettingName)
        {
            # remove old diagnostic setting
            Invoke-Executable az monitor diagnostic-settings delete --name $oldDiagnosticSetting.value.name --resource $ResourceId
        }
    }

    # Create new diagnostic setting
    Invoke-Executable az monitor diagnostic-settings create --resource $ResourceId --name $diagnosticSettingName --workspace $LogAnalyticsWorkspaceResourceId @optionalParameters
}