import json

from openai import AzureOpenAI
from utils.external_data import get_readme
from utils.prompt import DISCLAIMER_PROMPT, SAMPLE_NEGATIVE_MATCH_PROMPT, SAMPLE_PRODUCTS_PROMPT, SAMPLE_TECH_PROMPT, SAMPLE_QUERIES_PROMPT, WORKLOAD_TYPE_PROMPT

FIELDS_THAT_NEED_RESPONSES = ["sampleQueries", "tech", "products"]

def get_responses(workload: dict, client: AzureOpenAI, deployment_model: str) -> dict|str:
    if workload["sourceType"] != "ExecDocs": external_data = get_readme(workload['source'])
    else: external_data = ""
    for field in FIELDS_THAT_NEED_RESPONSES:
        # print(f"Getting response for {field}")
        workload[field] = get_field_response(client, workload, field, deployment_model, external_data)

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

    prompt = f"""title: {workload["title"]}\ndescription: {workload["description"]}\ntags:{workload['tags']}\n\n{external_data}{DISCLAIMER_PROMPT}\n\nYour Response:\n"""

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
        # print(f"{field}: {response.choices[0].message.content}")
        return json.loads(response.choices[0].message.content)
    except Exception as e:
        return str(response.choices[0].message.content)