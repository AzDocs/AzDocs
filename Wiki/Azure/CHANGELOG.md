# Change Log

All notable changes to this project will be documented in this file.

## [2021.07.19]
We are excited to bring you the big release of the overall documentation containing architectural explainations!

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
