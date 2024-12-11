import argparse, json, requests, logging

logging.basicConfig(level=logging.INFO, format='[%(asctime)s] - %(levelname)s - %(message)s')

def main(root="."):
    workloads = json.load(open(f"{root}/workloads/workloads.json", "r"))
    keep_workloads = []

    for workload in workloads:
        res = requests.get(workload["source"])

        print(res.status_code, workload["source"])
        if res.status_code == 200:
            logging.info(f"Keeping workload {workload['title']}")
            keep_workloads.append(workload)
        else:
            logging.info(f"Removing workload {workload['title']}")
    
    json.dump(keep_workloads, open(f"{root}/workloads/workloads.json", "w"), indent=4)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Delete unsupported workloads in workloads.json. Does so by looking at the source url.", 
                                      usage="%(prog)s --root ROOT")
    parser.add_argument("-r", "--root", help="Path to the root directory.", required=True)

    args = parser.parse_args()

    main(args.root)