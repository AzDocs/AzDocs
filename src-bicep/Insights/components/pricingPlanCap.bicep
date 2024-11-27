@description('Enter daily quota in GB.')
@minValue(1)
param dailyQuota int

@description('Enter the % value of daily quota after which warning mail to be sent.')
@minValue(1)
@maxValue(100)
param warningThreshold int

@description('Parent Application Insights resource')
@minLength(1)
param applicationInsightsName string

resource applicationInsights 'microsoft.insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource pricingplancap 'microsoft.insights/components/pricingPlans@2017-10-01' = {
  name: 'current'
  parent: applicationInsights
  properties: {
    cap: dailyQuota
    planType: 'Basic'
    stopSendNotificationWhenHitCap: true
    warningThreshold: warningThreshold
  }
}

@description('The Resource ID of the upserted pricing plan cap.')
output pricingPlanCapFeaturesId string = pricingplancap.id
@description('The name of the upserted pricing plan cap.')
output pricingPlanCapFeaturesName string = pricingplancap.name
