# CLI

This Dart application is a command line interface (CLI) designed to create Flutter projects based on a template.
The repository comprises two main sections, the CLI (`src/cli`) and the Flutter application (`src/app`).
When generating a new project, the CLI downloads the GitHub repository to get the latest files.
Because the template files are downloaded, you need internet when creating a new project.

## Special Files and Folders

There are several manipulations on the files of the template when packaging it and running it.
Most files are copied as-is and modified by the renaming phase, but that's not true for everything.

### Template files

When running the template, the `src/cli/` folder is discarded.

### GitHub files

When running the template, everything related to GitHub is discarded.
- The `.github/` folder
- `CODE_OF_CONDUCT.md`
- `CONTRIBUTING.md`
- `LICENSE`
- `.mergify.yml`

### READMEs

When packaging this template, the `README.md` (which describes the template) is moved to `cli` folder.
- `README.md` --> `src/cli/README.md`

When generating a new project from the template, the application `README.md` is updated with versioning information.

## Pipeline conditionals

The pipelines use some special conditionals.
The `.azure-pipelines.yml` has additional stages that are removed when running the template.
These conditions use the `#-if false` syntax and are configured in `lib/src/commands/create_command.dart`.

## GitVersion

For the template itself, we use the **MainLine** mode for GitVersion. This is the same mode as most of our open source packages.
The configuration is located at `src/cli/.azuredevops/gitversion-config.yml`.
For the generated app, we use the **ContinuousDeployment** mode for GitVersion.
The configuration is located at `build/gitversion-config.yml`.

## References
- [Creating custom templates](https://docs.microsoft.com/en-us/dotnet/core/tools/custom-templates)
- [Properties of template.json](https://github.com/dotnet/templating/wiki/Reference-for-template.json)
- [Comment syntax](https://github.com/dotnet/templating/wiki/Reference-for-comment-syntax)
- [Supported files](https://github.com/dotnet/templating/blob/5b5eb6278bd745149a57d0882d655b29d02c70f4/src/Microsoft.TemplateEngine.Orchestrator.RunnableProjects/SimpleConfigModel.cs#L387)
