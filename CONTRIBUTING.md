

# Contributing to FlutterApplicationTemplate

Thank you for considering contributing to **FlutterApplicationTemplate**! 🚀
This document explains how to get involved, report issues, suggest improvements, or contribute code to the project.

---

## Table of Contents

* [Code of Conduct](#code-of-conduct)
* [Getting Started](#getting-started)
* [How to Contribute](#how-to-contribute)

  * [Bug Reports](#bug-reports)
  * [Feature Requests](#feature-requests)
  * [Code Contributions](#code-contributions)
* [Development Guide](#development-guide)
* [Pull Request Process](#pull-request-process)
* [Style Guide](#style-guide)
* [License](#license)

---

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](./CODE_OF_CONDUCT.md). Please read it carefully and help us maintain a welcoming and respectful community.

---

## Getting Started

To run the project locally, follow the instructions in the [README.md](./README.md). Make sure you:

* Have Flutter and Dart installed.
* Run `flutter doctor -v` to verify your setup.

---

## How to Contribute

We welcome all kinds of contributions!

### Bug Reports

If you find a bug, please:

1. Check the [open issues](https://github.com/nventive/FlutterApplicationTemplate/issues) to see if it’s already reported.
2. If not, [open a new issue](https://github.com/nventive/FlutterApplicationTemplate/issues/new) with:

   * A clear title
   * Steps to reproduce the issue
   * Expected vs. actual behavior
   * Screenshots/logs (if applicable)
   * Flutter and Dart versions (output of `flutter doctor -v`)

### Feature Requests

We welcome ideas for new features! Please include:

* A use case or problem you’re solving
* A proposed solution or approach
* Any alternatives you’ve considered

### Code Contributions

If you want to contribute code:

1. **Fork the repository**
2. **Create a feature branch**:

   ```bash
   git checkout -b feature/my-new-feature
   ```
3. **Make your changes** and test them locally
4. **Commit your changes**
   Use conventional commit messages (e.g. `feat: add support for custom themes`)
5. **Push to your fork**
6. **Open a pull request** targeting the `main` branch
   Describe your changes clearly and reference any related issues

---

## Development Guide

### Application (App)

```bash
cd src/app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### CLI Tool

```bash
cd src/cli
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Manually update values in `src/cli/lib/src/commands/create_command.dart`:

* `_commitHash`
* `_shortCommitHash`
* `_versionNumber` (e.g. `2.4.1`)
* `_commitDate` (any string format, e.g. `2025-06-01`)

To activate the CLI locally:

```bash
dart pub global activate --source=path {Full Path}/src/cli
```

Use `--overwrite` if already activated.

---

## Pull Request Process

* Submit pull requests to the `main` branch.
* Ensure all changes are tested and formatted.
* Update documentation if needed.
* At least one maintainer must approve before merging.

---

## Style Guide

* Format code using `flutter format .`
* Follow Dart and Flutter conventions.
* Use null safety consistently.
* Add unit or widget tests when applicable.

---

## License

By contributing, you agree that your contributions will be licensed under the [Apache 2.0 License](./LICENSE).

---
Happy coding! 💙