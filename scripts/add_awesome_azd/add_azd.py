import json
import uuid

def main():
    with open("./workloads/azd_templates.json", "r") as f:
        data = json.load(f)

    new_workloads = []

    ## Get azd workloads
    for workload in data:
        if "msft" in workload["tags"]:
            new_workloads.append(workload)

    ## Add correct fields
    with open("./workloads/workloads.json", "r") as f:
        workloads = json.load(f)
    
    correct_keys = []
    unique_azd = {}
    for key in workloads[0].keys():
        correct_keys.append(key)

    for workload in workloads:
        unique_azd[workload["source"]] = workload

    ## Add correct keys for new_workloads
    for workload in new_workloads:
        if workload["source"] in unique_azd:
            keys = unique_azd[workload["source"]].keys()
            for key in keys:
                if key in workload:
                    unique_azd[workload["source"]][key] = workload[key]
        else:
            new_workload = {}
            for key in correct_keys:
                if key in workload:
                    new_workload[key] = workload[key]
                else:
                    match key:
                        case "tags":
                            new_workload[key] = []
                        case "products":
                            new_workload[key] = []
                        case "sampleQueries":
                            new_workload[key] = []
                        case "deploymentOptions":
                            new_workload[key] = ["AzD"]
                        case "sourceType":
                            new_workload[key] = "Azd"
                        case "deploymentConfig":
                            new_workload[key] = {}
                        case "id":
                            new_workload[key] = str(uuid.uuid4())
            workloads.append(new_workload)

    ## Write to file
    with open("./workloads/new_workloads.json", "w") as f:
        json.dump(workloads, f, indent=4)

if __name__ == "__main__":
    main()