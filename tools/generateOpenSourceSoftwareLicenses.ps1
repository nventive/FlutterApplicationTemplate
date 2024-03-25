<#
.SYNOPSIS
    This script generates the open-source software licenses for the Flutter project.

.DESCRIPTION
    This script generates the open-source software licenses for the Flutter project using the 'flutter_oss_licenses' package.
    The 'flutter_oss_licenses' will be activated, the licenses will be generated, and then the package will be deactivated.
    See https://pub.dev/packages/flutter_oss_licenses for more details.

.PARAMETER pubspecDirectoryPath
    (Required) The Flutter project root directory path where 'pubspec.lock' is located.

.PARAMETER outputPath
    (Required) The output destination path where the JSON file will be created (Path includes the file name).

.EXAMPLE
    .\generateOpenSourceSoftwareLicenses.ps1 C:\P\FlutterApplicationTemplate\src\app C:\P\FlutterApplicationTemplate\src\app\assets\openSourceSoftwareLicenses.json
    This will create a new license file called 'openSourceSoftwareLicenses.json' in 'C:\P\FlutterApplicationTemplate\src\app\assets' based on 'C:\P\FlutterApplicationTemplate\src\app\pubspec.lock'.
#>

param (
    [string]$pubspecDirectoryPath = $(throw "Please provide a 'pubspec.lock' directory path."),
    [string]$outputPath = $(throw "Please provide an output path.")
)

dart pub global activate flutter_oss_licenses

flutter pub get --directory $pubspecDirectoryPath

generate --output $outputPath --project-root $pubspecDirectoryPath --json

dart pub global deactivate flutter_oss_licenses
