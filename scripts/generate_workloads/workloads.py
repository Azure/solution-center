import os

from openai import AzureOpenAI
from utils.file_functions import read_file, write_file
from utils.get_responses import get_responses

FILE_PATH = "workloads/workloads.json"
DEPLOYMENT_MODEL = "gpt4-turbo-preview"
FAILED_WORKLOADS = "failed_workloads.json"
SUCCESSFUL_WORKLOADS = "new_workloads.json"


def main():
    workloads = read_file(FILE_PATH)

    client = AzureOpenAI(
        api_key = os.getenv("AZURE_OPENAI_API_KEY"),
        api_version = "2024-02-01",
        azure_endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
    )

    finished_workloads = []

    for workload in workloads:
        finished_workloads.append(get_responses(workload, client, DEPLOYMENT_MODEL))
    
    write_file(SUCCESSFUL_WORKLOADS, finished_workloads)
    

if __name__ == '__main__':
    main()