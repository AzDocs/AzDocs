@description('Pricing plan: 1 = Per GB (or legacy Basic plan), 2 = Per Node (legacy Enterprise plan)')
@allowed([
  1
  2
])
param priceCode int

@description('Enter daily quota in GB.')
@minValue(1)
param dailyQuota int

@description('Enter daily quota reset hour in UTC (0 to 23). Values outside the range will get a random reset hour.')
@minValue(0)
@maxValue(23)
param dailyQuotaResetTime int

@description('Enter the % value of daily quota after which warning mail to be sent.')
@minValue(1)
@maxValue(100)
param warningThreshold int

@description('Parent Application Insights resource')
@minLength(1)
param applicationInsightsName string

var priceArray = [
  'Basic'
  'Application Insights Enterprise'
]

var pricePlan = take(priceArray, priceCode)
var billingPlanName = '${applicationInsightsName}-${pricePlan[0]}'

resource applicationInsights 'microsoft.insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

#disable-next-line BCP081 // We need this type but it seems unknown
resource billingPlan 'microsoft.insights/components/CurrentBillingFeatures@2015-05-01' = {
  name: billingPlanName
  parent: applicationInsights
  properties: {
    CurrentBillingFeatures: pricePlan
    DataVolumeCap: {
      Cap: dailyQuota
      ResetTime: dailyQuotaResetTime
      warningThreshold: warningThreshold
    }
  }
}

@description('The Resource ID of the upserted billing feature.')
output currentBillingFeaturesId string = billingPlan.id
@description('The name of the upserted billing feature.')
output currentBillingFeaturesName string = billingPlan.name
