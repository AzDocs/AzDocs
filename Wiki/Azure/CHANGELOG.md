# Change Log

All notable changes to this project will be documented in this file.

## [2021.06.23.1-master]

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
- Added network whitelists scripts for StorageAccou
