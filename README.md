# Flutter Application Template

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat-square)](LICENSE)

This is a mobile app project template using [Flutter](https://github.com/flutter) and the latest Flutter/Dart practices.

## Requirements

Visual Studio Code with Flutter are required.

This template largely relies on Flutter, if you want to make sure you got everything installed correctly on your machine, we encourage you to use `flutter doctor -v`, the documentation is available [here](https://docs.flutter.dev/)

## Getting Started

We use a Dart CLI application to easily create new projects.

### Generate a new project

1. Install the CLI using this command.

   `dart pub global activate flutter_application_generator`

2. Create a new project using this command.

    `flutter_application_generator create --destinationDirectory C:\P --projectName MyProjectName --applicationName MyAppName --packageName com.example.myAppName --organizationName MyOrg`

   > 💡 The organization parameter is optional (Only used for the Windows platform).

   > 💡 You'll need internet access to create new projects.

   The following options are available when running the command.

   - To get help: `flutter_application_generator --help`

   - To show version: `flutter_application_generator --version`

### Next Steps

1. Open the `README.md` and complete the documentation TODOs.
2. Open the directory with Visual Studio Code.

## Changelog

Please consult the [CHANGELOG](CHANGELOG.md) for more information about the version history.

## License

This project is licensed under the Apache 2.0 license. See the [LICENSE](LICENSE) for details.

## Contributing

Please read [CONTRIBUTING](CONTRIBUTING.md) for details on the process for contributing to this project.

Be mindful of our [Code of Conduct](CODE_OF_CONDUCT.md).

### Application Template

To debug the app from within the template, run the following commands:
1. Go to the Flutter app directory.
   ```ps
   cd src/app
   ```
1. Restore the packages.
   ```ps
   flutter pub get
   ```
1. Run the code generators.
   ```ps
   dart run build_runner build --delete-conflicting-outputs
   ```
1. Build and run the application.
   ```ps
   flutter run
   ```

### Command Line Interface

To debug the CLI, do the following:

1. Go to the CLI directory.
   ```ps
   cd src/cli
   ```
1. Restore the packages.
   ```ps
   flutter pub get
   ```
1. Run the code generators.
   ```ps
   dart run build_runner build --delete-conflicting-outputs
   ```
1. Set the variables value in `src/cli/lib/src/commands/create_command.dart` that would normally be done by the Pipeline
   - `_commitHash`
   - `_shortCommitHash`
   - `_versionNumber`
   - `_commitDate`
   > 💡 You have to set real values, you should probably use the latest commit information or your own commit from your branch.
   > 💡 If you click [here](https://github.com/nventive/FlutterApplicationTemplate/commit/d3391444b8e2503e7c7bf27c12b6283062aa0a1c), you have the commit hash in the URL, and the short one is displayed at the top right of the page `commit d339144`.
   > 💡 The date can be any string of any format, it's just displayed, e.g. `2025-02-06`.
   > 💡 The version number should be {Major.Minor.Patch}, e.g. `2.4.1`.
1. Move the `README.md` into `src/cli` folder
1. `dart pub global activate --source=path {Full Path}/src/cli`
   > 💡 If you already have the CLI installed, you can use the `--overwrite` flag, but don't forget to reinstall it properly when you are done using `dart pub global activate flutter_application_generator --overwrite`.
