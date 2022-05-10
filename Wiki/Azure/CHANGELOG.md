# Change Log

All notable changes to this project will be documented in this file.
## [2022.05.09]
- Added `OriginHostHeader` to `Add-Origin-To-Front-Door.ps1`

## [2022.05.05]

## Changes
- Added `ConditionTransformBehavior` to `Add-Front-Door-Rule-For-Override-Route.ps1`.

## [2022.05.04]

## Changes
- Updated `Add-Front-Door-Rule-For-Override-Route.ps1` to be able to work with cli 2.36. 
- Updated `Create-Front-Door-EntryPoint.ps1`, removed `EndpointOriginResponseTimeoutInSeconds` parameter. 
- Added parameter `KeyvaultBypassTraffic` for `Create-Keyvault.ps1`.

## [2022.04.08]

## Added
- Added script `Add-Front-Door-Custom-Domain.ps1`
- Added script `Add-Front-Door-Rule-For-Override-Route.ps1`
- Added script `Add-Front-Door-ServiceTag-To-Resource.ps1`
- Added script `Add-Origin-To-Front-Door.ps1`
- Added script `Create-Front-Door-EntryPoint.ps1`
- Added script `Create-Front-Door-Profile.ps1`
- Added script `Create-WAF-Policy.ps1`
- Added script `Get-Front-Door-Id.ps1`

## [2022.03.22]

## Changes

- Added script `Create-VNet-Peering`.

## [2022.03.11]

## Changes

- Added `CORSUrls` param to `Create-Web-App.ps1` to configure allowed origins on app service

## [2022.02.24]

## Changes

- Added the following scripts for Logic Apps, `Create-Logic-App-Consumption.ps1` and `Create-Logic-App-Standard.ps1`.

## [2022.02.21]

## Breaking Changes

- When using the `Create-RedisCache-Instance.ps1` script, `ForcePublic` also has to be used when using the `RedisInstanceEnableNonSslPort` parameter.

## Changes

- Updated `Create-RedisCache-Instance.ps1` to be idempotent.
- Updated `Create-RedisCache-Instance.ps1` to be able to integrate your Redis Instance into a subnet.

## [2022.02.02]

- Added `PathBasedRouting` to `Create-Application-Gateway-Entrypoint-for-ContainerInstances.ps1` and `Create-Application-Gateway-Entrypoint-for-DomainName.ps1`

## [2022.01.21]

## Breaking Changes

- Removed `DisableDiagnosticSettings` from `Create-AppInsights-Resource.ps1`. Diagnostic settings will no be disabled by default for an App Insights resource. Added the possibility to add these Diagnostic settings to a separate workspace by using the parameter `DiagnosticSettingsLogAnalyticsWorkspaceResourceId`.

## [2022.01.18]

- Fixed `Create-Cost-Alert.ps1`

## [2022.01.10]

- Added documentation and example piplines to the AzDocs for a Dependabot integration with Azure Devops.

## [2021.12.21]

## Added

- Added `Create-Static-Web-App.ps1` for creating Static Web apps.

## [2021.12.09]

## Added

- Added script `Set-Tags-For-Resources.ps1`.

## [2021.12.08]

## Updated

- Updated `Create-Function-App.ps1` with added functionality for setting the default CORS settings for deployment slots.

## Breaking Changes

- Changed the default route all traffic throught vnet behaviour for Application service with vnet integration(`Add-VNet-integration-to-AppService.ps1`). The `RouteAllTrafficThroughVnet` is set to `false` now.
- Changed the default route all traffic throught vnet behaviour for Function app with vnet integration(`Add-VNet-integration-to-Function-App.ps1`). The `RouteAllTrafficThroughVnet` is set to `false` now.

## [2021.12.07]

## Added

- Added script `Deprovision-Cost-Alert.ps1`.

## [2021.12.01]

## Added

- Added script `Get-Monitor-Action-Group-Id-for-Pipeline.ps1`.

## [2021.11.24]

## Updated

- Improved the `Add-AD-Authentication-for-App-Service.ps1` script so that it can work with the `authv2` option.

## [2021.11.22]

## Updated

- Default CORS settings for function app have changes, by default the portal test urls are added, see `Azure.PlatformProvisioning\src\Functions\Create-Function-App.ps1` `CORSUrls` and `DisableCORSPortalTestUrls` settings.
  To disable this use the `DisableCORSPortalTestUrls` switch

## [2021.11.16]

## Updated

- Changed and added functionality to the `Create-CosmosDbAccount.ps1` script. Functionality has been added for: `Table`, `Gremlin` and `MongoDb`.
- Added the ability to pick a set of diagnostic settings for every resource.
- Added the ability to disable diagnostic settings for every resource.

## [2021.11.01]

## Breaking Changes

- Added mandatory parameter `AppServiceResourceGroupName` to `Grant-AppService-dataread-write-ddladmin-rights-on-SQL-Server.ps1`

## Added

- Added parameter `ApplyToAllSlots` to `Grant-AppService-dataread-write-ddladmin-rights-on-SQL-Server.ps1`
- Added parameter `ManagedIdentityApplyToAllSlots` to `Grant-Permissions-to-ManagedIdentity-on-Resource.ps1`

## [2021.10.26]

## Updated

- Added update functionality of ssl-profile to `Create-SSLTLS-Profile.ps1`.

## [2021.10.12]

## Updated

- Improved CosmosDB scripts
- Added Resource/ResourceGroup locking & unlocking

## [2021.10.06]

## Updated

- Updated `Create-CosmosDbCassandraKeyspace.ps1` with throughput functionality.
- Updated `Create-CosmosDbCassandraTable.ps1` with throughput functionality.
- Fixed Availability Zones in `Create-CosmosDbAccount.ps1`.

