# Azure Search + OpenAI RAG Example

This example demonstrates how to deploy a complete RAG (Retrieval-Augmented Generation) setup using Azure Search Service and Azure OpenAI.

## What's Included

This example creates:

- **Azure Search Service** with semantic search capabilities
- **Azure OpenAI Account** with embedding and generation models
- **Model Deployments**:
  - text-embedding-3-large (for document vectorization)
  - GPT-4o (for text generation)
- **Storage Account** for document storage
- **Diagnostics** integration with Log Analytics (optional)

## Architecture

```
[Documents] → [Storage Account] → [Azure Search] ← [Your App]
                                       ↕
                                 [OpenAI Embeddings]
                                       ↓
                              [OpenAI GPT-4o] → [Generated Response]
```

## Files

- `example-search-openai.bicep` - Main Bicep template
- `parameters.json` - Parameter file with example values
- `README.md` - This file

## Prerequisites

1. **Azure CLI** or **Azure PowerShell** installed
2. **Logged in to Azure** with appropriate permissions
3. **Subscription with OpenAI access** (requires special approval)
4. **Resource group** (will be created if doesn't exist)

## Quick Start

### Deploy Using Azure CLI

```bash
# Create resource group
az group create --name rg-rag-demo --location westeurope

# Deploy template
az deployment group create \
  --resource-group rg-rag-demo \
  --template-file example-search-openai.bicep \
  --parameters @parameters.json
```

### Deploy Using Azure PowerShell

```powershell
# Create resource group
New-AzResourceGroup -Name "rg-rag-demo" -Location "westeurope"

# Deploy template
New-AzResourceGroupDeployment `
  -ResourceGroupName "rg-rag-demo" `
  -TemplateFile "example-search-openai.bicep" `
  -TemplateParameterFile "parameters.json"
```

## Configuration

### Update Parameters

Edit `parameters.json` to customize your deployment:

```json
{
  "parameters": {
    "namePrefix": {
      "value": "mycompany-rag" // Change this to your company/project name
    },
    "environmentName": {
      "value": "dev" // dev, test, prod
    },
    "searchServiceSku": {
      "value": "basic" // basic, standard, standard2, standard3
    },
    "semanticSearch": {
      "value": "free" // disabled, free, standard
    }
  }
}
```

### Key Parameters

| Parameter          | Description                   | Default | Options                  |
| ------------------ | ----------------------------- | ------- | ------------------------ |
| `namePrefix`       | Prefix for all resource names | `rag`   | 2-20 characters          |
| `environmentName`  | Environment (dev/test/prod)   | `dev`   | Any string               |
| `searchServiceSku` | Search service pricing tier   | `basic` | basic, standard, etc.    |
| `semanticSearch`   | Semantic search capabilities  | `free`  | disabled, free, standard |

## Deployed Resources

### Azure Search Service

- **Name**: `{namePrefix}-search-{environmentName}`
- **SKU**: Configurable (basic/standard)
- **Features**: Semantic search, network security
- **Use case**: Document indexing and vector search

### Azure OpenAI Account

- **Name**: `{namePrefix}-openai-{environmentName}`
- **Models**:
  - text-embedding-3-large (embeddings)
  - GPT-4o (text generation)
- **Use case**: Text vectorization and response generation

### Storage Account

- **Name**: `{namePrefix}docs{environmentName}` (normalized)
- **Type**: Standard LRS
- **Use case**: Document storage and processing

## RAG Implementation Guide

### 1. Document Ingestion

```bash
# Upload documents to storage account
az storage blob upload-batch \
  --destination documents \
  --source ./my-documents \
  --account-name {storage-account-name}
```

### 2. Create Search Index

```json
{
  "name": "documents-index",
  "fields": [
    { "name": "id", "type": "Edm.String", "key": true },
    { "name": "content", "type": "Edm.String", "searchable": true },
    {
      "name": "contentVector",
      "type": "Collection(Edm.Single)",
      "searchable": true,
      "vectorSearchDimensions": 3072
    },
    {
      "name": "title",
      "type": "Edm.String",
      "searchable": true,
      "filterable": true
    },
    { "name": "category", "type": "Edm.String", "filterable": true }
  ],
  "vectorSearch": {
    "algorithms": [
      {
        "name": "vector-config",
        "kind": "hnsw"
      }
    ],
    "profiles": [
      {
        "name": "vector-profile",
        "algorithm": "vector-config"
      }
    ]
  }
}
```

### 3. Index Documents with Embeddings

```python
import openai
from azure.search.documents import SearchClient

# Configure OpenAI
openai.api_base = "{openai-endpoint}"
openai.api_key = "{openai-key}"

# Generate embeddings
def get_embedding(text):
    response = openai.Embedding.create(
        engine="text-embedding-3-large",
        input=text
    )
    return response.data[0].embedding

# Index document
documents = [
    {
        "id": "doc1",
        "content": "Your document content here",
        "contentVector": get_embedding("Your document content here"),
        "title": "Document Title",
        "category": "Technical"
    }
]

search_client.upload_documents(documents)
```

### 4. Perform RAG Query

```python
def rag_query(user_question):
    # 1. Get question embedding
    question_vector = get_embedding(user_question)

    # 2. Search for relevant documents
    search_results = search_client.search(
        search_text=user_question,
        vector_queries=[{
            "vector": question_vector,
            "k_nearest_neighbors": 3,
            "fields": "contentVector"
        }],
        select=["content", "title"],
        top=3
    )

    # 3. Build context from search results
    context = "\n".join([doc["content"] for doc in search_results])

    # 4. Generate response using GPT-4o
    prompt = f"""
    Context: {context}

    Question: {user_question}

    Please provide a comprehensive answer based on the context provided.
    """

    response = openai.ChatCompletion.create(
        engine="gpt-4o",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=500
    )

    return response.choices[0].message.content
```

## Cost Considerations

This deployment creates:

- 1x Azure Search Service (basic: ~$250/month, standard: ~$1,000/month)
- 1x Azure OpenAI account (S0 tier)
- 2x Model deployments with 250 TPM each
- 1x Storage account (LRS: ~$20/month for 100GB)
- Optional Log Analytics charges

**Estimated monthly cost**: $300-1,300 depending on SKU and usage.

## Production Recommendations

For production deployments, consider:

1. **Scale Configuration**:

   ```bicep
   searchServiceSku: 'standard'
   // Add multiple replicas for high availability
   ```

2. **Network Security**:

   ```bicep
   publicNetworkAccess: 'Disabled'
   // Configure private endpoints
   ```

3. **Monitoring**:

   ```bicep
   logAnalyticsWorkspaceResourceId: '/subscriptions/.../workspaces/prod-logs'
   ```

4. **Performance Optimization**:
   - Use standard or higher SKU for Search Service
   - Configure appropriate replica and partition counts
   - Implement caching strategies

## Security Best Practices

1. **Access Control**: Use managed identities and RBAC
2. **Network Security**: Configure private endpoints and firewall rules
3. **Key Management**: Rotate API keys regularly
4. **Data Protection**: Enable encryption at rest and in transit
5. **Monitoring**: Set up alerts and audit logging

## Troubleshooting

### Common Issues

1. **OpenAI Access Denied**

   ```
   Error: This subscription does not have access to Azure OpenAI
   ```

   **Solution**: Apply for Azure OpenAI access

2. **Search Service Name Conflict**

   ```
   Error: Search service name is not available
   ```

   **Solution**: Change the namePrefix parameter

3. **Storage Account Name Invalid**

   ```
   Error: Storage account name must be between 3 and 24 characters
   ```

   **Solution**: Ensure namePrefix + environmentName fits storage naming rules

4. **Insufficient Search Quota**
   ```
   Error: Quota exceeded for search services
   ```
   **Solution**: Request quota increase or choose different region

## Performance Tuning

### Search Service Optimization

- **Replicas**: Add replicas for query performance (1-12)
- **Partitions**: Add partitions for index size (1, 2, 3, 4, 6, 12)
- **Caching**: Implement application-level caching for frequent queries

### Vector Search Optimization

- **Dimensions**: Use appropriate embedding dimensions (3072 for text-embedding-3-large)
- **Algorithm**: Choose between HNSW and exhaustive KNN based on accuracy vs speed needs
- **Batch Processing**: Process documents in batches for better throughput

## Next Steps

After deployment:

1. **Test the Services**: Verify Search and OpenAI endpoints
2. **Create Search Index**: Define your document schema
3. **Implement Ingestion Pipeline**: Set up document processing
4. **Build RAG Application**: Implement the query logic
5. **Monitor Performance**: Set up dashboards and alerts

## Cleanup

To remove all resources:

```bash
az group delete --name rg-rag-demo --yes --no-wait
```

## Example Applications

This RAG setup is perfect for:

- **Document Q&A Systems**: Answer questions about internal documentation
- **Knowledge Bases**: Create intelligent search for support articles
- **Research Assistants**: Help users find and synthesize information
- **Customer Support**: Augment chatbots with accurate, context-aware responses

---

**Note**: This example provides a foundation for RAG implementations. Customize the indexing schema, search algorithms, and generation prompts based on your specific use case and requirements.
