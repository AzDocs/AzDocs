
@description('Name of the capacity')
@minLength(3)
@maxLength(63)
param capacityName string

@description('Number of units')
@minValue(1)
@maxValue(100)
param numberOfUnits int = 1

@description('Whether to allow cross-geo compute')
param crossGeoCompute 'NotAllowed' | 'Allowed' = 'NotAllowed'

@description('Location of the capacity')
param location 'westeurope' | 'australiaeast' | 'eastus' | 'uksouth' = 'westeurope'

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

output capacityId string = capacity.id
