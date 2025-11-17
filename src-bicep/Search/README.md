# Azure Search Service Bicep Modules

This folder contains Bicep modules for deploying Azure Search Service (Cognitive Search) resources.

## Structure

```
Search/
└── searchServices.bicep                     # Main Azure Search Service
```

## Features

- **Search Service**: Creates Azure Cognitive Search service with configurable capacity
- **Semantic Search**: Configure semantic search capabilities (free/standard)
- **Network Security**: Configure network access controls and IP rules
- **Authentication**: Support for API key authentication
- **Diagnostics**: Optional integration with Log Analytics for monitoring
- **Encryption**: Customer-managed key encryption support

## Usage Examples

### Basic Search Service

```bicep
module searchService 'br:contosoregistry.azurecr.io/search/searchservices:latest' = {
  name: 'deploy-search'
  params: {
    searchServiceName: 'mysearch-dev'
    location: 'westeurope'
    skuName: 'basic'
    semanticSearch: 'free'
  }
}
```

### Production Search Service with Advanced Features

```bicep
module searchService 'br:contosoregistry.azurecr.io/search/searchservices:latest' = {
  name: 'deploy-search-prod'
  params: {
    searchServiceName: 'mysearch-prod'
    location: 'westeurope'
    skuName: 'standard'
    replicaCount: 2
    partitionCount: 2
    semanticSearch: 'standard'
    publicNetworkAccess: 'disabled'
    logAnalyticsWorkspaceResourceId: '/subscriptions/.../workspaces/logs'
    tags: {
      Environment: 'production'
      Service: 'search'
    }
  }
}
```

### Search Service with Network Restrictions

```bicep
module searchService 'br:contosoregistry.azurecr.io/search/searchservices:latest' = {
  name: 'deploy-search-secure'
  params: {
    searchServiceName: 'mysearch-secure'
    skuName: 'standard'
    publicNetworkAccess: 'enabled'
    ipRules: [
      {
        value: '203.0.113.0/24'
      }
      {
        value: '198.51.100.1'
      }
    ]
    networkRuleSetBypass: 'AzureServices'
  }
}
```

## Parameters

### Main Search Service Parameters

| Parameter             | Type   | Required | Default                 | Description                                   |
| --------------------- | ------ | -------- | ----------------------- | --------------------------------------------- |
| `searchServiceName`   | string | Yes      | -                       | Name of the search service (2-60 chars)       |
| `location`            | string | No       | Resource group location | Azure region                                  |
| `skuName`             | string | No       | `basic`                 | Pricing tier (free, basic, standard, etc.)    |
| `replicaCount`        | int    | No       | `1`                     | Number of replicas (1-12)                     |
| `partitionCount`      | int    | No       | `1`                     | Number of partitions (1, 2, 3, 4, 6, 12)      |
| `publicNetworkAccess` | string | No       | `disabled`              | Enable/disable/securedByPerimeter             |
| `semanticSearch`      | string | No       | `free`                  | Semantic search tier (disabled/free/standard) |
| `disableLocalAuth`       | bool   | No       | `true`                  | Disable API key authentication                |
| `authenticationOptions`  | object | No       | -                       | Authentication options (aadOrApiKey/apiKeyOnly) |
| `hostingMode`            | string | No       | `default`               | Hosting mode (default/highDensity)            |
| `identity`               | object | No       | `{type: 'SystemAssigned'}` | Managed identity configuration             |

### Network Security Parameters

| Parameter              | Type   | Required | Default | Description                          |
| ---------------------- | ------ | -------- | ------- | ------------------------------------ |
| `ipRules`              | array  | No       | `[]`    | Array of IP rules for access control |
| `networkRuleSetBypass` | string | No       | `None`  | Bypass options (None/AzureServices)  |

### Encryption Parameters

| Parameter                        | Type   | Required | Default       | Description                         |
| -------------------------------- | ------ | -------- | ------------- | ----------------------------------- |
| `encryptionWithCmkEnforcement`   | string | No       | `Unspecified` | Customer-managed key enforcement    |
| `dataExfiltrationProtections`    | array  | No       | `[]`          | Data exfiltration protection config |

## SKU Tiers and Limits

