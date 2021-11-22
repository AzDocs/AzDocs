function Set-DiagnosticSettings
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $ResourceId,
        [Parameter(Mandatory)][string] $ResourceName, 
        [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
        [Parameter()][System.Object[]] $DiagnosticSettingsLogs,
        [Parameter()][System.Object[]] $DiagnosticSettingsMetrics
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    if (!$DiagnosticSettingsLogs)
    {
        Write-Host "No diagnostic settings for logs were specified. Continueing with the default set"
        $DiagnosticSettingsLogs = Get-DefaultDiagnosticSettings -ResourceId $ResourceId -DiagnosticSettingType 'Logs'
    }

    if (!$DiagnosticSettingsMetrics)
    {
        Write-Host "No diagnostic settings for metrics were specified. Continueing with the default set"
        $DiagnosticSettingsMetrics = Get-DefaultDiagnosticSettings -ResourceId $ResourceId -DiagnosticSettingType 'Metrics'
    }

    # Get root path and make sure the right provider is registered
    $RootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    & "$RootPath\Resource-Provider\Register-Provider.ps1" -ResourceProviderNamespace 'Microsoft.Insights'

    # Set the name for the diagnostic setting 
    $diagnosticSettingName = "$ResourceName-diagnostic-setting"

    # Remove existing diagnostic setting
    Remove-DiagnosticSetting -ResourceId $ResourceId -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $ResourceName

    # Create the diagnostic setting
    $optionalParameters = @()
    if ($DiagnosticSettingsMetrics)
    {
        # Confirm the diagnostic setting exists
        Confirm-DiagnosticSettings -ResourceId $ResourceId -DiagnosticSettings $DiagnosticSettingsMetrics -DiagnosticSettingType "Metrics"

        $metrics = New-DiagnosticSetting -DiagnosticSettings $DiagnosticSettingsMetrics
        $optionalParameters += "--metrics", "$metrics"
    }
    if ($DiagnosticSettingsLogs)
    {
        # Confirm the diagnostic setting exists
        Confirm-DiagnosticSettings -ResourceId $ResourceId -DiagnosticSettings $DiagnosticSettingsLogs -DiagnosticSettingType "Logs"

        $logs = New-DiagnosticSetting -DiagnosticSettings $DiagnosticSettingsLogs
        $optionalParameters += "--logs", "$logs"
    }
       
    # Create new diagnostic setting
    Invoke-Executable az monitor diagnostic-settings create --resource $ResourceId --name $diagnosticSettingName --workspace $LogAnalyticsWorkspaceResourceId @optionalParameters

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Remove-DiagnosticSetting
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $ResourceId,
        [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
        [Parameter(Mandatory)][string] $ResourceName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $diagnosticSettingName = "$ResourceName-diagnostic-setting"

    $existingDiagnosticSettings = Invoke-Executable az monitor diagnostic-settings list --resource $ResourceId | ConvertFrom-Json
    foreach ($diagnosticSetting in $existingDiagnosticSettings.value)
    {
        if ($diagnosticSetting.name -and $diagnosticSetting.name -eq $DiagnosticSettingName -and $diagnosticSetting.workspaceId -eq $LogAnalyticsWorkspaceResourceId)
        {
            Write-Host "Removing diagnostic settings $DiagnosticSettingName"
            # remove old diagnostic setting
            Invoke-Executable az monitor diagnostic-settings delete --name $diagnosticSetting.name --resource $ResourceId
        }
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Get-DefaultDiagnosticSettings
{
    [CmdletBinding()]
    param (
        [Parameter()][string] $ResourceId,
        [Parameter()][string][ValidateSet("Logs", "Metrics")] $DiagnosticSettingType
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $availableDiagnosticSettings = (Invoke-Executable az monitor diagnostic-settings categories list --resource $ResourceId | ConvertFrom-Json).value
    $settings = ($availableDiagnosticSettings | Where-Object { $_.categoryType -eq $DiagnosticSettingType }).name
    
    Write-Output $settings
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function New-DiagnosticSetting
{
    [CmdletBinding()]
    param (
        [Parameter()][System.Object[]] $DiagnosticSettings
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $diagnosticSettingsToCreate = @()
    foreach ($diagnosticSetting in $DiagnosticSettings)
    {
        $diagnosticSettingsToCreate += [PSCustomObject]@{
            Category = $diagnosticSetting
            Enabled  = $true
        }
    }

    Write-Output ($diagnosticSettingsToCreate | ConvertTo-Json -Compress -AsArray).Replace('"', '\"')
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Confirm-DiagnosticSettings
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $ResourceId,
        [Parameter()][System.Object[]] $DiagnosticSettings,
        [Parameter()][string][ValidateSet("Logs", "Metrics")] $DiagnosticSettingType
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $availableDiagnosticSettings = (Invoke-Executable az monitor diagnostic-settings categories list --resource $ResourceId | ConvertFrom-Json).value
    Write-Host "Available diagnostic settings $($availableDiagnosticSettings.name)"
    if ($DiagnosticSettings)
    {
        foreach ($diagnosticSetting in $DiagnosticSettings) 
        {
            $foundDiagnosticSettings = $availableDiagnosticSettings | Where-Object { $_.categoryType -eq $DiagnosticSettingType }
            if (!($foundDiagnosticSettings.name -contains $diagnosticSetting))
            {
                Write-Output $false
                throw "Diagnostic setting $DiagnosticSettingType category: $diagnosticSetting  is unknown for this resource. Please specify a category that exists."
            }
        }
    }

    Write-Output $true

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}