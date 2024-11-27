@description('''
The name of the Automation Account (should be existing).
Min length: 6
Max length: 50
''')
@minLength(6)
@maxLength(50)
param automationAccountName string

@description('''
The name for the variable (child resource) in the automation account.
''')
@minLength(1)
@maxLength(128)
param variableName string

@description('''
If the variable value needs to be encrypted.
''')
param encryptValue bool = false

@description('''
The description for the variable.
''')
param variableDescription string = ''

@description('''
The value for the variable you want to create in json format.
Example:
'"testvalue1"'
''')
param variableValue string

resource automationAccount 'Microsoft.Automation/automationAccounts@2021-06-22' existing = {
  name: automationAccountName
  resource keyVaultPolicies 'variables@2020-01-13-preview' = {
    name: variableName
    properties: {
      description: variableDescription
      isEncrypted: encryptValue
      value: variableValue
    }
  }
}
