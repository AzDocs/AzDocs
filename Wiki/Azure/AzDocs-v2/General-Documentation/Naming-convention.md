[[_TOC_]]

# Proposed naming convention

There is no hardcoded naming conventions in the AzDocs v2. However we do propose a naming convention to make things smooth & easy sailing. In this Wiki page we will describe this naming convention. This proposal is written with automation in the back of the mind.

# Environmenttypes

- [TLA](https://en.wikipedia.org/wiki/Three-letter_acronym) to avoid clashes in automation
- Avoid single character env names to avoid oopsies (accidentaly reading a `c` instead of `o` for example).
- Suffix everything with environmenttype (this should always be the last part).

Options we use:

- lab
- dev
- tst
- acc
- prd

Make sure to keep a maximum number of characters in your environmenttypes to avoid names from getting too long.

# Managementgroups

- This is an administrative unit, so use logical & human readable naming
- Use dashes instead of spaces (due to possible encoding/decoding in automation and potential oopsies)
- Don't suffix or prefix with -mg (Microsoft does this in their documentation), since on this level we have just one type of entity; the managementgroup. Adding any resourcetype suffix only creates harder reading when scanning management groups in the portal.

Examples:

```
Tenant root managementgroup (default)
Tenant root managementgroup (default) --> Root-Container
Tenant root managementgroup (default) --> Root-Container --> some-org
Tenant root managementgroup (default) --> Root-Container --> my-org --> On-premises
Tenant root managementgroup (default) --> Root-Container --> my-org --> Platform
Tenant root managementgroup (default) --> Root-Container --> my-org --> Landing-Zones
Tenant root managementgroup (default) --> Root-Container --> my-org --> Decommissioned
Tenant root managementgroup (default) --> Root-Container --> my-org --> Sandboxed
Tenant root managementgroup (default) --> Root-Container --> my-org --> Proof-of-Concepts
Tenant root managementgroup (default) --> Root-Container --> my-org --> Platform --> Identity
Tenant root managementgroup (default) --> Root-Container --> my-org --> Platform --> Management
Tenant root managementgroup (default) --> Root-Container --> my-org --> Platform --> Connectivity
Tenant root managementgroup (default) --> Root-Container --> my-org --> Sandboxed --> Dexters-Laboratory
Tenant root managementgroup (default) --> Root-Container --> my-org --> Sandboxed --> Development
Tenant root managementgroup (default) --> Root-Container --> my-org --> Sandboxed --> Test
Tenant root managementgroup (default) --> Root-Container --> my-org --> Sandboxed --> Acceptance
Tenant root managementgroup (default) --> Root-Container --> my-org --> Sandboxed --> Production
Tenant root managementgroup (default) --> Root-Container --> my-org --> Landing-Zones --> Development
Tenant root managementgroup (default) --> Root-Container --> my-org --> Landing-Zones --> Test
Tenant root managementgroup (default) --> Root-Container --> my-org --> Landing-Zones --> Acceptance
Tenant root managementgroup (default) --> Root-Container --> my-org --> Landing-Zones --> Production
```

# Subscriptions

- All lowercase
- This is an administrative unit, so use logical & human readable naming
- Use dashes instead of spaces (and other special characters) (due to possible encoding/decoding in automation and potential oopsies)
- multiple dashes will be consolidated to one.
- Don't suffix or prefix with anything like -sub or w/e, since on this level we have just one type of entity; the subscription. Adding any resourcetype suffix only creates harder reading when scanning management groups in the portal.
- We add a shortname for the subscription with min 8 max 18 characters. --> This should be filled during onboarding (verify if its unique). This shortname can be used for resource names.

Example formats:

- `<CompanyAbbreviation (TLA, UPPERCASE)>-<Department (PascalCase)>-<EnvironmentType (TLA, lowercase)>`
- `<CompanyAbbreviation (TLA, UPPERCASE)>-<Team (PascalCase)>-<EnvironmentType (TLA, lowercase)>`
- `<CompanyAbbreviation (TLA, UPPERCASE)>-<ApplicationName (PascalCase)>-<EnvironmentType (TLA, lowercase)>`
- `<CompanyAbbreviation (TLA, UPPERCASE)>-<Purpose (PascalCase)>-<EnvironmentType (TLA, lowercase)>`

Examples:

```
org-someapp-dev
{companyAbbr}-{appstack}-{env}

org-anotherapp-acc
{companyAbbr}-{appstack}-{env}

org-myteam-dev
{companyAbbr}-{team}-{env}

org-mydepartment-dev
{companyAbbr}-{department}-{env}
```

# Resourcegroups

- All lowercase
- This is an administrative unit, so use logical & human readable naming
- Use dashes instead of spaces (due to possible encoding/decoding in automation and potential oopsies)
- Don't prefix or suffix with anything like -rg or w/e, since on this level we have just one type of entity; the resourcegroup. Adding any resourcetype suffix only creates harder reading when scanning management groups in the portal.

- `<Purpose/Scope>[-<Component>]-<EnvironmentType>`

Examples:

```
myapp-dev
myapp-prd
anotherapp-portal-acc (if splitting based on component is desired)
anotherapp-api-acc (if splitting based on component is desired)
```

Actually the first part is pretty much freeformat as long as the functional purpose is clear/deductable. Simply always suffix with envtype for easy glancing.

For the Shared resource group we propose:
platform-<EnvironmentType>

# Resources

- All lowercase
- Use dashes instead of spaces (due to possible encoding/decoding in automation and potential oopsies)

This is where it gets truely interesting.

MS suggests that you CAN include the resourcetype in the name with it's abbreviation. However, its even more valuable to use resources types while building names for resources that actually are bound together. Think of a VM for example; it has a:

- Virtual Machine
- Network Interface
- Public IP
- OS Disk
- One or more Data Disks?
- Managed Identity
- AvailabilitySet

These resources are more or less bound together. So it holds value to reflect this in the naming. This is why we would propose the following:

Format:
`<ResourceTypeAbbreviation>[-<InstanceNumberPrefixedWith1LeadingZero>][-<MainResourceType>][-<MainResourceInstanceNumberPrefixedWith1LeadingZero>]-<Purpose>[-OptionalInfo][-azureregionabbreviation]-<EnvironmentType>`

NOTE:

- `ResourceTypeAbbreviation` is picked from [this official Microsoft list](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- Omit instancecount if we only have 1
- Omit region if its just west europe (no other locations) --> we for westeurope & ne for northeurope.
- If you have multiple references to the environment --> consolidate to one suffix at the end (avoid `-dev-dev`).
- For Shared resources in your Shared resource group, use the `SubscriptionName` as `Purpose`.
- For specific resourcetypes like storageaccounts we have limited naming capabilities. In the automations we will simply strip the symbols & spaces.
- OPTIONAL: Use a shortname for when resourcenames get too long.

Normal app stack resources:
NOTE: Lets try to avoid teamnames --> we used to do this at our old department, but if an appstack gets handed over to another team, you have a challenge :).

Example with a Virtual Machine:

- `vm-01-myapp-dev` --> This is the Virtual Machine name itself. Note: max 15 characters for Windows.
- `nic-vm-01-myapp-dev` --> The Network Interface; The Virtual Machine name prefixed with `nic-`
- `pip-vm-01-myapp-dev` --> The Public IP; The Virtual Machine name prefixed with `pip-`
- `osdisk-vm-01-myapp-dev` --> The OS Disk; The Virtual Machine name prefixed with `osdisk-`
- `disk-01-vm-01-myapp-dev` --> 1st Data disk; The Virtual Machine name prefixed with `disk-01-`
- `disk-02-vm-01-myapp-dev` --> 2nd Data disk; The Virtual Machine name prefixed with `disk-02-`
- `disk-03-vm-01-myapp-dev` --> 3rd Data disk; The Virtual Machine name prefixed with `disk-03-`
- `id-vm-01-myapp-dev` --> The managed identity; The Virtual Machine name prefixed with `id-`
- `avail-vm-01-myapp-dev` --> The Availability Set; The Virtual Machine name prefixed with `avail-`

Example with App Services:

- `app-myapp-frontend-dev` (This could be an App Service)
- `app-myapp-api-dev` (This could be an Function App)
  OR if myapp only exists out of 1 component (just 1 app service):
- `app-myapp-dev`

When the myapp appservice frontend would be multi-region:

- `app-myapp-frontend-we-dev` --> Frontend in West Europe
- `app-myapp-frontend-ne-dev` --> Frontend in North Europe

Example with a public & private Application Gateway:

- `agw-01-subscriptionname-pub-dev`
  - `pip-agw-01-subscriptionname-pub-dev`
  - `id-agw-01-subscriptionname-pub-dev`
  - `waf-agw-01-subscriptionname-pub-dev`
- `agw-01-subscriptionname-pvt-dev`
  - `pip-agw-01-subscriptionname-pvt-dev`
  - `id-agw-01-subscriptionname-pvt-dev`
  - `waf-01-subscriptionname-pvt-dev`

Example with a Virtual Network:

- `vnet-subscriptionname-dev`
  - `rt-vnet-subscriptionname-dev`

# Childresources

The last, but not least thing we have to talk about is childresources.

- All lowercase
- Use dashes instead of spaces (due to possible encoding/decoding in automation and potential oopsies)

## Subnets

Format:
`snet-[<AppStackName>-][<ComponentName>-]<Layer>-[OptionalInfo-]<InstanceNumberPrefixedWith1LeadingZero>-<EnvironmentType>`

Examples:

```
snet-gateway-public-01-dev
snet-gateway-private-01-dev
snet-frontend-01-dev
snet-app-01-prd
snet-data-01-acc
snet-<appstackname>-app-01-dev
```

## Network Security Groups

Format:
`nsg-<SubnetName>`

Examples:

```
nsg-snet-gateway-public-01-dev
nsg-snet-app-01-prd
```

## Routetables

Routetable that applies to a Subnet:

Format:
`rt-<VnetNameWithoutEnvironmentTypeSuffix>-<SubnetName>`

Examples:
`rt-MySubscription-vnet-snet-app-01-dev`

Routetable that acts as the default routetable for the subnets within the Virtual Network):

