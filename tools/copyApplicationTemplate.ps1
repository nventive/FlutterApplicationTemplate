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

    WriteAndPause -message "Flutter project '$projectName' has been successfully copied to the destination directory." -foregroundColor Green
}
catch {
    WriteAndPause -message "An error occurred." -foregroundColor Red
    exit
}
