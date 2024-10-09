import json

def read_file(file_path: str) -> list[dict]:
    with open(file_path, "r") as f:
        data = json.load(f)
    return data

def write_file(file_path: str, data: list[dict]):
    with open(file_path, "w") as f:
        json.dump(data, f, indent=4)
    
    return 0