Format:
`rt-<VnetName>`

Examples:
`rt-MySubscription-vnet-dev`

## Application Gateway:

Here we will describe the proposed naming for the Application Gateway subresources

## Ports

These are based on the defaults from MS:

- For port 80: `Port_80`
- For port 443: `Port_443`

## Listeners/BackendPools/HTTPSettings/Probes/Rewrites/Rules

AppGw listeners/backendpools/httpsettings/probes/rewrites/rules:

```
For the url test.dev.appstack.mycompany.com:
HTTPS listener: test-dev-appstack-mycompany-com-httpslistener
HTTP listener (which redirects to HTTPS): test-dev-appstack-mycompany-com-httplistener
Backendpool: test-dev-appstack-mycompany-com-backendaddresspool
HTTP Settings: test-dev-appstack-mycompany-com-backendaddresssettings
Rules: test-dev-appstack-mycompany-com-requestroutingrule
Rewriteset: test-dev-appstack-mycompany-com-httpsrewriteset
Healthprobe: test-dev-appstack-mycompany-com-httpsprobe

For the url test-something.dev.appstack.mycompany.com:
HTTPS listener: test--something-dev-appstack-mycompany-com-httpslistener
HTTP listener (which redirects to HTTPS): test--something-dev-appstack-mycompany-com-httplistener
Backendpool: test--something-dev-appstack-mycompany-com-backendaddresspool
HTTP Settings: test--something-dev-appstack-mycompany-com-backendaddresssettings
Rules: test--something-dev-appstack-mycompany-com-requestroutingrule
Rewriteset: test--something-dev-appstack-mycompany-com-httpsrewriteset
Healthprobe: test--something-dev-appstack-mycompany-com-httpsprobe
```

