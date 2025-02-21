
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
