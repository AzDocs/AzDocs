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

    Write-Header -ScopedPSCmdlet $PSCmdlet

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
    foreach ($oldDiagnosticSetting in $oldDiagnosticSettings.value)
    {
        if ($oldDiagnosticSetting.name -and $oldDiagnosticSetting.name -ne $diagnosticSettingName -and $oldDiagnosticSetting.workspaceId -eq $LogAnalyticsWorkspaceResourceId)
        {
            # remove old diagnostic setting
            Invoke-Executable az monitor diagnostic-settings delete --name $oldDiagnosticSetting.name --resource $ResourceId
        }
    }

    # Create new diagnostic setting
    Invoke-Executable az monitor diagnostic-settings create --resource $ResourceId --name $diagnosticSettingName --workspace $LogAnalyticsWorkspaceResourceId @optionalParameters

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Get-DiagnosticSettingBasedOnTier
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][ValidateSet("webapp")][string] $ResourceType,
        [Parameter(Mandatory)][string] $CurrentResourceTier
    )

    #  Create diagnostics settings & make sure to check which categories can be accessed based upon the SKU of the app service plan
    # https://docs.microsoft.com/en-us/azure/app-service/troubleshoot-diagnostic-logs#send-logs-to-azure-monitor-preview

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $diagnosticSettingToReturn = $null
    if ($ResourceType -eq 'webapp')
    {
        $allowedWebAppTiers = @("Premium", "PremiumV2", "PremiumV3")
        if ($allowedWebAppTiers -contains $CurrentResourceTier)
        {
            $diagnosticSettingToReturn = [PSCustomObject]@{
                DiagnosticSettingType  = "Logs"
                DiagnosticSettingValue = "[{ 'category': 'AppServiceHTTPLogs', 'enabled': true }, { 'category': 'AppServiceConsoleLogs', 'enabled': true }, { 'category': 'AppServiceAppLogs', 'enabled': true }, { 'category': 'AppServiceFileAuditLogs', 'enabled': true }, { 'category': 'AppServiceIPSecAuditLogs', 'enabled': true }, { 'category': 'AppServicePlatformLogs', 'enabled': true }, { 'category': 'AppServiceAuditLogs', 'enabled': true } ]".Replace("'", '\"')
            }
        }
        else
        {
            $diagnosticSettingToReturn = [PSCustomObject]@{
                DiagnosticSettingType  = "Logs"
                DiagnosticSettingValue = "[{ 'category': 'AppServiceHTTPLogs', 'enabled': true }, { 'category': 'AppServiceConsoleLogs', 'enabled': true }, { 'category': 'AppServiceAppLogs', 'enabled': true }, { 'category': 'AppServiceIPSecAuditLogs', 'enabled': true }, { 'category': 'AppServicePlatformLogs', 'enabled': true }, { 'category': 'AppServiceAuditLogs', 'enabled': true } ]".Replace("'", '\"')
            }
        }
    }

    Write-Output $diagnosticSettingToReturn

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}