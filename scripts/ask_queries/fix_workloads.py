import json

with open("./workloads/workloads.json", "r") as f:
    real_workloads = json.load(f)

with open("./new_workloads.json", "r") as f:
    new_workloads = json.load(f)

workload_ref = {}
for workload in new_workloads:
    workload_ref[workload["id"]] = workload

for workload in real_workloads:
    workload_id = workload["id"]
    if workload["sourceType"] == "ExecDocs":
        continue
    workload["infrastructure"] = workload_ref.get(workload_id, {}).get("infrastructure", [])
    workload["infraExplained"] = workload_ref.get(workload_id, {}).get("infraExplained", [])

with open("new_workloads_2.json", "w") as f:
    json.dump(real_workloads, f, indent=2)