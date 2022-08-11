# Welcome to Solution center! :wave:
      
## Overview

This repository is the central repository for the metadata defined in the Azure Portal's [Solution center](https://aka.ms/solutioncenter/portal).

## How to submit a solution

Solution center enables our partners to deploy and manage Azure and open-source services and software all with a single metadata-driven repository. Some examples could be deploying webapps or using inexpensive virtual machines for machine learning. Solution center uses the concept of a "solution" to help customers understand and configure services and software with ease.

A solution includes:

### configuration.metadata

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
- options: the details for each configuration option
   - id: Vertical column unique ID.
   - title: Vertical column header 1.
   - subTitle: Vertical column header 2.
   - cost
      - supports a cost score or currency value (hourly/daily/monthly)
   - maintenanceScore
   - pivotValues
      - pivotName
      - content

### discovery.metadata

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