## [2021.09.24]

### Updated

- Updated `Create-Application-Gateway-Entrypoint-for-DomainName.ps1` to be able to update keyvault values in a VNet whitelisted keyvault.

## [2021.09.22]

### Added

- Added metric alert rule script [Create-Metric-Alert-Rule.ps1](../../src/Monitor/Create-Metric-Alert-Rule.ps1) in the `monitor` directory.
- Created `Get-Storage-Account-ConnectionString.ps1`.
- Created `Grant-Public-Access-to-StorageAccount.ps1` because of bug (ip from agent in the same region whitelisted is being ignored).
- Created `Remove-Public-Access-from-StorageAccount.ps1`.

### Updated

- Refactored `Set-Keyvault-permissions-for-AppService-Identity.ps1` to also have the ApplyToAllSlots possibility.
- Updated `Add-Network-Whitelist-to-Sql-Server.ps1` to be able to open it up publicly.
- Updated `Get-ObjectID-for-ServiceUser.ps1` to be able to output it as pipeline variable.
- Updated `pipeline-release.yml` to be able to run the regression test with both agents (windows, linux) for the variant that is spinned up publicly.
- Updated `pipeline-orchestrator.yml` to be able to tag the resources correctly.

## [2021.09.15]

### Breaking Changes

- In the case of using vnet integrated webapps or function apps, the default for the `RouteAllTrafficThroughVnet` is set to `true`.
- Changed `$FunctionAppAlwaysOn` parameter from string to boolean. This means that in your pipelines you will have to specify it as a boolean e.g. `$true` or `$false`.

### Added

- Added parameters `DisableVNetWhitelistForDeploymentSlot` and `DisablePrivateEndpointForDeploymentSlot` to Create-WebApp
- Added parameters to Create Function App `DisableVNetWhitelistForDeploymentSlot`, `DisablePrivateEndpointForDeploymentSlot`, `StopFunctionAppImmediatelyAfterCreation` and `StopFunctionAppSlotImmediatelyAfterCreation`
- Added functionality to automatically create deployment slots including VNet whitelisting or Private endpoints
- Added optional parameter `RouteAllTrafficThroughVnet` for `Add-VNet-integration-to-AppService.ps1`.
- Added optional parameter `RouteAllTrafficThroughVnet` for `Add-VNet-integration-to-Function-App.ps1`.
- Added migration script [Move-VnetRouteAllSettings.ps1](../../migration/Move-VnetRouteAllSettings.ps1) in the `migration` directory for moving the vnet route all setting to the vnet integration settings.

## [2021.08.12]

- Added parameter `KeyvaultSku`,`KeyvaultPurgeProtectionEnabled` and `KeyvaultRetentionInDays` to `Create-Keyvault.ps1`.
- Added `-ForceDisablePurgeProtection` to avoid creating keyvaults without purge-protection enabled unintentionally.
- Added fixes to the `Create-Application-Gateway-Entrypoint` scripts and to the `Remove-Application-Gateway-Entrypoint` script.

## [2021.08.11]

- Added support for updating Tags on resources in a generic way (`Set-ResourceTagsForResource`).
- Refactored some code and removed some unneeded CLI statements.

## [2021.08.10]

- Fix for backwards-compatibility with diagnostic settings.
- Forcing that the log retention on a Log Analytics Workspace is set to 180 days.
- Forcing that the expiry date of a key or secret is not longer thant 397 days.
- Added `KeyExpiresInDays` to `Create-Keyvault-Key.ps1`. Defaults to 397 days.
- Added `KeyNotBeforeInDays` to `Create-Keyvault-Key.ps1`.

## Breaking Changes

- In script `Create-Keyvault-Secret` changed parameter `SecretExpires` in `SecretExpiresInDays` and `SecretNotBefore` in `SecretNotBeforeInDays`. This means the expiration date will now be calculated for you, and you are able to specify this by using days.

## [2021.08.09]

- Renamed `Get-Log-Analytics-Workspace-Id-for-Pipeline` to `Get-Log-Analytics-Workspace-ResourceId-for-Pipeline` because this script retrieves the resource id instead of the (Customer) ID.
- Added a new `Get-Log-Analytics-Workspace-Id-for-Pipeline` script which actually gets the (Customer) ID.
- Expanded Regression Tests pipeline
- Made Regression Tests pipeline parallel executable
- Added toggles for enabling/disabling Regression Tests pipeline
- Changed the behaviour for the `PostgreSqlServerPublicNetworkAccess` flag in `Create-PostgreSQL-Server` in combination with VNet whitelisting. From now on if you choose VNet whitelisting, the `PostgreSqlServerPublicNetworkAccess` will forcefully be enabled (this is needed for VNet whitelisting to work)
- Loads of docs fixes

## [2021.08.05]

### Added

- Added parameter `PostgreSqlServerMinimalTlsVersion` to `Create-PostgreSQL-Server.ps1`.
- Added parameter `StorageAccountMinimalTlsVersion` to `Create-Storage-account.ps1`.
- Added parameter `AppServiceMinimalTlsVersion` to `Create-Web-App.ps1`.
- Added parameter `FunctionAppMinimalTlsVersion` to `Create-Function-App.ps1`.
- Added warnings when not using TLS version 1.2 or higher.
- Added `-ForceDisableTLS` to the scripts which spin up resources that can allow this to avoid creating resources without TLS enforcement unintentionally.
- Added a extra check for not allowing all access when setting the "Any" network whitelisting (0.0.0.0/\*).

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
