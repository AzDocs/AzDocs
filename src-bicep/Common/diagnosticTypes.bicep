metadata name = 'Common Diagnostic Settings Types'
metadata description = 'Shared user-defined types for Azure diagnostic settings across all modules.'

/*
.SYNOPSIS
Common diagnostic settings types for Azure resources
.DESCRIPTION
This module defines shared user-defined types for diagnostic settings that can be used across all Azure resource modules.
These types provide type safety and documentation for diagnostic settings parameters.
.LINKS
- [Azure Monitor diagnostic settings](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?pivots=deployment-language-bicep)
*/

// ================================================= User-Defined Types =================================================

@export()
@description('Diagnostic settings log category configuration')
type diagnosticLogCategory = {
  @description('The name of the log category')
  category: string?

  @description('The name of the log category group')
  categoryGroup: string?

  @description('Whether the log category is enabled')
  enabled: bool

  @description('The retention policy for the log category')
  retentionPolicy: {
    @description('The number of days to retain the logs')
    days: int

    @description('Whether the retention policy is enabled')
    enabled: bool
  }?
}

@export()
@description('Diagnostic settings metrics category configuration')
type diagnosticMetricCategory = {
  @description('The name of the metric category')
  category: string

  @description('Whether the metric category is enabled')
  enabled: bool

  @description('The retention policy for the metric category')
  retentionPolicy: {
    @description('The number of days to retain the metrics')
    days: int

    @description('Whether the retention policy is enabled')
    enabled: bool
  }?

  @description('The time grain for the metric category')
  timeGrain: string?
}
