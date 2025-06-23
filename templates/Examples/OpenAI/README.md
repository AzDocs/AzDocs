# Azure OpenAI Example

This example demonstrates how to deploy a complete Azure OpenAI setup using the CognitiveServices Bicep modules.

## What's Included

This example creates:

- **Azure OpenAI Account** with custom subdomain
- **Model Deployments**:
  - GPT-4o (latest version)
  - o3-mini (with custom content filtering)
  - text-embedding-3-large (for embeddings)
- **Custom RAI Policy** with strict content filtering
- **Defender for AI** configuration (disabled by default)
- **Diagnostics** integration with Log Analytics (optional)

## Files

- `example-openai.bicep` - Main Bicep template
- `parameters.json` - Parameter file with example values
- `deploy.sh` - Bash deployment script
- `deploy.ps1` - PowerShell deployment script
- `README.md` - This file

## Prerequisites

1. **Azure CLI** or **Azure PowerShell** installed
2. **Logged in to Azure** with appropriate permissions
3. **Subscription with OpenAI access** (requires special approval)
4. **Resource group** (will be created if doesn't exist)

## Quick Start

### Option 1: Using Azure CLI (Bash)

```bash
# Make the script executable
chmod +x deploy.sh

# Run the deployment
./deploy.sh
```

### Option 2: Using Azure PowerShell

```powershell
# Run the deployment
.\deploy.ps1
```

### Option 3: Manual Deployment

```bash
# Create resource group
az group create --name rg-openai-demo --location westeurope

# Deploy template
az deployment group create \
  --resource-group rg-openai-demo \
  --template-file example-openai.bicep \
  --parameters @parameters.json
```

## Configuration

### Update Parameters

Edit `parameters.json` to customize your deployment:

```json
{
  "parameters": {
    "namePrefix": {
      "value": "mycompany-openai" // Change this to your company/project name
    },
    "environmentName": {
      "value": "dev" // dev, test, prod
    },
    "location": {
      "value": "westeurope" // Azure region
    },
    "logAnalyticsWorkspaceResourceId": {
      "value": "/subscriptions/.../providers/Microsoft.OperationalInsights/workspaces/..."
    }
  }
}
```

### Key Parameters

| Parameter                         | Description                            | Default          |
| --------------------------------- | -------------------------------------- | ---------------- |
| `namePrefix`                      | Prefix for all resource names          | `openai`         |
| `environmentName`                 | Environment (dev/test/prod)            | `dev`            |
| `location`                        | Azure region                           | `westeurope`     |
| `tags`                            | Resource tags for governance           | Environment tags |
| `logAnalyticsWorkspaceResourceId` | Log Analytics workspace for monitoring | Empty (disabled) |

## Deployed Models

The example deploys three models:

1. **GPT-4o** (`gpt-4o`)

   - Version: 2024-11-20
   - Capacity: 250 tokens per minute
   - Use case: Advanced conversational AI

2. **o3-mini** (`o3-mini`)

   - Version: 2025-01-31
   - Capacity: 250 tokens per minute
   - Custom content filtering applied
   - Use case: Lightweight reasoning tasks

3. **Text Embedding 3 Large** (`text-embedding-3-large`)
   - Version: 1
   - Capacity: 250 tokens per minute
   - No auto-upgrade
   - Use case: Vector embeddings for search/RAG

## Content Filtering

The example includes a custom RAI policy with strict filtering:

- **Violence**: Low threshold, blocking enabled
- **Hate Speech**: Low threshold, blocking enabled
- **Sexual Content**: Low threshold, blocking enabled
- **Self-harm**: Low threshold, blocking enabled

Applied to both prompts and completions.

## Security Features

- **Network Access**: Public access enabled (change for production)
- **Content Filtering**: Custom strict policies applied
- **Monitoring**: Optional Log Analytics integration
- **Defender for AI**: Available but disabled by default

## Cost Considerations

This deployment creates:

- 1x Azure OpenAI account (S0 tier)
- 3x model deployments with 250 TPM each
- Optional Log Analytics charges
- Optional Defender for AI charges (if enabled)

Estimated monthly cost: $50-200 depending on usage.

## Production Recommendations

For production deployments, consider:

1. **Network Security**:

   ```bicep
   publicNetworkAccess: 'Disabled'
   // Add private endpoint configuration
   ```

2. **Monitoring**:

   ```bicep
   logAnalyticsWorkspaceResourceId: '/subscriptions/.../workspaces/prod-logs'
   ```

3. **Access Control**:

   - Use Azure RBAC
   - Implement managed identities
   - Configure API key rotation

4. **Regional Deployment**:
   - Choose regions with model availability
   - Consider data residency requirements

## Troubleshooting

### Common Issues

1. **OpenAI Access Not Approved**

   ```
   Error: This subscription does not have access to Azure OpenAI
   ```

   **Solution**: Apply for Azure OpenAI access through the Azure portal

2. **Model Not Available in Region**

   ```
   Error: Model gpt-4o is not available in westeurope
   ```

   **Solution**: Check model availability and change region or model

3. **Quota Exceeded**

   ```
   Error: Quota exceeded for model deployments
   ```

   **Solution**: Request quota increase or reduce deployment capacity

4. **Resource Name Conflicts**
   ```
   Error: Account name already exists
   ```
   **Solution**: Change the namePrefix parameter to ensure uniqueness

### Getting Help

- Check the [Azure OpenAI documentation](https://learn.microsoft.com/en-us/azure/ai-services/openai/)
- Review Azure portal diagnostics
- Check deployment logs in the resource group

## Next Steps

After deployment:

1. **Test the Endpoints**: Use Azure OpenAI Studio or REST API
2. **Configure Applications**: Update your apps with the new endpoints
3. **Monitor Usage**: Set up alerts and dashboards
4. **Scale as Needed**: Adjust model capacities based on usage

## Cleanup

To remove all resources:

```bash
az group delete --name rg-openai-demo --yes --no-wait
```

---

**Note**: This example is for demonstration purposes. Always follow your organization's security and compliance requirements when deploying to production.
