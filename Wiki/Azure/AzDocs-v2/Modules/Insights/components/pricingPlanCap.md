# pricingPlanCap

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| dailyQuota | int | <input type="checkbox" checked> | Value between 1-* | <pre></pre> | Enter daily quota in GB. |
| warningThreshold | int | <input type="checkbox" checked> | Value between 1-100 | <pre></pre> | Enter the % value of daily quota after which warning mail to be sent. |
| applicationInsightsName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Parent Application Insights resource |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| pricingPlanCapFeaturesId | string | The Resource ID of the upserted pricing plan cap. |
| pricingPlanCapFeaturesName | string | The name of the upserted pricing plan cap. |
