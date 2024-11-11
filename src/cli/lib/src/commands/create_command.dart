import 'dart:io';

import 'package:archive/archive.dart';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// {@template create_command}
///
/// `template create_command`
/// A [Command] to create a new flutter application based on our template.
/// {@endtemplate}
final class CreateCommand extends Command<int> {
  /// The logger instance.
  final Logger _logger;

  /// GitHub username or organization name.
  final _githubUsername = 'nventive';

  /// GitHub project name.
  final _githubProjectName = 'FlutterApplicationTemplate';

  /// The commit hash of the project.
  final String _commitHash = '<Sha>';

  /// The short commit hash of the project.
  final String _shortCommitHash = '<ShortSha>';

  /// The version number of the project.
  final String _versionNumber = '<MajorMinorPatch>';

  /// The commit date of the project.
  final String _commitDate = '<CommitDate>';

  ///
  /// {@macro create_command}
  ///
  CreateCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addOption(
        'destinationDirectory',
        help:
            'The destination directory path where the new Flutter project will be created.',
        valueHelp: 'C:\\P',
        defaultsTo: null,
        mandatory: true,
      )
      ..addOption(
        'projectName',
        help:
            'The name of the project that is used to create the project directory.',
        valueHelp: 'MyProjectName',
        defaultsTo: null,
        mandatory: true,
      )
      ..addOption(
        'applicationName',
        help: 'The displayed name of the application.',
        valueHelp: 'MyAppName',
        defaultsTo: null,
        mandatory: true,
      )
      ..addOption(
        'packageName',
        help: 'The package name of the application.',
        valueHelp: 'com.example.myAppName',
        defaultsTo: null,
        mandatory: true,
      )
      ..addOption(
        'organizationName',
        help:
            'The organization name (company name) of the Windows application.',
        valueHelp: 'MyOrgName',
        defaultsTo: null,
        mandatory: false,
      );
  }

  @override
  String get description =>
      "Create a new flutter application based on our template.";

  @override
  String get name => "create";

  @override
  Future<int> run() async {
    _validateArguments();

    _logger.info('Creating a new Flutter project.');

    // Extract the arguments.
    final destinationDirectory = argResults!['destinationDirectory'] as String;
    final projectName = argResults!['projectName'] as String;
    final applicationName = argResults!['applicationName'] as String;
    final packageName = argResults!['packageName'] as String;
    final organizationName = argResults!['organizationName'] as String?;

    // Download and extract the project to the destination directory.
    final extractedDirectory = await _downloadAndExtractTemplate(
      Directory(destinationDirectory),
    );

    // Rename the extracted directory to the project name.
    final destinationProjectDirectory =
        await extractedDirectory.rename('$destinationDirectory/$projectName');

    final flutterProjectDirectoryPath =
        path.join(destinationProjectDirectory.path, 'src', 'app');

    await _applyRenameConfiguration(
      flutterProjectDirectoryPath,
      destinationProjectDirectory.path,
      applicationName,
      packageName,
      organizationName,
    );

    await _deleteUnnecessaryFiles(destinationProjectDirectory.path);

    await _removeCommentedOutBlocks(
        '${destinationProjectDirectory.path}/build');

    await _updateAppReadme(
      inputPath: path.join(flutterProjectDirectoryPath, 'README.md'),
      versionNumber: _versionNumber,
      commitShortSha: _shortCommitHash,
      commitFullSha: _commitHash,
      commitDate: _commitDate,
    );

    // Delete the old README.md file.
    await File(path.join(destinationProjectDirectory.path, 'README.md'))
        .delete();

    return ExitCode.success.code;
  }

  ///
  /// Validate the arguments provided by the user.
  ///
  void _validateArguments() {
    if (argResults?['destinationDirectory'] == null) {
      throw UsageException(
        'Please provide a destination directory path.',
        usage,
      );
    }

    if (argResults?['projectName'] == null) {
      throw UsageException(
        'Please provide a project name.',
        usage,
      );
    }

    if (argResults?['applicationName'] == null) {
      throw UsageException(
        'Please provide an application name.',
        usage,
      );
    }

    if (argResults?['packageName'] == null) {
      throw UsageException(
        'Please provide a package name.',
        usage,
      );
    }
  }

  ///
  /// Downloads Flutter Application Template source code based on its commit hash and extracts it to a specified directory.
  ///
  /// The downloaded file is deleted after the Flutter project is created.
  ///
  /// Returns the extracted directory.
  ///
  Future<Directory> _downloadAndExtractTemplate(
    Directory extractDirectory,
  ) async {
    /// URL of the GitHub API endpoint for downloading a tarball of the project
    final url =
        'https://api.github.com/repos/$_githubUsername/$_githubProjectName/tarball/$_commitHash';

    /// Send a GET request to the GitHub API
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      /// File to store the downloaded zip file
      final zipFile =
          File(path.join(Directory.systemTemp.path, '$_commitHash.tar.gz'));

      /// Write the response bytes to the zip file
      await zipFile.writeAsBytes(response.bodyBytes);

      /// Read the bytes from the zip file
      final bytes = await zipFile.readAsBytes();

      /// Decode the gzipped tarball
      final archive =
          TarDecoder().decodeBytes(GZipDecoder().decodeBytes(bytes));

      /// Extract the project to the extract directory
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          /// Create a new file in the extract directory and write its contents
          final outputFile = File(path.join(extractDirectory.path, filename));
          await outputFile.create(recursive: true);
          await outputFile.writeAsBytes(file.content as List<int>);
        } else {
          /// Create a new directory in the extract directory
          await Directory(path.join(extractDirectory.path, filename))
              .create(recursive: true);
        }
      }

      // Delete the zip file after extraction.
      await zipFile.delete();

      _logger.info(
          'GitHub project downloaded and extracted to ${extractDirectory.path}.');

      return Directory(
        path.join(
          extractDirectory.path,
          '$_githubUsername-$_githubProjectName-$_shortCommitHash',
        ),
      );
    } else {
      _logger.err(
          'Failed to download GitHub project. Status code: ${response.statusCode}.');
      throw Exception('Failed to download GitHub project.');
    }
  }

  ///
  /// Applies the rename configuration of the Flutter project.
  ///
  Future<void> _applyRenameConfiguration(
    String flutterProjectDirectoryPath,
    String destinationProjectDirectoryPath,
    String applicationName,
    String packageName,
    String? organizationName,
  ) async {
    // Navigate to the Flutter project folder in the destination directory to run specific commands.
    Directory.current = flutterProjectDirectoryPath;

    // Load the content of the YAML file.
    var renameConfigurationFile = File('package_rename_config.yaml');
    var fileContent = await renameConfigurationFile.readAsLines();

    // Store the modified lines in a list.
    final newContent = <String>[];

    // Iterate through each line of the file content.
    for (var line in fileContent) {
      if (line.contains('app_name:')) {
        line = _updateYamlLine(line, applicationName);
      } else if (line.contains('package_name:')) {
        line = _updateYamlLine(line, packageName);
      } else if (line.contains('bundle_name:')) {
        line = _updateYamlLine(line, applicationName);
      } else if (line.contains('exe_name:')) {
        line = _updateYamlLine(line, applicationName);
      } else if (line.contains('organization:')) {
        line = _updateYamlLine(line, organizationName ?? applicationName);
      }

      // Add the original/modified line to the new content list.
      newContent.add(line);
    }

    // Save the updated content back to the YAML file.
    renameConfigurationFile =
        await renameConfigurationFile.writeAsString(newContent.join('\n'));

    // Apply new configuration.
    // await Process.run('flutter', ['pub', 'get'], runInShell: true);
    await Process.run('dart', ['run', 'package_rename'], runInShell: true);

    // Load the content of the YAML file.
    fileContent = await renameConfigurationFile.readAsLines();

    // Store the modified lines in a list.
    newContent.clear();

    // Iterate through each line of the file content.
    for (var line in fileContent) {
      // In case the user want's to change the configuration later.
      if (line.contains('override_old_package')) {
        line = _updateYamlLine(line, packageName);
      }

      // Add the original/modified line to the new content list.
      newContent.add(line);
    }

    // Save the updated content back to the YAML file.
    renameConfigurationFile =
        await renameConfigurationFile.writeAsString(newContent.join('\n'));

    // Navigate back to the root directory.
    Directory.current = destinationProjectDirectoryPath;
  }

  ///
  /// Delete unnecessary files and directories from the project.
  ///
  Future<void> _deleteUnnecessaryFiles(
    String destinationProjectDirectoryPath,
  ) async {
    await Directory(
      path.join(destinationProjectDirectoryPath, '.github'),
    ).delete(recursive: true);

    await Directory(
      path.join(destinationProjectDirectoryPath, 'src', 'cli'),
    ).delete(recursive: true);

    await File(
      path.join(destinationProjectDirectoryPath, '.mergify.yml'),
    ).delete();

    await File(
      path.join(destinationProjectDirectoryPath, 'CODE_OF_CONDUCT.md'),
    ).delete();

    await File(
      path.join(destinationProjectDirectoryPath, 'CONTRIBUTING.md'),
    ).delete();

    await File(
      path.join(destinationProjectDirectoryPath, 'LICENSE'),
    ).delete();
  }

  ///
  /// Update the value of a YAML line.
  ///
  String _updateYamlLine(String value, String newValue) {
    final splitLines = value.split(':');
    final originalValue = splitLines[1].trim();
    return value.replaceAll(originalValue, newValue);
  }

  ///
  /// Remove commented-out blocks from the specified folder.
  ///
  Future<void> _removeCommentedOutBlocks(String folderPath) async {
    final directory = Directory(folderPath);
    final directoryExists = await directory.exists();

    if (!directoryExists) {
      _logger.err('The specified folder does not exist.');
      return;
    }

    // Regex pattern to match the comment blocks.
    final pattern = RegExp(
      r'#-if false.*?#-endif',
      dotAll: true,
      multiLine: true,
    );

    // Function to process each file.
    Future<void> processFile(File file) async {
      // Read the content of the file.
      final content = await file.readAsString();

      // Remove the comment blocks.
      final modifiedContent = content.replaceAll(pattern, '');

      // Write the modified content back to the file.
      await file.writeAsString(modifiedContent);
    }

    // Recursive function to process files in the directory and its subdirectories.
    Future<void> processDirectory(Directory dir) async {
      await dir.list(recursive: false).forEach((final entity) async {
        if (entity is File) {
          await processFile(entity);
        } else if (entity is Directory) {
          await processDirectory(entity);
        }
      });
    }

    // Start processing from the root directory.
    await processDirectory(directory);

    _logger.info('Commented-out blocks removed successfully.');
  }

  ///
  /// Takes the APP_README.md file with the correct version number and commit information.
  ///
  Future<void> _updateAppReadme({
    required String inputPath,
    String? outputPath,
    required String versionNumber,
    required String commitShortSha,
    required String commitFullSha,
    required String commitDate,
  }) async {
    // If outputPath is not provided, use inputPath as outputPath.
    outputPath ??= inputPath;

    // Read the content of the input file.
    final content = await File(inputPath).readAsString();

    // Replace placeholders with the provided values.
    var modifiedContent =
        content.replaceAll('{{app-template-version}}', versionNumber);
    modifiedContent = modifiedContent.replaceAll(
        '{{app-template-commit-short-sha}}', commitShortSha);
    modifiedContent = modifiedContent.replaceAll(
        '{{app-template-commit-full-sha}}', commitFullSha);
    modifiedContent =
        modifiedContent.replaceAll('{{app-template-commit-date}}', commitDate);

    // Write the modified content to the output file.
    await File(outputPath).writeAsString(modifiedContent);

    _logger.info('APP_README.md generated successfully.');
  }
}
