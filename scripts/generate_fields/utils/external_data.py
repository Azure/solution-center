import requests, os, logging
from utils.prompt import README_PROMPT

PAT = os.getenv("GITHUB_EMU_PAT")
EMU_PAT = os.getenv("GITHUB_EMU_PAT")

HEADERS = {'Authorization': f'token {PAT}'} if PAT else {}
EMU_HEADERS = {'Authorization': f'token {EMU_PAT}'} if EMU_PAT else {}

def get_readme(github_url: str) -> str:
    if github_url.startswith("https://github.com"):
        raw_github = "https://raw.githubusercontent.com"
        github_url = github_url.replace("https://github.com", raw_github)
        readme_url = f"{github_url}/refs/heads/main/README.md"
        response = requests.get(readme_url)
        if response.status_code == 404:
            try:
                logging.info(f"Getting correct branch and readme from {github_url}")
                github_api = github_url.replace(raw_github, "https://api.github.com/repos")

                res = requests.get(f"{github_api}/contents", headers=HEADERS)
                if res.status_code != 200:
                    res = requests.get(f"{github_api}/contents", headers=EMU_HEADERS)
                contents = res.json()
                readme_file = [file['download_url'] for file in contents if 'readme' in file['name'].lower()][0]
                logging.info(f"Getting data from {readme_file}")

                response = requests.get(readme_file)
            except Exception as e:
                logging.error(f"Error getting readme file: {e}")
                raw_github = "https://raw.githubusercontent.com"
                github_url = github_url.replace("https://github.com", raw_github)
                readme_url = f"{github_url}/refs/heads/main/README.md"
                response = requests.get(readme_url)
    else: 
        logging.info(f"Getting data from {github_url}")
        readme_url = github_url
        response = requests.get(readme_url)

    return format_readme_request(response.text), response

def format_readme_request(response) -> str:
    return f"{README_PROMPT}:\n```\n{response}\n```{README_PROMPT}\n"