Apply this naming scheme for the input URL's:

- replace `-` with `--` & `.` with `-` to avoid clashes and easy glance.
- Suffix with the childresourcetype

# Policies

- This is an administrative unit, so use logical & human readable naming
- Use dashes instead of spaces (due to possible encoding/decoding in automation and potential oopsies)

## Policy definitions

Format (For the technical name):
`<TeamOwnerNameAbbreviation>-<AzureServiceAbbreviation>-<Purpose>-[OptionalInfo-]<Effect>-<Version(Semver)>`

For example:

```
myteam-kv-diagnostics-settings-dine-v1.1.0
myteam-app-networking-audit-myteam-mg-allowed-location-audit-v1.0.3
```

Format (For the displayname):
`<TeamOwnerName> - <AzureService> - <Purpose> - <Effect> - <Version(Semver)>`
For example:

```
My Team - Key vault - Diagnostic Settings - DeployIfNotExists - v1.2.3
My Team - App Services - Networking - Audit - v1.1.6
My Team - Management Group - Allowed Locations - AUDIT - v1.7.4
```

### Effectstable

| Effect            | Shortname  |
| ----------------- | ---------- |
| Append            | `APPEND`   |
| Audit             | `AUDIT`    |
| AuditIfNotExists  | `AINE`     |
| Deny              | `DENY`     |
| DeployIfNotExists | `DINE`     |
| Disabled          | `DISABLED` |
| Modify            | `MODIFY`   |

## Policy Set

Format (For the technical name):
`<TeamOwnerNameAbbreviation>-<AzureServiceAbbreviation>-[OptionalInfo-]<Version(Semver)>`

For example:

```
myteam-kv-v1.0.0
myteam-app-v1.2.3
```

Format (For the displayname):
`<TeamOwnerName> - <AzureService> - <Version(Semver)>`
For example:

```
My Team - Key vault - v1.0.0
My Team - App Services - v1.2.1
My Team - Management Group - v1.5.4
```
