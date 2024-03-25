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

    if ($env:OS -like "*Windows*") {
        cmd /c "pause"
    } else {
        Read-Host "Press any key to continue..."
    }
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

# Function to update the 'README.md' file content.
function UpdateAppReadMe {
    $gitVersionOutput = $null

    # Run GitVersion and capture the output.
    if ($env:OS -like "*Windows*") {
        $gitVersionOutput = dotnet-gitversion /output json
    } else {
        $gitVersionOutput = gitversion /output json
    }

    # Parse the JSON output.
    $gitVersionJson = $gitVersionOutput | ConvertFrom-Json

    # Extract information from the JSON output.
    $majorMinorPatch = $gitVersionJson.MajorMinorPatch
    $commitShortSha = $gitVersionJson.ShortSha
    $commitFullSha = $gitVersionJson.Sha
    $commitDate = $gitVersionJson.CommitDate

    # Update the 'README.md' file content by executing a local script.
    & "$PSScriptRoot\generateAppReadme.ps1" -InputPath README.md -VersionNumber $majorMinorPatch -CommitShortSha $commitShortSha -CommitFullSha $commitFullSha -CommitDate $commitDate

    Write-Host "Application README updated successfully." -ForegroundColor Green
}

# Function to remove commented-out blocks from the specified folder and its subfolders.
function RemoveCommentedOutBlocks {
    param(
        [string]$folderPath
    )

    # Get all files in the specified folder and its subfolders.
    $files = Get-ChildItem -Path $FolderPath -Recurse -File

    # Iterate through each file.
    foreach ($file in $files) {
        # Read the content of the file.
        $content = Get-Content -Path $file.FullName -Raw

        # Define regex pattern to match the comment blocks.
        $pattern = '(?s)#-if false.*?#-endif'

        # Remove the comment blocks.
        $content = $content -replace $pattern, ''

        # Remove empty lines.
        $content = $content -replace '^\s*$', ''

        # Write the modified content back to the file.
        Set-Content -Path $file.FullName -Value $content
    }

    Write-Host "Commented-out blocks removed successfully." -ForegroundColor Green
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

        if ($line -like "*package_rename_config-production:*") {
            break
        }

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
        if ($line -like "*package_rename_config-production:*") {
            break
        }
        elseif ($line -like "*override_old_package*") {
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

    # Delete the copy tool stage file.
    Remove-Item ".\build\stage-copytool.yaml"

    # Delete template tools.
    Remove-Item ".\tools\generateAppReadme.ps1"
    Remove-Item ".\tools\copyApplicationTemplate.ps1"

    # Rename the 'APP_README.md' file to 'README.md'.
    Rename-Item -Path "APP_README.md" -NewName "README.md"

    # Update the 'README.md' file content.
    UpdateAppReadMe

    # Remove commented-out blocks from the project.
    RemoveCommentedOutBlocks -FolderPath "build"

    # Display success message.
    WriteAndPause -message "Flutter project '$projectName' has been successfully copied to the destination directory." -foregroundColor Green
}
catch {
    WriteAndPause -message "An error occurred: $_." -foregroundColor Red
    exit
}
