# Change Log

All notable changes to this project will be documented in this file.

## [2021.08.04]

### Added

- Added parameter `PostgreSqlServerMinimalTlsVersion` to `Create-PostgreSQL-Server.ps1`.
- Added parameter `StorageAccountMinimalTlsVersion` to `Create-Storage-account.ps1`.
- Added parameter `AppServiceMinimalTlsVersion` to `Create-Web-App.ps1`.
- Added parameter `FunctionAppMinimalTlsVersion` to `Create-Function-App.ps1`.
- Added warnings when not using TLS version 1.2 or higher.
- Added `-ForceDisableTLS` to the scripts which spin up resources that can allow this to avoid creating resources without TLS enforcement unintentionally.

## [2021.07.30]

### Added

- Added ServiceBus

## [2021.07.29]

### Breaking Changes

- Removed `ApplicationSubnetName` from `Create-App-Configuration.ps1` since it was not being used.

### Added

- Added `-ForcePublic` to the scripts which spin up resources to avoid creating public resources unintentionally.
- Added Regression Tests & Test.API to AzDocs! We are now able to run tests when changing our scripts.
- Corrected `Create-Log-Analytics-Workspace` documentation for the `LogAnalyticsWorkspaceSolutionTypes` parameter.

### Removed

- Removed `SqlServerSubscriptionId` from `Create-SQL-Server`. This is now fetched automatically.

## [2021.07.26]

New scripts and improvements!
We've improved the creation of the diagnostic settings which are crucial for the metrics and logs of your resources! Next to that, we've added some new features
to use in your platform.

Happy deploying!

### Breaking Changes

- Removed `AppConfigDiagnosticsName` from `Create-App-Configuration.ps1`
- Removed `AppServiceDiagnosticsName` from `Create-Web-App-Linux.ps1`
- Removed `AppServiceDiagnosticsName` from `Create-Web-App-Windows.ps1`
- Removed `AppServiceDiagnosticsName` from `Create-Web-App-with-App-Service-Plan-Windows.ps1`
- Removed `AppServiceDiagnosticsName` from `Create-Web-App-with-App-Service-Plan-Linux.ps1`
- Removed `FunctionAppDiagnosticsName` from `Create-Function-App-Linux.ps1`
- Removed `FunctionAppDiagnosticsName` from `Create-Function-App-Windows.ps1`
- Removed `FunctionAppDiagnosticsName` from `Create-Function-App-Windows-with-App-Service-Plan.ps1`
- Removed `FunctionAppDiagnosticsName` from `Create-Function-App-Linux-with-App-Service-Plan.ps1`
- Removed `KeyvaultDiagnosticsName` from `Create-Keyvault.ps1`
- Added diagnostic settings to `Create-Blobcontainer-in-StorageAccount.ps1`
  - Added mandatory parameters `StorageAccountResourceGroupName` and `LogAnalyticsWorkspaceResourceId`
- Added diagnostic settings to `Create-Fileshare-in-StorageAccount.ps1`
  - Added mandatory parameters `LogAnalyticsWorkspaceResourceId`
- Added diagnostic settings to `Create-Queue-in-StorageAccount.ps1`
  - Added mandatory parameters `StorageAccountResourceGroupName` and `LogAnalyticsWorkspaceResourceId`
- Added diagnostic settings to `Create-Storage-Account.ps1`
  - Added mandatory parameters `LogAnalyticsWorkspaceResourceId`
- Added diagnostic settings to `Create-Container-Registry.ps1`
  - Added mandatory parameters `LogAnalyticsWorkspaceResourceId`
- Added diagnostic settings to `Create-MySQL-Server.ps1`
  - Added mandatory parameters `LogAnalyticsWorkspaceResourceId`
- Added diagnostic settings to `Create-PostgreSQL-Server.ps1`
  - Added mandatory parameters `LogAnalyticsWorkspaceResourceId`
- Added diagnostic settings to `Create-RedisCache-Instance.ps1`
  - Added mandatory parameters `LogAnalyticsWorkspaceResourceId`
- Added diagnostic settings to `Create-SQL-Database.ps1`
  - Added mandatory parameters `LogAnalyticsWorkspaceResourceId`
- Added diagnostic settings to `Create-AppInsights-Resource.ps1`
  - Added mandatory parameters `LogAnalyticsWorkspaceResourceId`
- Added diagnostic settings to `Create-Application-Gateway.ps1`
  - Added mandatory parameters `LogAnalyticsWorkspaceResourceId`

### Added

- Added the possibility to add an elastic pool to your sql server in script `Add-Elastic-Pool-To-SQL-Server.ps1`
- Added the possibility to add your database to an elastic pool in script `Create-SQL-Database.ps1`
- Added the possibility to deprovision an entry point in the Application Gateway (including certificates) in script `Remove-Application-Gateway-Entrypoint.ps1`
- Added the possiblity to add a custom dns server to a VNET in script `Add-Custom-DNS-Server-To-VNET.ps1`

## [2021.07.19]

We are excited to bring you the big release of the overall documentation containing architectural explanations!

### Breaking Changes

None!

### Added

- Documentation
  - Recommended architecture
  - Which components are available?
  - Tutorials on how to setup this boilerplate in your Azure DevOps environment.
  - How to use these scripts?
  - Guidelines for creating new scripts & contributing to this repository.
  - Application Gateway information & Best practises
  - Networking information (private endpoints & vnet whitelisting)
  - Logging & monitoring
  - Deprovisioning
- Added WAF options to the [Create Application Gateway](/Azure/Azure-CLI-Snippets/Application-Gateway/Create-Application-Gateway) script.
- Added the [Add DDoS Protection To Vnet](/Azure/Azure-CLI-Snippets/Networking/Add-DDoS-Protection-To-Vnet) script.
- Reset the Wiki order of components to alphabetical (for easier finding your components).

Note: as always this is work in progress and will be subjected to changes & additions.

## [2021.06.23]

A networking release! We've made sure it is easier to interact with different kind of networking whitelisting/dewhitelisting actions within you platform.

### Breaking Changes

- Filename changed from `Add-IP-Whitelist-To-{resource}.ps1` to `Add-Network-Whitelist-To-{resource}.ps1`
- Filename changed from `Remove-IP-Whitelist-from-{resource}.ps1` to `Remove-Network-Whitelist-from-{resource}.ps1`
- Removed parameter `WhitelistMyIp` from `Add-Network-Whitelist-to-App-Service.ps1` (only breaking if used)
- Removed parameter `WhitelistMyIp` from `Add-Network-Whitelist-to-Function-App.ps1` (only breaking if used)
- Removed script `Disable-public-access-for-SQL-Server.ps1`
- Removed script `Enable-public-access-for-SQL-Server.ps1`
- Removed script `Remove-agent-whitelists-from-SQL-Server.ps1`
- Removed script `Whitelist-Subnet-for-StorageAccount.ps1`

### Added

- Added network whitelist scripts for Redis Cache.
- Added network whitelist scripts for Keyvault.
- Added network whitelist scripts for MySql.
- Added network whitelist scripts for PostgreSql.
- Added network whitelists scripts for StorageAccount
