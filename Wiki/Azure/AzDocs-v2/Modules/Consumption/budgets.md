# budgets

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| budgetName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | Name of the Budget. It should be unique within a resource group. |
| amount | int | <input type="checkbox" checked> | None | <pre></pre> | The total amount of cost or usage to track with the budget |
| timeGrain | string | <input type="checkbox"> | `'Annually'` or `'BillingAnnual'` or `'BillingMonth'` or `'BillingQuarter'` or `'Monthly'` or `'Quarterly'` | <pre>'Monthly'</pre> | The time covered by a budget. Tracking of the amount will be reset based on the time grain. |
| startDate | string | <input type="checkbox"> | None | <pre>'&#36;{utcNow('yyyy-MM')}-01'</pre> | The start date must be first of the month in YYYY-MM-DD format. Future start date should not be more than three months. Past start date should be selected within the timegrain period. Defaults to the first of the current month. |
| endDate | string | <input type="checkbox"> | None | <pre>dateTimeAdd(startDate, 'P5Y')</pre> | The end date for the budget in YYYY-MM-DD format. If not provided, we can default this to 5 years from the start date. |
| firstThreshold | int | <input type="checkbox"> | Value between 0-1000 | <pre>90</pre> | Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0.01 and 1000. |
| secondThreshold | int | <input type="checkbox"> | Value between 0-1000 | <pre>110</pre> | Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0.01 and 1000. |
| contactEmails | array | <input type="checkbox" checked> | None | <pre></pre> | The list of email addresses to send the budget notification to when the threshold is exceeded (eg [ "email@email.nl","anotheremail@email.nl" ]). |
