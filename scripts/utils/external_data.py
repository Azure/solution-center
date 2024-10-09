import requests
from utils.prompt import README_PROMPT

def get_readme(github_url: str) -> str:
    raw_github = "https://raw.githubusercontent.com"
    github_url = github_url.replace("https://github.com", raw_github)
    readme_url = f"{github_url}/refs/heads/main/README.md"
    response = requests.get(readme_url)
    return format_readme_request(response.text)

def format_readme_request(response) -> str:
    return f"{README_PROMPT}:\n```\n{response}\n```{README_PROMPT}\n"