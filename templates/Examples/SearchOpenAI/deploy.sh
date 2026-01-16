#!/bin/bash

# Azure Search + OpenAI RAG Deployment Script
# This script demonstrates how to deploy the combined Search and OpenAI modules for RAG scenarios

set -e

# Configuration
RESOURCE_GROUP_NAME="rg-rag-demo"
LOCATION="westeurope"
DEPLOYMENT_NAME="rag-deployment-$(date +%Y%m%d-%H%M%S)"
TEMPLATE_FILE="example-search-openai.bicep"
PARAMETERS_FILE="parameters.json"

echo "🚀 Starting Azure Search + OpenAI RAG deployment..."

# Check if Azure CLI is installed and user is logged in
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    echo "❌ You are not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Get current subscription info
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SUBSCRIPTION_NAME=$(az account show --query name --output tsv)

echo "📋 Deployment Configuration:"
echo "   Subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"
echo "   Resource Group: $RESOURCE_GROUP_NAME"
echo "   Location: $LOCATION"
echo "   Template: $TEMPLATE_FILE"
echo "   Parameters: $PARAMETERS_FILE"
echo ""

# Create resource group if it doesn't exist
echo "🔍 Checking if resource group exists..."
if ! az group show --name "$RESOURCE_GROUP_NAME" &> /dev/null; then
    echo "📦 Creating resource group: $RESOURCE_GROUP_NAME"
    az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"
else
    echo "✅ Resource group already exists: $RESOURCE_GROUP_NAME"
fi

# Validate the template
echo "🔍 Validating Bicep template..."
az deployment group validate \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file "$TEMPLATE_FILE" \
    --parameters "@$PARAMETERS_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Template validation successful"
else
    echo "❌ Template validation failed"
    exit 1
fi

# Deploy the template
echo "🚀 Deploying Azure Search + OpenAI RAG resources..."
az deployment group create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$DEPLOYMENT_NAME" \
    --template-file "$TEMPLATE_FILE" \
    --parameters "@$PARAMETERS_FILE" \
    --verbose

if [ $? -eq 0 ]; then
    echo "✅ Deployment completed successfully!"
    
    # Get deployment outputs
    echo "📊 Deployment outputs:"
    OUTPUTS=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$DEPLOYMENT_NAME" \
        --query properties.outputs)
    
    echo "$OUTPUTS" | jq '.'
    
    # Extract key information
    SEARCH_ENDPOINT=$(echo "$OUTPUTS" | jq -r '.searchServiceEndpoint.value')
    OPENAI_ENDPOINT=$(echo "$OUTPUTS" | jq -r '.openAiEndpoint.value')
    STORAGE_NAME=$(echo "$OUTPUTS" | jq -r '.storageAccountName.value')
    
    echo ""
    echo "🎉 RAG Platform deployment completed!"
    echo "📝 Quick Start Information:"
    echo "   Search Service Endpoint: $SEARCH_ENDPOINT"
    echo "   OpenAI Endpoint: $OPENAI_ENDPOINT"
    echo "   Storage Account: $STORAGE_NAME"
    echo ""
    echo "🔗 View your resources in the Azure Portal:"
    echo "   https://portal.azure.com/#@/resource/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME"
    echo ""
    echo "📚 Next Steps:"
    echo "   1. Create a search index for your documents"
    echo "   2. Upload documents to the storage account"
    echo "   3. Index documents with embeddings using OpenAI"
    echo "   4. Implement your RAG application"
else
    echo "❌ Deployment failed"
    exit 1
fi
