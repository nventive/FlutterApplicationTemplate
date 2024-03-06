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

# Main script.
try {
    Write-Host "Welcome to the Flutter Application Template copy tool!" -ForegroundColor Green

    # Get source directory.
    if (-not $sourceDir) {
        $sourceProjectDir = GetUserInput "Enter the source directory path:"
    }

    # Check if source directory exists.
    if (-not (Test-Path $sourceProjectDir)) {
        WriteAndPause -message "Source directory does not exist. Please provide a valid directory." -foregroundColor Red
        exit
    }

    # Get destination directory.
    if (-not $sourceDir) {
        $destDir = GetUserInput "Enter the destination directory path:"
    }

    # Check if destination directory exists.
    if (-not (Test-Path $destDir)) {
        WriteAndPause -message "Destination directory does not exist. Please provide a valid directory." -foregroundColor Red
        exit
    }

    # Get project name.
    $projectName = GetUserInput "Enter the name of the Flutter project:"

    # TODO: Prompt user for values of 'package_rename_config.yaml' file.

    # Construct destination path.
    $destProjectDir = Join-Path -Path $destDir -ChildPath $projectName

    Write-Host $destProjectDir

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

    Set-Location Join-Path -Path $destProjectDir -ChildPath "src\app"

    # TODO: Update 'package_rename_config.yaml' file.
    # TODO: Run 'flutter pub get' command.
    # TODO: Run 'dart run package_rename' command.
    # TODO: Update 'override_old_package' in 'package_rename_config.yaml' file.

    WriteAndPause -message "Flutter project '$projectName' has been successfully copied to the destination directory." -foregroundColor Green
}
catch {
    WriteAndPause -message "An error occurred." -foregroundColor Red
    exit
}
