import os
import json
import argparse
import time
from openai import AzureOpenAI
import requests

# Configure basic logging
import logging
logging.basicConfig(level=logging.INFO, format='[%(asctime)s] - %(levelname)s - %(message)s')

EMU_PAT = os.getenv("GIT_EMU_PAT")

EMU_HEADERS = {'Authorization': f'token {EMU_PAT}'} if EMU_PAT else {}

def get_readme(github_url: str) -> str:
    if github_url.startswith("https://github.com"):
        raw_github = "https://raw.githubusercontent.com"
        github_url = github_url.replace("https://github.com", raw_github)
        readme_url = f"{github_url}/refs/heads/main/README.md"
        response = requests.get(readme_url)
        if response.status_code == 404:
            try:
                logging.info(f"Getting correct branch and readme from {github_url}")
                github_api = github_url.replace(raw_github, "https://api.github.com/repos")

                res = requests.get(f"{github_api}/contents", headers=EMU_HEADERS)
                contents = res.json()
                readme_file = [file['download_url'] for file in contents if 'readme' in file['name'].lower()][0]
                logging.info(f"Getting data from {readme_file}")

                response = requests.get(readme_file)
            except Exception as e:
                logging.error(f"Error getting readme file: {e}")
                raw_github = "https://raw.githubusercontent.com"
                github_url = github_url.replace("https://github.com", raw_github)
                readme_url = f"{github_url}/refs/heads/main/README.md"
                response = requests.get(readme_url)
    else: 
        logging.info(f"Getting data from {github_url}")
        readme_url = github_url
        response = requests.get(readme_url)

    return response.text, response

def read_file(filepath):
    """Read JSON file and return its contents."""
    try:
        with open(filepath, 'r', encoding='utf-8') as file:
            return json.load(file)
    except Exception as e:
        logging.error(f"Error reading file {filepath}: {e}")
        return []

def write_file(filepath, data):
    """Write data to a JSON file."""
    try:
        with open(filepath, 'w', encoding='utf-8') as file:
            json.dump(data, file, indent=2)
        logging.info(f"Successfully wrote to {filepath}")
    except Exception as e:
        logging.error(f"Error writing to file {filepath}: {e}")

def modify_field_with_ai(client, item, model="gpt-4o-mini"):
    """Use Azure OpenAI to modify a specific field in an item."""
    original_value = []
    readme, response = get_readme(item.get("source", ""))
    if response.status_code != 200 or not readme:
        logging.warning(f"Could not fetch README from {item.get('source', '')}. Using empty list for keyFeatures.")
        logging.error(f"Failed to fetch README from {item.get('source', '')}: {response.status_code} {response.text}")
        return original_value

    prompt = f"""
        Here is the README for the workload as well so that you can understand the context for the workload:

        
        {readme}


        I need your help finishing a field in a JSON object called 'infraExplained'. It will explain why
        the infrastructure is there for the workload in question. The field is currently empty and I need you to
        go through the infrastructure field and provide a list of key features, line by line (JUST ONE LINE PER INFRASTRUCTURE, NO MORE NO LESS)
        for each of the values. Here is the Infrastructure field:
        {item["infrastructure"]}
        Please provide the key features in a JSON array format, like this:
        [
            "Microsoft.DocumentDB/databaseAccounts -- This is a Cosmos DB account used for storing data",
            "Microsoft.Compute/virtualMachines -- This is a Linux virtual machine used for running the application",
            "Microsoft.App/containerApps -- This is a container for hosting the React application"
        ]
        Notice How I'm specifying what tech stack is used for that resource, this is important. For example if it's a REACT web app, specify that
        if it's being used in a container app, webapp, or site.

        ONLY PROVIDE THE JSON ARRAY, VALID JSON ONLY.
        """

    try:
        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": "You are a helpful assistant specialized in improving content."},
                {"role": "user", "content": prompt}
            ]
        )
        
        # Try to parse as JSON first, fall back to raw text if that fails
        response_text = response.choices[0].message.content.strip()
        # remove ```json if present
        if response_text.startswith("```json"):
            response_text = response_text[7:].strip()
        # Remove backticks if present
        response_text = response_text.replace("`", "").replace("'", '"')
        try:
            logging.info(f"Response from Azure OpenAI: {response_text}")
            modified_value = json.loads(response_text)
            return modified_value
        except json.JSONDecodeError:
            logging.warning(f"Response wasn't valid JSON. Using raw text.")
            return response_text
            
    except Exception as e:
        logging.error(f"Error calling Azure OpenAI: {e}")
        return original_value

def process_items(input_file, output_file):
    """Process all items in the input file and modify specified field."""
    # Initialize Azure OpenAI client
    client = AzureOpenAI(
        api_key=os.getenv("AZURE_OPENAI_API_KEY"),
        api_version="2024-02-01",
        azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT")
    )
    
    # Read input file
    items = read_file(input_file)
    if not items:
        return
    
    # Process each item
    for i, item in enumerate(items):
        logging.info(f"Processing item {i+1}/{len(items)}: {item.get('title', 'Untitled')}")
        
        # Modify the specified field
        keyFeatures = modify_field_with_ai(client, item)
        if not keyFeatures:
            logging.warning(f"No key features generated for item {i+1}. Using empty list.")
            continue
        item["infraExplained"] = keyFeatures
        
        # Add a small delay to avoid rate limits
        time.sleep(2)
    
    # Write the modified data back
    write_file(output_file, items)
    logging.info(f"Completed processing {len(items)} items")

def main():
    parser = argparse.ArgumentParser(description="Modify a specific field in JSON items using Azure OpenAI")
    parser.add_argument("--input", "-i", required=True, help="Path to the input JSON file")
    parser.add_argument("--output", "-o", required=True, help="Path for the output JSON file")
    
    args = parser.parse_args()
    
    process_items(args.input, args.output)

if __name__ == "__main__":
    main()
