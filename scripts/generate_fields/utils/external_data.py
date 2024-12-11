import requests, os, logging
from utils.prompt import README_PROMPT

PAT = os.getenv("GITHUB_EMU_PAT")
HEADERS = {'Authorization': f'token {PAT}'} if PAT else {}

def get_readme(github_url: str) -> str:
    if github_url.startswith("https://github.com"):
        raw_github = "https://raw.githubusercontent.com"
        github_url = github_url.replace("https://github.com", raw_github)
        readme_url = f"{github_url}/refs/heads/main/README.md"
        response = requests.get(readme_url)
        if response.status_code == 404:
            try:
                github_api = github_url.replace(raw_github, "https://api.github.com/repos")
                res = requests.get(github_api, headers=HEADERS)
                repo_info = res.json()
                main_branch = repo_info.get("default_branch", "main")

                res = requests.get(f"{github_api}/contents", headers=HEADERS)
                contents = res.json()
                readme_file = [file['name'] for file in contents if 'readme' in file['name'].lower()][0]

                raw_github = "https://raw.githubusercontent.com"
                github_url = github_url.replace("https://github.com", raw_github)
                readme_url = f"{github_url}/refs/heads/{main_branch}/{readme_file}"

                response = requests.get(readme_url)
            except Exception as e:
                logging.error(f"Error getting readme file: {e}")
                raw_github = "https://raw.githubusercontent.com"
                github_url = github_url.replace("https://github.com", raw_github)
                readme_url = f"{github_url}/refs/heads/main/README.md"
                response = requests.get(readme_url)
    else: 
        readme_url = github_url
        response = requests.get(readme_url, headers=HEADERS)

    return format_readme_request(response.text)

def format_readme_request(response) -> str:
    return f"{README_PROMPT}:\n```\n{response}\n```{README_PROMPT}\n"