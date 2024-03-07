<#
.SYNOPSIS
    This script create custom Flutter application from a template.

.DESCRIPTION
    The script copies the Flutter project from the source directory to the destination directory.
    It then updates the 'package_rename_config.yaml' file with the new application name, package name and other parameters.
    The script also runs the 'package_rename' command to apply the updated configuration.
    The script also renames the 'APP_README.md' file to 'README.md' and deletes the template 'README.md' file.

.PARAMETER sourceProjectDir
    (Required) The source directory path where the Flutter Application Template repository is located.

.PARAMETER destDir
    (Required) The destination directory path where the new Flutter project will be created.

.PARAMETER projectName
    (Required) The name of the project that is used to create the project directory.

.PARAMETER appName
    (Required) The displayed name of the application.

.PARAMETER packageName
    (Required) The package name of the application.

.PARAMETER organization
    (Optional) The organization name (company name) of the Windows application.

.EXAMPLE
    .\copyApplicationTemplate.ps1 -sourceProjectDir C:\P\FlutterApplicationTemplate -destDir C:\P -projectName MyProjectName -appName MyAppName -packageName com.example.myAppName -organization MyOrg
    This will create a new Flutter project in the 'C:\P' directory with the specified parameters.
#>

param (
    [string]$sourceProjectDir = $(throw "Please provide a source directory path."),
    [string]$destDir = $(throw "Please provide a destination directory path."),
    [string]$projectName = $(throw "Please provide a project name."),
    [string]$appName = $(throw "Please provide an app name."),
    [string]$packageName = $(throw "Please provide a package name."),
    [string]$organization = $null
)

# Function to prompt user for input.
function GetUserInput {
    param (
        [string]$message
    )

    Write-Host $message -ForegroundColor Cyan
    return Read-Host
}

# Function to write a message and pause the script.
function WriteAndPause {
    param (
        [string]$message,
        [System.ConsoleColor]$foregroundColor
    )
    Write-Host $message -ForegroundColor $foregroundColor
    cmd /c "pause"
}

# Function used to update a line in a YAML file.
function UpdateYamlLine {
    param (
        [string]$line,
        [string]$newValue
    )
    # Split the line into key and value parts
    $splitLines = $line -split ":|#", 3

    # Get the original value part.
    $originalValue = $splitLines[1].Trim()

    # Replace the original value with the new value.
    $newLine = $line -replace "$originalValue", "$newValue"

    return $newLine
}

# Main script.
try {
    Write-Host "Welcome to the Flutter Application Template copy tool!" -ForegroundColor Green

    # Check if source directory exists.
    if (-not (Test-Path $sourceProjectDir)) {
        WriteAndPause -message "Source directory does not exist. Please provide a valid directory." -foregroundColor Red
        exit
    }

    # Check if destination directory exists.
    if (-not (Test-Path $destDir)) {
        WriteAndPause -message "Destination directory does not exist. Please provide a valid directory." -foregroundColor Red
        exit
    }

    # Construct destination path.
    $destProjectDir = Join-Path -Path $destDir -ChildPath $projectName

    # Check if project exists in source directory.
    if (-not (Test-Path $sourceProjectDir -PathType Container)) {
        WriteAndPause -message "The specified Flutter project directory does not exist." -foregroundColor Red
        exit
    }

    # Check if project already exists in destination directory.
    if (Test-Path $destProjectDir -PathType Container) {
        Write-Host "A project with the same name already exists in the destination directory." -ForegroundColor Yellow
        $confirm = GetUserInput "Do you want to overwrite it? (Y/N)"
        if ($confirm -ne "Y") {
            WriteAndPause -message "Operation canceled." -foregroundColor Yellow
            exit
        }
        else {
            Remove-Item -Path $destProjectDir -Recurse -Force
        }
    }

    # Copy the project to the destination directory.
    Copy-Item -Path $sourceProjectDir -Destination $destProjectDir -Recurse

    # Navigate to the Flutter project folder in the destination directory to run specific commands.
    $flutterProjectDir = Join-Path -Path $destProjectDir -ChildPath "src\app"
    Set-Location $flutterProjectDir

    $renameConfigFileName = "package_rename_config.yaml"

    # Load the content of the YAML file.
    $fileContent = Get-Content -Path $renameConfigFileName
    
    # Store the modified lines in an array.
    $newContent = @()

    # Iterate through each line of the file content.
    foreach ($line in $fileContent) {
        # Value to put inside the YAML line.
        $newValue = $null

        # Check if the line contains one of the keys you want to update.
        switch -Regex ($line) {
            ("app_name:") {
                $newValue = $appName
            }
            ("package_name:") {
                $newValue = $packageName
            }
            ("bundle_name:") {
                $newValue = $appName
            }
            ("exe_name:") {
                $newValue = $appName
            }
            ("organization:") {
                $newValue = $organization
            }
            default {
                $newLine = $line
            }
        }
        # Update the line with the new value.
        if ($null -ne $newValue) {
            $newLine = UpdateYamlLine -line $line -newValue $newValue
        }

        # Add the original/modified line to the new content array.
        $newContent += $newLine
    }

    # Save the updated content back to the YAML file.
    Set-Content -Path $renameConfigFileName -Value $newContent

    Invoke-Expression "flutter pub get"
    Invoke-Expression "dart run package_rename"

    # Load the content of the YAML file.
    $fileContent = Get-Content -Path $renameConfigFileName

    # Store the modified lines in an array.
    $newContent = @()

    # Iterate through each line of the file content.
    foreach ($line in $fileContent) {
        if ($line -like "*override_old_package*") {
            # Update the line with the new value.
            $newLine = UpdateYamlLine -line $line -newValue $packageName
        } else {
            $newLine = $line
        }

        # Add the original/modified line to the new content array.
        $newContent += $newLine
    }

    # Save the updated content back to the YAML file.
    Set-Content -Path $renameConfigFileName -Value $newContent

    # Navigate back to the root directory.
    Set-Location "..\.."

    # Delete the template 'README.md' file.
    Remove-Item "README.md"

    # Rename the 'APP_README.md' file to 'README.md'.
    Rename-Item -Path "APP_README.md" -NewName "README.md"

    WriteAndPause -message "Flutter project '$projectName' has been successfully copied to the destination directory." -foregroundColor Green
}
catch {
    WriteAndPause -message "An error occurred." -foregroundColor Red
    exit
}
