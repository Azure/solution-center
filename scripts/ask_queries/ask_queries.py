import os
import requests
import json
from typing import Dict, Any, Optional

SEMANTIC_CONFIGURATION = "cn-workloads-index-exp-wkf-semconf"
TOPK = 1

def get_search_credentials() -> tuple:
    """
    Get Azure Search credentials from environment variables.
    
    Returns:
        tuple: (api_key, service_name)
    """
    api_key = os.environ.get("AZURE_SEARCH_API_KEY")
    service_name = os.environ.get("AZURE_SEARCH_SERVICE_NAME", "workloads")
    
    if not api_key:
        raise ValueError("AZURE_SEARCH_API_KEY environment variable not set")
    
    return api_key, service_name

def search_index(
    query: str,
    index_name: str,
) -> Dict[str, Any]:
    """
    Search an Azure AI Search index with the given query.
    
    Args:
        query: The search text
        index_name: Name of the search index
        filter_condition: Optional OData filter expression
        top: Maximum number of results (default 10)
        select: Comma-separated list of fields to include in results
        order_by: Fields to sort by (e.g., "field1 asc, field2 desc")
    
    Returns:
        Dict containing search results
    """
    api_key, service_name = get_search_credentials()
    
    # Construct the search URL
    search_url = f"https://{service_name}.search.windows.net/indexes/{index_name}/docs/search?api-version=2023-07-01-Preview"
    
    # Set up headers
    headers = {
        "Content-Type": "application/json",
        "api-key": api_key
    }
    
    # Prepare request body
    request_body = {
        "search": query,
        "top": TOPK,
        "queryType": "semantic",
        "semanticConfiguration": SEMANTIC_CONFIGURATION,
    }
    
    try:
        response = requests.post(search_url, headers=headers, json=request_body)
        response.raise_for_status()  # Raise exception for non-2xx status codes
        return response.json()
    except requests.exceptions.HTTPError as http_err:
        print(f"HTTP error occurred: {http_err}")
        if response.text:
            print(f"Response content: {response.text}")
        return {"error": str(http_err)}
    except Exception as err:
        print(f"An error occurred: {err}")
        return {"error": str(err)}

def simple_search_example(query: str, index_name: str) -> None:
    """
    A simple example function to demonstrate searching an index.
    
    Args:
        query: Search term
        index_name: Name of the index to search
    """
    print(f"Searching for '{query}' in index '{index_name}'")
    results = search_index(query, index_name)
    
    if "error" in results:
        print(f"Search failed: {results['error']}")
        return

    return results

if __name__ == "__main__":
    index_name = "cn-workloads-field-experiment"
    search_query = "I want a python workload"

    with open("golden_dataset.json", "r") as f:
        golden_dataset = json.load(f)
    
    attempts = 0
    successes = 0
    baseline = {}
    for qa in golden_dataset:
        search_query = qa["user_requirements"]
        expected_workload = qa["expected_workload"]
        test_case_id = qa.get("test_case_id", "No ID")

        if expected_workload == "No matching workload":
            print(f"Skipping query '{search_query}' as it has no expected workload.")
            continue
        attempts += 1
        print(f"Running search for: {search_query}")
    
        workloads = simple_search_example(search_query, index_name)
        returned_workloads = set()
        for workload in workloads.get("value", []):
            returned_workloads.add(workload.get("id"))
        if expected_workload not in returned_workloads:
            print(f"Expected workload '{expected_workload}' not found in results for query '{search_query}'.")
            baseline[test_case_id] = {
                "search_query": search_query,
                "expected_workload": expected_workload,
                "returned_workloads": list(returned_workloads),
                "success": False,
            }
            continue
        baseline[test_case_id] = {
            "search_query": search_query,
            "expected_workload": expected_workload,
            "returned_workloads": list(returned_workloads),
            "success": True,
        }
        successes += 1

    baseline["total_attempts"] = attempts
    baseline["successful_searches"] = successes
    with open(f"{SEMANTIC_CONFIGURATION}{TOPK}.json", "w") as f:
        json.dump(baseline, f, indent=2)
    print(f"Total attempts: {attempts}, Successful searches: {successes}")
