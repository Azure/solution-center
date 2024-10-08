PROMPT = """Add more sample queries to this json: """

README_PROMPT = """
This is data straight from the github readme of the workload. You can also use this in your decisions for creating the correct responses for the field you are creating.
IF THE TECHNOLOGY IN THE README IS POINTING TO OR REFERENCING ANOTHER WEBSITE OR REPOSITORY THEN DON'T USE THAT TECHNOLOGY. FOR EXAMPLE:
This solution's backend is written in Python. There are also [**JavaScript**](https://aka.ms/azai/js/code), [**.NET**](https://aka.ms/azai/net/code), and [**Java**](https://aka.ms/azai/java/code) samples based on this one. Learn more about [developing AI apps using Azure AI Services](https://aka.ms/azai).

SHOULD ONLY RETURN ["python"] AS **THIS** SOLUTION IS WRITTEN IN PYTHON, AND THE OTHER LANGUAGES ARE REFERENCES TO OTHER WEBSITES.
"""

SAMPLE_QUERIES_PROMPT = """
Make a json list object that can be read with json.loads() in python that contains 3 sample queries for the workload. THIS MEANS YOU ONLY RETURN THE LIST OBJECT WITH NO OTHER WORDS, AND STRING ARE DOUBLE QUOTED ALWAYS.
Sample queries are something a user could potentially ask to access this workload. These workloads all exist in github repositories and are designed to be used as a starting point for a project. With this in mind, users might not know about this workload and might ask general questions related to a tech stack or technology, so be sure to consider that when designing questions.
Here is an example of how to derive sample queries from the workload given a workload title, description, tags, and sourcetype:
sourceType: "Azd"
title: "ChatGPT + Enterprise data with Azure OpenAI and AI Search"
description: "A sample app for the Retrieval-Augmented Generation pattern running in Azure, using Azure AI Search for retrieval and Azure OpenAI large language models to power ChatGPT-style and Q&A experiences."
tags: ["OpenAI", "Azure", "AI Search", "ChatGPT", "Enterprise"]

Your Response:
"["How to use Azure AI Search to power ChatGPT-style and Q&A experiences", "Can I use Azure OpenAI to enhance ChatGPT responses with my company's proprietary data?", "How to integrate Azure AI Search with ChatGPT for custom knowledge bases?"]"

WORKLOAD DETAILS:

"""

SAMPLE_TECH_PROMPT = """
Make a json list object that can be read with json.loads() in python that contains the tech used in a workload. THIS MEANS YOU ONLY RETURN THE LIST OBJECT WITH NO OTHER WORDS, AND STRING ARE DOUBLE QUOTED ALWAYS.
The tech in a workload simply refers to languages, frameworks, and APIs used in the stack. ONLY INCLUDE LANGUAGES, FRAMEWORKS, DATABASES, AND APIs for this section that you can directly see in the workload or can infer based on a suffix like langchain.js which is a javascript node.js tech stack. This can be inferred from the tags and the title and/or description and tags for the workload.
Here is an example of how to derive tech from the workload given a workload title, description, and tags:
title: "React Web App with Node.js API and MongoDB"
description: "Features a Chat-GPT-like user interface, including additional capabilities to debug responses, restyle, revisit history and reset the chat."
tags: ["bicep", "nodejs", "typescript", "javascript", "appservice", "cosmosdb", "monitor", "keyvault", "mongodb", "reactjs", "msft"],

Your Response:
"["Bicep", "Nodejs", "Typescript", "Javascript", "Reactjs", "MongoDB", "CosmosDB"]"

IT IS IMPORTANT YOU ONLY USE LANGUAGES AND FRAMWORKS AND DATABASES AND APIS IN THIS, NO OTHER AZURE PRODUCTS, SERVICES, OR PLATFORMS. LETS BE CONSISTENT ESPECIALLY WITH LANGUAGES OF ALL FLAVORS, WHETHER IT'S A PROGRAMMING LANGUAGE OR A MARKUP LANGUAGE, IT BELONGS HERE.
THIS CAN BE LEFT BLANK IF THERE ARE NO LANGUAGES OR FRAMEWORKS MENTIONED. DON'T INCLUDE PLATFORMS (HINT: ChatGPT is a platform, OpenAI is an API). AND START EVERY STRING WITH A CAPITAL LETTER AND ITS FORMAL NAME LIKE dotnetsharp=.NET OR C# AND NO SPACES! DONT FORGET BICEP OR TERRAFORM!

WORKLOAD DETAILS:

"""

