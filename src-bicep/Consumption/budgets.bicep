@description('Name of the Budget. It should be unique within a resource group.')
@minLength(1)
@maxLength(63)
param budgetName string

@description('The total amount of cost or usage to track with the budget')
param amount int

@description('The time covered by a budget. Tracking of the amount will be reset based on the time grain.')
@allowed([
  'Annually'
  'BillingAnnual'
  'BillingMonth'
  'BillingQuarter'
  'Monthly'
  'Quarterly'
])
param timeGrain string = 'Monthly'

@description('The start date must be first of the month in YYYY-MM-DD format. Future start date should not be more than three months. Past start date should be selected within the timegrain period. Defaults to the first of the current month.')
param startDate string = '${utcNow('yyyy-MM')}-01'

@description('The end date for the budget in YYYY-MM-DD format. If not provided, we can default this to 5 years from the start date.')
param endDate string = dateTimeAdd(startDate, 'P5Y')

@description('Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0.01 and 1000.')
@minValue(0)
@maxValue(1000)
param firstThreshold int = 90

@description('Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0.01 and 1000.')
@minValue(0)
@maxValue(1000)
param secondThreshold int = 110

@description('The list of email addresses to send the budget notification to when the threshold is exceeded (eg [ "email@email.nl","anotheremail@email.nl" ]).')
param contactEmails array

@description('Upsert the budget based on the given parameters. For example, please refer to https://docs.microsoft.com/en-us/azure/cost-management-billing/costs/quick-create-budget-bicep?tabs=CLI')
resource budget 'Microsoft.Consumption/budgets@2021-10-01' = {
  name: budgetName
  properties: {
    timePeriod: {
      startDate: startDate
      endDate: endDate
    }
    timeGrain: timeGrain
    amount: amount
    category: 'Cost'
    notifications: {
      NotificationForExceededBudget1: {
        enabled: true
        operator: 'GreaterThan'
        threshold: firstThreshold
        contactEmails: contactEmails
      }
      NotificationForExceededBudget2: {
        enabled: true
        operator: 'GreaterThan'
        threshold: secondThreshold
        contactEmails: contactEmails
      }
    }
  }
}
