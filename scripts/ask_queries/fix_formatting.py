import json
import sys


def main():
    """Read a JSON file, format it, and write it back"""
    if len(sys.argv) != 2:
        print("Usage: python fix_formatting.py <json_file_path>")
        sys.exit(1)

    file_path = sys.argv[1]

    try:
        # Read and parse JSON
        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        # Write formatted JSON back to file
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, sort_keys=True)

        print(f"Successfully formatted {file_path}")
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
