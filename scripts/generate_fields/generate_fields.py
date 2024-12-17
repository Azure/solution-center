import os
import argparse
from openai import AzureOpenAI

from utils.file_functions import read_file, write_file
from utils.get_responses import get_responses
from utils.fields import get_fields

FILE_PATH = "workloads/workloads.json"
DEPLOYMENT_MODEL = "gpt-4o-mini"
FAILED_WORKLOADS = "failed_workloads.json"
SUCCESSFUL_WORKLOADS = "workloads/workloads.json"


def main(all_workloads: bool = False, fields: str = "", root: str = ".", output: str = ""):
    """
    Process workloads with Azure OpenAI.
    
    Arguments:
    all_workloads -- Boolean indicating whether to process all workloads.
    fields        -- String of fields to turn on, represented by letters.
    
    Usage examples:
    1. To process all workloads:
        python script_name.py --all-workloads
    
    2. To process specific fields:
        python script_name.py --fields abc
    """

    fields_that_need_responses = get_fields(fields)

    if not root: root = "."
    workloads = read_file(f"{root}/{FILE_PATH}")
    client = AzureOpenAI(
        api_key = os.getenv("AZURE_OPENAI_API_KEY"),
        api_version = "2024-02-01",
        azure_endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
    )

    finished_workloads = []

    for workload in workloads:
        finished_workloads.append(get_responses(workload, client, DEPLOYMENT_MODEL, fields_that_need_responses, all_workloads))
    
    if not output:
        write_file(f"{root}/{SUCCESSFUL_WORKLOADS}", finished_workloads)
    else:
        write_file(output, finished_workloads)
    

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=(
            'Process workloads with Azure OpenAI.\n\n'
            'Usage examples:\n'
            '1. To process all workloads:\n'
            '   python script_name.py --all-workloads\n'
            '\n'
            '2. To process specific fields:\n'
            '   python script_name.py --fields '
        ),
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument('-r', '--root', type=str, help='Path to the root directory')
    parser.add_argument('-a', '--all-workloads', action='store_true', help='Process all workloads')
    parser.add_argument('-f', '--fields', type=str, default='', help='String of fields to turn on, letters to indicate fields')
    parser.add_argument('-o', '--output', type=str, help='Path to the output file')

    args = parser.parse_args()

    main(all_workloads=args.all_workloads, fields=args.fields, root=args.root, output=args.output)