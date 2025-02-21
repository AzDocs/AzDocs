/*
.SYNOPSIS
Creating Security Copilot SCU's (Security compute units).
.DESCRIPTION
Microsoft Security Copilot (Security Copilot) is a generative AI-powered security solution that helps increase the efficiency and capabilities of defenders to improve security outcomes at machine speed and scale.
.EXAMPLE
<pre>
module vm 'br:contosoregistry.azurecr.io/securitycopilot/capacities:latest' = {
  name: 'deployment-scu'
  scope: resourceGroup
  params: {
    capacityName: 'copilot-capacity-dev'
  }
}
</pre>
<p>Creates a SCU (single one) for security copilot in west europe only</p>
.EXAMPLE
<pre>
module vm 'br:contosoregistry.azurecr.io/securitycopilot/capacities:latest' = {
  name: 'deployment-scus'
  scope: resourceGroup
  params: {
    capacityName: 'copilot-capacity-dev'
    numberOfUnits: 3
  }
}
</pre>
<p>Creates 3 SCU's for security copilot in west europe only</p>
.LINKS
- [Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/)
- [Provision with azure first](https://learn.microsoft.com/en-us/copilot/security/get-started-security-copilot#option-2-provision-capacity-in-azure)
*/

@description('Name of the capacity')
@minLength(3)
@maxLength(63)
param capacityName string

@description('Number of units')
@minValue(1)
@maxValue(100)
param numberOfUnits int = 1

@description('Whether to allow or not allow')
type isAllowed = 'NotAllowed' | 'Allowed'

@description('Whether to allow cross-geo compute')
param crossGeoCompute isAllowed = 'NotAllowed'

@description('Valid location of the capacity')
type locations = 'westeurope' | 'australiaeast' | 'eastus' | 'uksouth'

@description('Location of the capacity')
param location locations = 'westeurope'

var locationGeoMap = {
  westeurope: 'EU'
  australiaeast: 'ANZ'
  eastus: 'US'
  uksouth: 'UK'
}

var geo = locationGeoMap[location]

resource capacity 'Microsoft.SecurityCopilot/capacities@2023-12-01-preview' = {
  name: capacityName
  location: location
  properties: {
    numberOfUnits: numberOfUnits
    crossGeoCompute: crossGeoCompute
    geo: geo
  }
}

@description('ID of the capacity')
output capacityId string = capacity.id
