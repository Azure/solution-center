# Welcome to Solution center! :wave:
      
## Overview

This repository is the central repository for the metadata defined in the Azure Portal's [Solution center](https://aka.ms/solutioncenter/portal).

## How to submit a solution?

Solution center enables our partners to deploy and manage Azure and open-source services and software all with a single metadata-driven repository. Some examples could be deploying webapps or using inexpensive virtual machines for machine learning. Solution center uses the concept of a "solution" to help customers understand and configure services and software with ease.

To get started, 
1. Fork the repository.
2. Copy `starter-template-v1` and customize the name of the folder with your solution name (must be unique). 
3. Follow the instructions below to author your first solution and solution card.
4. Add an ARM template per configuration to your solution folder, and reference it using the `templateFileName`.
5. Replace the solutionId in this URL and test your experience at: https://ms.portal.azure.com/?feature.canmodifystamps=true&Microsoft_Azure_SolutionCenter=flight1&feature.testmode=true#view/Microsoft_Azure_SolutionCenter/SolutionInfo.ReactView/solutionId/\<your solution id\>

A solution includes:

### configuration.metadata

Configuration metadata is how your solution looks to others. It defines pricing, resources deployed, and the path for the ARM template. 

- overviewContent: a single paragraph defining the solution, when & why customers might consider your solution, and its use case.
- associatedResources: a list of resources which will be deployed as apart of the deployment.
   - If a portal asset type, enter:
      - resourceType: found in [portal asset types](https://ms.portal.azure.com/#view/Microsoft_Azure_Resources/AssetTypes.ReactView)
      - type: "AzureResource"
   - If not a portal asset type, upload the icon and specify a reference, i.e.:
      - displayName: custom display name
      - type: "Custom"
      - icon:
         - iconType: "CustomIcon"
         - iconFileName: enter the name of the file, typically uploaded to the `icons` directory
- pivots: the differences between the configurations, choose a unique name and display name for each pivot
- documentationFileName: a markdown file in the repository which helps with architecture diagrams and addditional resources for deployment (2nd tab of solution).
- options: the details for each configuration.
   - id: Vertical column unique ID.
   - title: Vertical column header 1.
   - templateFileName: The ARM JSON with parameters specified. This will auto-load a create flow once the user selects your configuration.
   - subTitle: Vertical column header 2.
   - cost
      - supports a cost score or currency value (hourly/daily/monthly)
   - maintenanceScore
   - pivotValues
      - pivotName
      - content

### discovery.metadata

Discovery metadata is how you define your solution in a solution grouping page. It is also how your solution will look in Solution center.

- icon
- title
- shortDescription
- cost
- activationString
- keywords
- detailsDescription
- learnMoreLink
- learnMoreLinkText
- highlights: info on the card when expanded
   - content
   - highlightLearnMoreLink: optional
   - highlightLearnMoreLinkText: optional

#### **An example of a solution card with descriptions on**

![description-on-image](images/descriptions-on.png)

#### **An example of a solution card with descriptions off**

![description-off-image](images/descriptions-off.png)

#### **An example configuration with three pivots**
See `pivots` and `options` in `configuration.metadata` for implementation
![configuration](images/configuration.png)

## How to submit a solution group

So you have at least 3 solutions you'd like to help customers compare? Copy the `ExampleGroup.json` file under `scenariogroups` in the repository and add the solution IDs. Solution groups reference each individual `discovery.metadata.json` file to render the page.