# Your Project Name

TODO: Give a **brief description** of the app.
Explain the **high level goals** and the **main** features.

TODO: Make sure you adjust or augment the information that is provided by default in this document.
e.g. If you decide to change the solution structure, you should mention it in the [Solution Structure section](#solution-structure).

## Project Template

This repository was generated using the **nventive Mobile Template**.
- Version: {{app-template-version}}
- Commit: [{{app-template-commit-short-sha}}](https://github.com/nventive/FlutterApplicationTemplate/tree/{{app-template-commit-full-sha}})
- Date: {{app-template-commit-date}}

[**View the template changes since the generation of this project**.](https://github.com/nventive/FlutterApplicationTemplate/compare/{{app-template-commit-full-sha}}..main)

## Environment and Prerequisites

### Local Development Requirements
All development is expected to be done from Visual Studio Code in a Windows or Mac environment.

- Flutter
- Visual Studio Code
  - We recommend validating your components using this [Flutter guide](https://docs.flutter.dev/get-started/install).
- For local iOS compilation and debugging, you need access to Mac with Xcode 14.2 (more recent versions may work too).

### Pipelines Requirements
The pipelines (for continuous integration, testing, and delivery) of this project are made for [Azure Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines?view=azure-devops).

#### Required Knowledge
If you're unfamiliar with Azure Pipeline, you should at least read about the following topics.
- [Key Concepts](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/key-pipelines-concepts?view=azure-devops)
- [Set a secret variable in a variable group](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/set-secret-variables?view=azure-devops&tabs=yaml%2Cbash#set-a-secret-variable-in-a-variable-group)
- [Add a secure file](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/secure-files?view=azure-devops#add-a-secure-file)

#### Required Infrastructure
- You need an Azure DevOps organization project with Pipelines enabled.
  - You can follow [this guide](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/pipelines-sign-up?view=azure-devops) for more details.
- For compilation, access to the the following [Microsoft-hosted agents](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops&tabs=yaml) is required.
  - `windows-2022`
  - `macOS-13`
- For deployment, access to Mac agents with the following capabilities is required.
  - `fastlane 2.212.1`

## Repository Content

| Folder or File | Description |
|-:|-|
`.azuredevops/` | Used to store the pull request template used by Azure DevOps.
`build/` | Regroups all yaml files used that compose the pipelines defined in `azure-pipelines.yml`.
`build/gitversion-config.yml` | Contains the configuration for the GitVersion tool that is used to compute the version number in the pipelines.
`build/azure-pipelines.yml` | Defines the main CI/CD pipeline of the project.
`doc/` | Regroups all the documentation of the project, with the only exception of `README.md`, which is located at the root of the repository.<br/><br/>**There are many topics covered. Make sure you check them out.**
`README.md` | The entry point of this project's documentation.
`src/` | Contains all the code of the application, including tests, with the exception of the configuration files located at the root of the repository.
`analysis_options.yaml` | Configure the code formatting rules and analyzers of Visual Studio Code.
`.gitignore` | Contains the git ignore rules.
`tools/` | Offers a place to put custom tools and scripts.

## Software Architecture

The software architecture of the application is documented in the [Architecture.md](doc/Architecture.md) document.
It covers things like the application context, the functional overview, the application structure, the solution structure, the recipes, and more.

## Pipelines

This project uses Azure Pipelines to automate some processes.
They are described in details in [AzurePipelines.md](doc/AzurePipelines.md).

### Pipelines Summary
TODO: Fill the following table with your own pipelines.

| Link | Code Entry Point | Goal | Triggers |
|-|-|-|-|
| [Name of Main Pipeline](link-to-pipeline)| [`build/azure-pipelines.yml`](.azure-pipelines.yml)| Build validation during pull request.| Pull requests.
| [Name of Main Pipeline](link-to-pipeline)| [`build/azure-pipelines.yml`](.azure-pipelines.yml)| Build and deploy the application to AppCenter, TestFlight, and GooglePlay. | Changes on the `main` branch.<br/>Manual trigger.

## Additional Information

TODO: Add any other relevant information. e.g. You could link to your _Definition of Done_, more documentation, UI mockups, etc.
