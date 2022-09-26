# backupPolicies

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| backupPolicyName | string | <input type="checkbox"> | None | <pre>'DefaultPolicy'</pre> | Backup policy to be used to backup VMs. Backup Policy defines the schedule of the backup and how long to retain backup copies.<br>By default, every vault comes with a \'DefaultPolicy\' which can be used here.') |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| recoveryServicesVaultName | string | <input type="checkbox" checked> | Length between 2-50 | <pre></pre> | The name of the recovery services vault to use. |
| scheduleRunTimes | array | <input type="checkbox"> | None | <pre>['2022-08-05T02:00:00Z']</pre> | Must be an array, however for IaaS VMs only one value is valid. This will be used in LTR too for daily, weekly, monthly and yearly backup.<br>Also see https://docs.microsoft.com/en-us/azure/templates/microsoft.recoveryservices/vaults/backuppolicies?pivots=deployment-language-bicep |
| timeZone | string | <input type="checkbox"> | None | <pre>'UTC'</pre> | Any Valid timezone, for example:UTC, Pacific Standard Time. Refer: https://msdn.microsoft.com/en-us/library/gg154758.aspx |
| instantRpRetentionRangeInDays | int | <input type="checkbox"> | Value between 1-5 | <pre>2</pre> | Number of days Instant Recovery Point should be retained |
| backupRetentionInDays | int | <input type="checkbox"> | None | <pre>14</pre> | Number of days you want to retain the backup |
| protectedItemsCount | int | <input type="checkbox"> | None | <pre>2</pre> | Number of items associated with this policy. If the backupManagementType is 'AzureIAASVM', it is the number of VMs associated with this policy. |
| backupProtectionPolicy | object | <input type="checkbox"> | None | <pre>{<br>  protectedItemsCount: protectedItemsCount<br>  backupManagementType: 'AzureIaasVM'<br>  instantRpRetentionRangeInDays: instantRpRetentionRangeInDays<br>  schedulePolicy: {<br>    scheduleRunFrequency: 'Daily'<br>    scheduleRunTimes: scheduleRunTimes<br>    schedulePolicyType: 'SimpleSchedulePolicy'<br>  }<br>  retentionPolicy: {<br>    dailySchedule: {<br>      retentionTimes: scheduleRunTimes<br>      retentionDuration: {<br>        count: backupRetentionInDays<br>        durationType: 'Days'<br>      }<br>    }<br>    weeklySchedule: {<br>      daysOfTheWeek: [<br>        'Sunday'<br>        'Tuesday'<br>        'Thursday'<br>      ]<br>      retentionTimes: scheduleRunTimes<br>      retentionDuration: {<br>        count: 104<br>        durationType: 'Weeks'<br>      }<br>    }<br>    monthlySchedule: {<br>      retentionScheduleFormatType: 'Daily'<br>      retentionScheduleDaily: {<br>        daysOfTheMonth: [<br>          {<br>            date: 1<br>            isLast: false<br>          }<br>        ]<br>      }<br>      retentionTimes: scheduleRunTimes<br>      retentionDuration: {<br>        count: 60<br>        durationType: 'Months'<br>      }<br>    }<br>    yearlySchedule: {<br>      retentionScheduleFormatType: 'Daily'<br>      monthsOfYear: [<br>        'January'<br>        'March'<br>        'August'<br>      ]<br>      retentionScheduleDaily: {<br>        daysOfTheMonth: [<br>          {<br>            date: 1<br>            isLast: false<br>          }<br>        ]<br>      }<br>      retentionTimes: scheduleRunTimes<br>      retentionDuration: {<br>        count: 10<br>        durationType: 'Years'<br>      }<br>    }<br>    retentionPolicyType: 'LongTermRetentionPolicy'<br>  }<br>  timeZone: timeZone<br>}</pre> | Numerous options you can choose in the properites of the backupPolicies, depending on the backupManagementType.<br>See https://docs.microsoft.com/en-us/azure/templates/microsoft.recoveryservices/vaults/backuppolicies?pivots=deployment-language-bicep |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| policyId | string | the resource id for the backup policy. |

