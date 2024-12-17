import json, uuid, argparse, logging

logging.basicConfig(level=logging.INFO, format='[%(asctime)s] - %(levelname)s - %(message)s')

def main(root: str, input_file: str, check_quality: bool = False):
    workloads_file = f"{root}/workloads/workloads.json"

    with open(input_file, "r") as f:
        data = json.load(f)

    new_workloads = []
    active_workload_sources = set()

    ## Get azd workloads
    for workload in data:
        if workload["status"] == "active":
            new_workloads.append(workload)
            active_workload_sources.add(workload["sourceUrl"])
        elif check_quality:
            if workload.get("quality", None):
                new_workloads.append(workload)

    ## Add correct fields
    with open(workloads_file, "r") as f:
        workloads = json.load(f)

    non_active_exec_docs = []
    for workload in workloads:
        if workload["sourceType"] == "ExecDocs" and workload["source"] not in active_workload_sources:
            non_active_exec_docs.append(workload)

    for workload in non_active_exec_docs:
        logging.info(f"Removing workload: {workload['title']}")
        workloads.remove(workload)
    
    correct_keys =  workloads[0].keys()
    unique_exec = {}
    for workload in workloads:
        unique_exec[workload["source"]] = workload

    ## Add correct keys for new_workloads
    for exec_workload in new_workloads:
        logging.info(f"Processing workload: {workload['title']}")
        if exec_workload["sourceUrl"] in unique_exec:
            for key in exec_workload.keys():
                if key in correct_keys:
                    unique_exec[exec_workload["sourceUrl"]][key] = exec_workload[key]
        else:
            logging.info(f"Adding new workload: {workload['title']}")
            new_workload = {}
            for key in correct_keys:
                if key in exec_workload:
                    new_workload[key] = exec_workload[key]
                else:
                    match key:
                        case "source":
                            new_workload[key] = exec_workload["sourceUrl"]
                        case "tags":
                            new_workload[key] = []
                        case "products":
                            new_workload[key] = []
                        case "sampleQueries":
                            new_workload[key] = []
                        case "deploymentOptions":
                            new_workload[key] = ["azcli"]
                        case "sourceType":
                            new_workload[key] = "ExecDocs"
                        case "deploymentConfig":
                            new_workload[key] = {
                                "execDocs": {
                                    "path": exec_workload["key"].replace("/", "%2F")
                                }
                            }
                        case "id":
                            new_workload[key] = str(uuid.uuid4())
                        case "tech":
                            new_workload[key] = []
                        case "keyFeatures":
                            new_workload[key] = []
                        case _:
                            new_workload[key] = []
            workloads.append(new_workload)

    ## Write to file
    with open(workloads_file, "w") as f:
        json.dump(workloads, f, indent=4)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process workloads and add necessary fields.", 
                                      usage="%(prog)s --root ROOT --input_file INPUT_FILE [--check-quality]")
    parser.add_argument("-r", "--root", help="Path to the root directory.", required=True)
    parser.add_argument("-i", "--input_file", help="Path to the input JSON file.", required=True)
    parser.add_argument("--check-quality", action="store_true", help="Whether to check the quality field in the workloads.")

    args = parser.parse_args()

    main(args.root, args.input_file, args.check_quality)