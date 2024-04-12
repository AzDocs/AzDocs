# currentBillingFeatures

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| priceCode | int | <input type="checkbox" checked> | `1` or `2` | <pre></pre> | Pricing plan: 1 = Per GB (or legacy Basic plan), 2 = Per Node (legacy Enterprise plan) |
| dailyQuota | int | <input type="checkbox" checked> | Value between 1-* | <pre></pre> | Enter daily quota in GB. |
| dailyQuotaResetTime | int | <input type="checkbox" checked> | Value between 0-23 | <pre></pre> | Enter daily quota reset hour in UTC (0 to 23). Values outside the range will get a random reset hour. |
| warningThreshold | int | <input type="checkbox" checked> | Value between 1-100 | <pre></pre> | Enter the % value of daily quota after which warning mail to be sent. |
| applicationInsightsName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Parent Application Insights resource |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| currentBillingFeaturesId | string | The Resource ID of the upserted billing feature. |
| currentBillingFeaturesName | string | The name of the upserted billing feature. |
