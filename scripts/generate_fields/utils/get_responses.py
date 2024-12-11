import json
import uuid
import time
from openai import AzureOpenAI

from utils.external_data import get_readme
from utils.prompt import KEY_FEATURES_PROMPT, DISCLAIMER_PROMPT, SAMPLE_NEGATIVE_MATCH_PROMPT, SAMPLE_PRODUCTS_PROMPT, SAMPLE_TECH_PROMPT, SAMPLE_QUERIES_PROMPT, WORKLOAD_TYPE_PROMPT, TAGS_PROMPT
import logging

FIELDS_THAT_NEED_RESPONSES = ["tags", "keyFeatures", "sampleQueries", "tech", "products"]
# Configure logging
logging.basicConfig(level=logging.INFO, format='[%(asctime)s] - %(levelname)s - %(message)s')

def get_responses(workload: dict, client: AzureOpenAI, deployment_model: str, fields_that_need_responses = FIELDS_THAT_NEED_RESPONSES, all_workloads = False) -> dict | str:
    logging.info(f"Processing workload: {workload['title']}")
    external_data = get_readme(workload['source'])
    if workload["id"] == "": workload["id"] = str(uuid.uuid4())
    for field in fields_that_need_responses:
        if (not all_workloads and workload.get(field, None)): continue
        logging.info(f"Getting response for {field}")
        
        try:
            workload[field] = get_field_response(client, workload, field, deployment_model, external_data)
            logging.info(f"Successfully got response for {field}")
            logging.info(f"Field {field} - Response: {workload[field]}")
        except Exception as e:
            logging.error(f"Error getting response for {field}: {e}")
            workload[field] = str(e)
        time.sleep(5)

    return workload

def get_field_response(client: AzureOpenAI, workload: dict, field: str, deployment_model: str, external_data: str) -> str:
    ask_prompt = ""

    match field:
        case "sampleQueries":
            if workload[field]: return workload[field]
            ask_prompt = f"{SAMPLE_QUERIES_PROMPT}{WORKLOAD_TYPE_PROMPT}\nsourceType: {workload['sourceType']}\n"
        case "tech":
            ask_prompt = SAMPLE_TECH_PROMPT
        case "products":
            ask_prompt = SAMPLE_PRODUCTS_PROMPT
        case "negativeMatch":
            ask_prompt = SAMPLE_NEGATIVE_MATCH_PROMPT
        case "keyFeatures":
            ask_prompt = KEY_FEATURES_PROMPT
        case "tags":
            ask_prompt = TAGS_PROMPT

    prompt = f"""title: {workload["title"]}\ndescription: {workload["description"]}\ntags:{workload['tags']}\n\n{external_data}\n\n{DISCLAIMER_PROMPT}\n\nYour Response:\n"""

    try:
        response = client.chat.completions.create(
            model=deployment_model, 
            messages=[
                {
                    "role": "system",
                    "content": f"{DISCLAIMER_PROMPT}\n\n{ask_prompt}\n\n{prompt}"
                }
            ],
        )
        return json.loads(response.choices[0].message.content)
    except Exception as e:
        return str(response.choices[0].message.content)