SAMPLE_PRODUCTS_PROMPT = """"
Make a json list object that can be read with json.loads() in python that contains the azure products used in a workload. THIS MEANS YOU ONLY RETURN THE LIST OBJECT WITH NO OTHER WORDS, AND STRING ARE DOUBLE QUOTED ALWAYS.
The azure products in a workload simply refers to any service offered through azure. ONLY INCLUDE THESE SERVICES IN THIS LIST AND ONLY FIND THEM IN THE TAGGED SECTION OR THE DESCRPTION OR THE TITLE DIRECTLY. ALL INFORMATION WILL BE IN THESE THREE SECTIONS.
Here is an example of how to derive azure products from the workload given a workload title, description, and tags:
title: "React Web App with Node.js API and MongoDB"
description: "Features a Chat-GPT-like user interface, including additional capabilities to debug responses, restyle, revisit history and reset the chat."
tags: ["bicep", "nodejs", "typescript", "javascript", "appservice", "cosmosdb", "monitor", "keyvault", "mongodb", "reactjs", "msft"],

Your Response:
"["Azure App Service", "Azure Cosmos DB", "Azure Monitor", "Azure Keyvault"]"

THIS CAN BE LEFT BLANK IF THERE ARE NO AZURE PRODUCTS MENTIONED. DON'T GO CRAZY AND INFER A BUNCH OF AZURE PRODUCTS, ONLY MENTION WHAT IS STRICTLY MENTIONED.

WORKLOAD DETAILS:

"""

SAMPLE_NEGATIVE_MATCH_PROMPT = """
Make a json list object that can be read with json.loads() in python that contains the lack of other languages or tech commonly used in a workload. THIS MEANS YOU ONLY RETURN THE LIST OBJECT WITH NO OTHER WORDS, AND STRING ARE DOUBLE QUOTED ALWAYS.
The tech in a workload simply refers to languages, frameworks, and common services used in a stack but not included in this particular one. ONLY INCLUDE LANGUAGES, FRAMEWORKS, AND COMMON SERVICES NORMALLY USED IN A STACK BUT NOT PRESENT IN THIS STACK for this section that you can directly see in the workload.
Here is an example of how to derive negative match from the workload given a workload title, description, and tags:
title: "React Web App with Node.js API and MongoDB"
description: "Features a Chat-GPT-like user interface, including additional capabilities to debug responses, restyle, revisit history and reset the chat."
tags: ["bicep", "nodejs", "typescript", "javascript", "appservice", "cosmosdb", "monitor", "keyvault", "mongodb", "reactjs", "msft"],

Your Response:
"["Python", "Azure Functions", "PostgreSQL", ".NET", "Java", "Spring Boot", "Angularjs", "Vuejs", "Flask"]"

IT IS IMPORTANT YOU DON'T GET CRAZY WITH THIS LIST. DON'T LIST EVERYTHING THAT HAS TO DO WITH ONE NICHE TECH STACK, JUST THE MOST COMMONLY USED TECH STACKS THAT ARE NOT IN THIS WORKLOAD. WHAT I MEAN BY NOT GETTING CRAZY IS IF THE WORKLOAD DOESN'T MENTION A DATABASE, THEN DON'T EVEN TALK ABOUT DATABASES! SAME THING GOES FOR LANGUAGES AND FRAMEWORKS!
YOU ARE ALLOWED TO LEAVE THIS BLANK IF THERE ARE NO OBVIOUS NEGATIVE MATCHES! AND START EVERY STRING WITH A CAPITAL LETTER.

WORKLOAD DETAILS:

"""

DISCLAIMER_PROMPT = """
BECAUSE I AM USING json.loads() YOU ARE TO JUST RETURN THE LIST OBJECT WITH NO OTHER WORDS, AND STRING ARE DOUBLE QUOTED ALWAYS. PLEASE FOLLOW THIS INSTRUCTION AND RETURN THE CORRECT FORMAT. NO BACKTICKS!!!
"""

WORKLOAD_TYPE_PROMPT = """
If AzD then it's a github workload that uses AzD templates to quickstart your journey with this workload on azure. 
If ExecDocs then it's a workload that is deployed straight onto Azure via Executable Docs after following a guided experience.
If AzureSamples then it's a simple github repository.
"""