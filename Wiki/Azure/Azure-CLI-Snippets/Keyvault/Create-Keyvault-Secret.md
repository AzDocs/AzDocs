[[_TOC_]]

# Description
This snippet will create a key inside the keyvault if it doesn't exist yet.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| KeyVaultName | `mykeyvault-$(Release.EnvironmentName)` | This is the keyvault name to use. |
| SecretName | `oneofmysecrets` | This is the secretname to use. |
| SecretDescription | `my cool description of this very secret secret` | OPTIONAL: Add a description to your secret. Can be left blank. |
| SecretExpires | `2018-12-30T07:28:38Z` | OPTIONAL: Add a expiry date for your secret. Can be left blank. |
| SecretNotBefore | `2018-12-30T07:28:38Z` | OPTIONAL: Add a "not before" date for your secret. Secret won't be used before this date. Can be left blank. |
| SecretFilePath | `/path/to/my/very/secret/file.txt` | SEMI-OPTIONAL: Path to the secret file you want to upload. Use this parameter in combination with the fileEncoding parameter. If you use the filePath & fileEncoding option, you MUST leave the "value" parameter blank. |
| SecretFileFileEncoding | `base64` | SEMI-OPTIONAL: The encoding of the file you want to upload. Use this parameter in combination with the filePath parameter. If you use the filePath & fileEncoding option, you MUST leave the "value" parameter blank. |
| SecretValue | `s0m3v3ry53cre7va1u3!!` | SEMI-OPTIONAL: The value of the secret you want to provision to the keyvault. If you use this parameter, you MUST leave the "filePath" & "fileEncoding" parameters blank. |

# Code
[Click here to download this script](../../../../src/Keyvault/Create-Keyvault-Secret.ps1)

# Links

[Azure CLI - az keyvault secret set](https://docs.microsoft.com/en-us/cli/azure/keyvault/secret?view=azure-cli-latest#az_keyvault_secret_set)