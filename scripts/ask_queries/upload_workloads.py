"""
Script to upload workload documents to Azure AI Search index.
"""

import os
import json
from typing import List, Dict, Any
import logging
from azure.core.credentials import AzureKeyCredential
from azure.search.documents import SearchClient

# Configuration variables
SEARCH_ENDPOINT = "https://workloads.search.windows.net"
SEARCH_API_KEY = os.getenv("AZURE_SEARCH_API_KEY", "your-api")
SEARCH_INDEX_NAME = "cn-workloads-field-experiment"
DATA_FILE_PATH = "./new_workloads.json"

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_search_client(endpoint: str, key: str, index_name: str) -> SearchClient:
    """
    Create and return a search client for Azure AI Search.
    
    Args:
        endpoint: The Azure AI Search service endpoint
        key: The Azure AI Search admin key
        index_name: The name of the index to connect to
        
    Returns:
        SearchClient: The client for uploading documents
    """
    credential = AzureKeyCredential(key)
    client = SearchClient(endpoint=endpoint, index_name=index_name, credential=credential)
    return client

def upload_documents(client: SearchClient, documents: List[Dict[str, Any]]) -> None:
    """
    Upload documents to the search index one by one.
    
    Args:
        client: The search client
        documents: List of document dictionaries to upload
    """
    total_succeeded = 0
    total_failed = 0
    
    for i, document in enumerate(documents):
        document.pop("deploymentConfig", None)  # Remove deploymentConfig if it exists
        document.pop("deploymentOptions", None)
        try:
            # Upload a single document
            result = client.upload_documents(documents=[document])
            
            if result[0].succeeded:
                total_succeeded += 1
                logger.info(f"Successfully uploaded document {i+1}/{len(documents)}")
            else:
                total_failed += 1
                logger.error(f"Failed to upload document {i+1}/{len(documents)}: {result[0].error_message}")
                
        except Exception as e:
            total_failed += 1
            logger.error(f"Error uploading document {i+1}/{len(documents)}: {str(e)}")
    
    logger.info(f"Upload completed. Succeeded: {total_succeeded}, Failed: {total_failed}")

def load_documents(file_path: str) -> List[Dict[str, Any]]:
    """
    Load documents from a JSON file.
    
    Args:
        file_path: Path to the JSON file containing documents
        
    Returns:
        List of document dictionaries
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            documents = json.load(f)
            logger.info(f"Loaded {len(documents)} documents from {file_path}")
            return documents
    except Exception as e:
        logger.error(f"Failed to load documents: {str(e)}")
        return []

def main():
    # Create search client using the configuration variables
    client = get_search_client(SEARCH_ENDPOINT, SEARCH_API_KEY, SEARCH_INDEX_NAME)
    
    # Load documents
    documents = load_documents(DATA_FILE_PATH)
    
    if documents:
        # Upload documents
        upload_documents(client, documents)
        logger.info("Document upload operation completed")
    else:
        logger.warning("No documents to upload")

if __name__ == "__main__":
    main()
