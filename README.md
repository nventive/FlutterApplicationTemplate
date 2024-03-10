# Flutter Application Template

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat-square)](LICENSE) ![Version](https://img.shields.io/nuget/v/NV.Templates.Mobile?style=flat-square) ![Downloads](https://img.shields.io/nuget/dt/NV.Templates.Mobile?style=flat-square)

This is a mobile app project template using [Flutter](https://github.com/flutter) and the latest Flutter/Dart practices.

- TODO (Pattern used if applicable).
- Code is organized by [application layer](doc/Architecture.md#Solution-Structure).
- It comes with [dependency injection](doc/DependencyInjection.md).
- There are built-in [logs](doc/Logging.md) and [diagnostic tools](doc/Diagnostics.md).
- There is scaffolding code showing sample features.
  When you run as-is, you get a _Dad Jokes_ application.

## Preview
TODO.

### Diagnostic Tools
TODO.

## Requirements

Visual Studio Code with Flutter are required.

This template largely relies on Flutter, if you want to make sure you got everything installed correctly on your machine, we encourage you to use `flutter doctor -v`, the documentation is available [here](https://docs.flutter.dev/)

## Getting Started

We use a custom PowerShell script and a Dart package to easily create new projects. It simplifies the **project renaming**.

### Generate a new project

1. Make sure you cloned the latest version of this repository.

2. Make sure you have PowerShell installed.

   > 💡 For Windows, you can run `powershell` to verify. You can install it with the command `winget install --id Microsoft.Powershell --source winget`.
   > 💡 For Mac, you can run `pwsh` to verify. You can install it with Homebrew `brew install powershell/tap/powershell`.

3. Make sure you have GitVersion installed.

   > 💡 For Windows, you can run `dotnet-gitversion` to verify. You can install it with the command `dotnet tool install --global GitVersion.Tool`.
   > 💡 For Mac, you can run `gitversion` to verify. You can install it with Homebrew `brew install gitversion`.

4. To run the script and create a new project, run the following command in the cloned `FlutterApplicationTemplate` repository.

   `powershell -File ".\tools\copyApplicationTemplate.ps1" -sourceProjectDir C:\P\FlutterApplicationTemplate -destDir C:\P -projectName MyProjectName -appName MyAppName -packageName com.example.myAppName -organization MyOrg`

   > 💡 The organization parameter is optional (Only used for the Windows platform).

   The following options are available when running the command.

   - To get help: `Get-Help .\tools\copyApplicationTemplate.ps1`

### Next Steps

1. Open the `README.md` and complete the documentation TODOs.
2. Open the directory with Visual Studio Code.
3. In Visual Studio Code, go to the **VIEW** menu and open the **Problems** to get hints on next steps.
   
   This template comes with several pointers on what you're most likely to change next.
   
   ![](doc/images/VisualStudioTaskListForNextSteps.PNG)

## Architecture and Recipes
This repository provides documentation on different topics under the [doc](doc/) folder.

### Architecture

The software architecture of the application is documented in the [Architecture](doc/Architecture.md) document.

### Summary of Recipes
| Topic | Recipe/Implementation |
|-|-|
UI Framework | [Flutter](https://flutter.dev/)
[State Management](doc/Architecture.md#mvvm---viewmodels) | TODO.
[Dependency Injection](doc/DependencyInjection.md) | [get_it](https://pub.dev/packages/get_it)
[Configuration](doc/Configuration.md) | TODO.
[Runtime Environments](doc/Environments.md) | TODO.
Design System | [Material Design for Flutter](https://docs.flutter.dev/ui/design/material)<br/>[Material Design](https://m3.material.io/)
[HTTP](doc/HTTP.md) | [dio](https://pub.dev/packages/dio)<br/>[retrofit](https://pub.dev/packages/retrofit)
[Logging](doc/Logging.md) | [logger](https://pub.dev/packages/logger)
[Testing](doc/Testing.md) | TODO.
[Serialization](doc/Serialization.md) | TODO.
[Localization](doc/Localization.md) | [flutter_localization](https://pub.dev/packages/flutter_localization)
[Navigation](doc/Architecture.md#navigation) | TODO.
[Validation](doc/Validation.md) | TODO.
[App Reviews](doc/Reviews.md) | TODO.

## Changelog

Please consult the [CHANGELOG](CHANGELOG.md) for more information about the version history.

## License

This project is licensed under the Apache 2.0 license. See the [LICENSE](LICENSE) for details.

## Contributing

Please read [CONTRIBUTING](CONTRIBUTING.md) for details on the process for contributing to this project.

Be mindful of our [Code of Conduct](CODE_OF_CONDUCT.md).
