@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
Backup policy to be used to backup VMs. Backup Policy defines the schedule of the backup and how long to retain backup copies.
By default, every vault comes with a \'DefaultPolicy\' which can be used here.')
''')
param backupPolicyName string = 'DefaultPolicy'

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('''
The name of the recovery services vault to use.
''')
@minLength(2)
@maxLength(50)
param recoveryServicesVaultName string

@description('''Times in day when backup should be triggered. e.g. 01:00 or 13:00. List of times of day this schedule has to be run.
Must be an array, however for IaaS VMs only one value is valid. This will be used in LTR too for daily, weekly, monthly and yearly backup.
Also see https://docs.microsoft.com/en-us/azure/templates/microsoft.recoveryservices/vaults/backuppolicies?pivots=deployment-language-bicep
''')
param scheduleRunTimes array = ['2022-08-05T02:00:00Z']

@description('Any Valid timezone, for example:UTC, Pacific Standard Time. Refer: https://msdn.microsoft.com/en-us/library/gg154758.aspx')
param timeZone string = 'UTC'

@description('Number of days Instant Recovery Point should be retained')
@minValue(1)
@maxValue(5)
param instantRpRetentionRangeInDays int = 2

@description('Number of days you want to retain the backup')
param backupRetentionInDays int = 14

@description('''
Number of items associated with this policy. If the backupManagementType is 'AzureIAASVM', it is the number of VMs associated with this policy.
''')
param protectedItemsCount int = 2

@description('''
Numerous options you can choose in the properites of the backupPolicies, depending on the backupManagementType.
See https://docs.microsoft.com/en-us/azure/templates/microsoft.recoveryservices/vaults/backuppolicies?pivots=deployment-language-bicep
''')
param backupProtectionPolicy object = {
  protectedItemsCount: protectedItemsCount
  backupManagementType: 'AzureIaasVM'
  instantRpRetentionRangeInDays: instantRpRetentionRangeInDays
  schedulePolicy: {
    scheduleRunFrequency: 'Daily'
    scheduleRunTimes: scheduleRunTimes
    schedulePolicyType: 'SimpleSchedulePolicy'
  }
  retentionPolicy: {
    dailySchedule: {
      retentionTimes: scheduleRunTimes
      retentionDuration: {
        count: backupRetentionInDays
        durationType: 'Days'
      }
    }
    weeklySchedule: {
      daysOfTheWeek: [
        'Sunday'
        'Tuesday'
        'Thursday'
      ]
      retentionTimes: scheduleRunTimes
      retentionDuration: {
        count: 104
        durationType: 'Weeks'
      }
    }
    monthlySchedule: {
      retentionScheduleFormatType: 'Daily'
      retentionScheduleDaily: {
        daysOfTheMonth: [
          {
            date: 1
            isLast: false
          }
        ]
      }
      retentionTimes: scheduleRunTimes
      retentionDuration: {
        count: 60
        durationType: 'Months'
      }
    }
    yearlySchedule: {
      retentionScheduleFormatType: 'Daily'
      monthsOfYear: [
        'January'
        'March'
        'August'
      ]
      retentionScheduleDaily: {
        daysOfTheMonth: [
          {
            date: 1
            isLast: false
          }
        ]
      }
      retentionTimes: scheduleRunTimes
      retentionDuration: {
        count: 10
        durationType: 'Years'
      }
    }
    retentionPolicyType: 'LongTermRetentionPolicy'
  }
  timeZone: timeZone
}

@description('Fetch the recovery services vault you want to have your backup policies configured in.')
resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2022-04-01' existing = {
  name: recoveryServicesVaultName
}

@description('''The backup policies you want to configure in the Recovery Services vault.
These also contain the backup policies that are associated with any protected virtual machines.
''')
resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-06-01-preview' = {
  name: backupPolicyName
  location: location
  tags: tags
  parent: recoveryServicesVault
  properties: backupProtectionPolicy
}

@description('the resource id for the backup policy.')
output policyId string = backupPolicy.id