| SKU                  | Max Replicas | Max Partitions | Max Search Units | Storage per Partition |
| -------------------- | ------------ | -------------- | ---------------- | --------------------- |
| Free                 | 0            | 0              | 0                | 50 MB                 |
| Basic                | 3            | 1              | 3                | 2 GB                  |
| Standard (S1)        | 12           | 12             | 36               | 25 GB                 |
| Standard (S2)        | 12           | 12             | 36               | 100 GB                |
| Standard (S3)        | 12           | 12             | 36               | 200 GB                |
| Storage Optimized L1 | 12           | 12             | 36               | 1 TB                  |
| Storage Optimized L2 | 12           | 12             | 36               | 2 TB                  |

## Semantic Search

Azure Cognitive Search offers semantic search capabilities:

- **Disabled**: No semantic search
- **Free**: 1,000 queries per month
- **Standard**: Pay-per-use pricing

## Security Considerations

1. **Network Access**: Use `publicNetworkAccess: 'Disabled'` with private endpoints for production
2. **Authentication**: Consider disabling API keys (`disableLocalAuth: true`) and use Azure AD
3. **IP Restrictions**: Configure IP rules to limit access to known networks
4. **Encryption**: Enable customer-managed keys for sensitive data
5. **Monitoring**: Enable diagnostics for security and performance monitoring

## Best Practices

1. **Capacity Planning**:

   - Start with basic SKU for development
   - Use standard SKUs for production workloads
   - Plan replicas for availability, partitions for scale

2. **Performance Optimization**:

   - Use appropriate number of replicas for query load
   - Use appropriate number of partitions for index size
   - Monitor search latency and throughput

3. **Cost Optimization**:

   - Use free tier for development/testing
   - Right-size production deployments
   - Monitor usage patterns

4. **High Availability**:
   - Use multiple replicas for SLA requirements
   - Deploy across availability zones when possible

## Outputs

| Output                     | Type   | Description                                  |
| -------------------------- | ------ | -------------------------------------------- |
| `searchServiceName`        | string | Name of the created search service           |
| `searchServiceResourceId`  | string | Resource ID of the search service            |
| `searchServiceEndpoint`    | string | HTTPS endpoint URL                           |
| `searchServicePrincipalId` | string | Principal ID of system-assigned identity     |

**Note**: Admin and query keys are not exposed as outputs for security reasons. Use Azure CLI, PowerShell, or REST API to retrieve keys when needed.

## Integration with Other Services

### Azure Cognitive Services Integration

```bicep
// Deploy both Search and OpenAI for RAG scenarios
module searchService 'br:contosoregistry.azurecr.io/search/searchservices:latest' = {
  name: 'search-for-rag'
  params: {
    searchServiceName: 'rag-search'
    skuName: 'standard'
    semanticSearch: 'standard'
  }
}

module openAI 'br:contosoregistry.azurecr.io/cognitiveservices/accounts:latest' = {
  name: 'openai-for-rag'
  params: {
    accountName: 'rag-openai'
    kind: 'OpenAI'
  }
}
```

### Storage Account Integration

```bicep
// Search service with data source from storage
module searchService 'br:contosoregistry.azurecr.io/search/searchservices:latest' = {
  name: 'search-with-storage'
  params: {
    searchServiceName: 'document-search'
    skuName: 'standard'
  }
}

module storageAccount 'br:contosoregistry.azurecr.io/storage/storageaccounts:latest' = {
  name: 'document-storage'
  params: {
    storageAccountName: 'docstorage'
    storageAccountKind: 'StorageV2'
  }
}
```

## Troubleshooting

### Common Issues

1. **Service Name Already Exists**

   ```
   Error: Search service name is not available
   ```

   **Solution**: Choose a globally unique name

2. **Insufficient Quota**

   ```
   Error: Quota exceeded for search services
   ```

   **Solution**: Request quota increase or use different region

3. **Invalid SKU Configuration**

   ```
   Error: Invalid replica/partition count for SKU
   ```

   **Solution**: Check SKU limits and adjust capacity

4. **Network Access Issues**
   ```
   Error: Unable to connect to search service
   ```
   **Solution**: Check firewall rules and network configuration

### Required Permissions

- `Search Service Contributor` role for deployment
- `Reader` role for diagnostics workspace (if configured)
- Appropriate network permissions for private endpoints

## Links

- [Azure Cognitive Search Documentation](https://learn.microsoft.com/en-us/azure/search/)
- [Search Service REST API](https://docs.microsoft.com/en-us/rest/api/searchservice/)
- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Semantic Search](https://learn.microsoft.com/en-us/azure/search/semantic-search-overview)
