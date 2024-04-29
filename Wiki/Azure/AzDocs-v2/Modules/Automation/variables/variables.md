# variables

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| automationAccountName | string | <input type="checkbox" checked> | Length between 6-50 | <pre></pre> | The name of the Automation Account (should be existing).<br>Min length: 6<br>Max length: 50 |
| variableName | string | <input type="checkbox" checked> | Length between 1-128 | <pre></pre> | The name for the variable (child resource) in the automation account. |
| encryptValue | bool | <input type="checkbox"> | None | <pre>false</pre> | If the variable value needs to be encrypted. |
| variableDescription | string | <input type="checkbox"> | None | <pre>''</pre> | The description for the variable. |
| variableValue | string | <input type="checkbox" checked> | None | <pre></pre> | The value for the variable you want to create in json format.<br>Example:<br>'"testvalue1"' |
