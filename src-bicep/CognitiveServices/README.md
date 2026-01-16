# Azure OpenAI Bicep Modules

This folder contains Bicep modules for deploying Azure OpenAI and related Cognitive Services resources.

## Structure

```
CognitiveServices/
├── accounts.bicep                           # Main Cognitive Services account (including OpenAI)
└── accounts/
    ├── deployments.bicep                    # Model deployments
    ├── raiPolicies.bicep                   # Responsible AI policies
    └── defenderForAISettings.bicep         # Microsoft Defender for AI settings
```

## Features

- **Cognitive Services Account**: Creates Azure OpenAI or other Cognitive Services accounts
- **Model Deployments**: Deploy AI models (GPT-4o, GPT-3.5-turbo, embeddings, etc.)
- **RAI Policies**: Configure content filtering and responsible AI policies
- **Defender for AI**: Enable/disable Microsoft Defender for AI
- **Diagnostics**: Optional integration with Log Analytics for monitoring
- **Network Security**: Configure network access controls and private endpoints

## Usage Examples

### Basic Azure OpenAI Account

```bicep
module openAi 'br:contosoregistry.azurecr.io/cognitiveservices/accounts:latest' = {
  name: 'deploy-openai'
  params: {
    accountName: 'my-openai-account'
    location: 'westeurope'
    kind: 'OpenAI'
    skuName: 'S0'
    publicNetworkAccess: 'Enabled'
  }
}
```

### Deploy GPT-4 Model

```bicep
module gpt4 'br:contosoregistry.azurecr.io/cognitiveservices/accounts/deployments:latest' = {
  name: 'deploy-gpt4'
  params: {
    accountName: 'my-openai-account'
    deploymentName: 'gpt-4'
    modelName: 'gpt-4'
    modelVersion: '0613'
    skuCapacity: 100
  }
}
```

### Custom Content Filter Policy

```bicep
module raiPolicy 'br:contosoregistry.azurecr.io/cognitiveservices/accounts/raipolicies:latest' = {
  name: 'deploy-rai-policy'
  params: {
    accountName: 'my-openai-account'
    policyName: 'StrictContentFilter'
    mode: 'Default'
    basePolicyName: 'Microsoft.DefaultV2'
    contentFilters: [
      {
        name: 'Violence'
        severityThreshold: 'Low'
        blocking: true
        enabled: true
        source: 'Prompt'
      }
    ]
  }
}
```

## Complete Example

See `templates/Examples/OpenAI/example-openai.bicep` for a complete example that includes:

- Azure OpenAI account creation
- Multiple model deployments (GPT-4o, o3-mini, text-embedding-3-large)
- Custom RAI policies
- Defender for AI configuration
- Proper dependency management

## Parameters

### Main Account Parameters

| Parameter             | Type   | Required | Description                                         |
| --------------------- | ------ | -------- | --------------------------------------------------- |
| `accountName`         | string | Yes      | Name of the Cognitive Services account (2-64 chars) |
| `location`            | string | No       | Azure region (defaults to resource group location)  |
| `kind`                | string | Yes      | Type of service (OpenAI, TextAnalytics, etc.)       |
| `skuName`             | string | No       | Pricing tier (F0, S0, S1, etc.)                     |
| `publicNetworkAccess` | string | No       | Enable/disable public access                        |
| `customSubDomainName` | string | No       | Custom subdomain (defaults to account name)         |

### Model Deployment Parameters

| Parameter        | Type   | Required | Description                                  |
| ---------------- | ------ | -------- | -------------------------------------------- |
| `accountName`    | string | Yes      | Parent Cognitive Services account name       |
| `deploymentName` | string | Yes      | Name for the model deployment                |
| `modelName`      | string | Yes      | Model to deploy (gpt-4o, gpt-35-turbo, etc.) |
| `modelVersion`   | string | Yes      | Specific model version                       |
| `skuCapacity`    | int    | No       | Token rate limit capacity                    |
| `raiPolicyName`  | string | No       | RAI policy to apply                          |

## Security Considerations

1. **Network Access**: Use `publicNetworkAccess: 'Disabled'` for production environments
2. **Content Filtering**: Always configure appropriate RAI policies
3. **Monitoring**: Enable diagnostics and Log Analytics integration
4. **Access Control**: Use Azure RBAC for fine-grained access control
5. **Private Endpoints**: Consider using private endpoints for sensitive workloads

## Supported Models

The deployment module supports all Azure OpenAI models including:

- **GPT Models**: gpt-4o, gpt-4, gpt-35-turbo
- **Embedding Models**: text-embedding-ada-002, text-embedding-3-large
- **Image Models**: dall-e-3
- **Code Models**: Various code generation models

## Best Practices

1. **Naming**: Use consistent naming conventions across resources
2. **Tagging**: Apply appropriate tags for cost management and governance
3. **Monitoring**: Enable diagnostics for all production deployments
4. **Capacity Planning**: Right-size SKU capacity based on expected usage
5. **Regional Availability**: Check model availability in your target region
6. **Cost Management**: Monitor usage and implement appropriate quotas

## Troubleshooting

### Common Issues

1. **Model not available**: Check if the model is available in your region
2. **Quota exceeded**: Verify your subscription quotas and limits
3. **Permission denied**: Ensure proper Azure RBAC permissions
4. **Network connectivity**: Check firewall rules and network ACLs

### Required Permissions

- `Cognitive Services Contributor` role for deployment
- `Reader` role for diagnostics workspace (if configured)
- Appropriate network permissions for private endpoints

## Links

- [Azure OpenAI Documentation](https://learn.microsoft.com/en-us/azure/ai-services/openai/)
- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Responsible AI Policies](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/content-filter)
