# Specify the base directory where you want to check for the directory
$baseDirectory = "C:\xampp\htdocs"

# Get the client's domain from the user
$clientDomain = Read-Host "Enter the client's domain (e.g., example.com)"

# Ensure the client's domain is not empty
if ([string]::IsNullOrEmpty($clientDomain)) {
    Write-Host "Client's domain cannot be empty. Exiting."
    exit
}

# Define the full path to the directory
$directoryPath = Join-Path -Path $baseDirectory -ChildPath $clientDomain

# Check if the directory exists
if (Test-Path -Path $directoryPath -PathType Container) {
    # The directory exists, so prompt the user
    $choice = Read-Host "Directory '$clientDomain' already exists. Do you want to rename it to '$clientDomain-old'? (Y/N)"

    if ($choice -eq "Y" -or $choice -eq "y") {
        # Rename the existing directory to add "-old"
        $newDirectoryPath = Join-Path -Path $baseDirectory -ChildPath "$clientDomain-old"
        Rename-Item -Path $directoryPath -NewName $newDirectoryPath
        Write-Host "Directory in $baseDirectory renamed to '$clientDomain-old'."
    } else {
        Write-Host "No changes were made. Exiting..."
        exit
    }
} else {
    Write-Host "Directory '$clientDomain' is avalible in '$baseDirectory'. script continuing..."
}

# Define the download URL for the latest WordPress core
$wordpressDownloadUrl = "http://wordpress.org/latest.zip"

# Download the latest WordPress core zip file
Invoke-WebRequest -Uri $wordpressDownloadUrl -OutFile "$PSScriptRoot\latest.zip"

# Extract the zip file to the destination folder
Expand-Archive -Path "$PSScriptRoot\latest.zip" -DestinationPath $PSScriptRoot

# Rename the extracted folder to the client's domain
Rename-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath "wordpress") -NewName $clientDomain

# Clean up the downloaded zip file
Remove-Item -Path "$PSScriptRoot\latest.zip"

Write-Host "WordPress has been downloaded and extracted to the folder: $clientDomain"

$sourceFile = "$clientDomain/wp-config-sample.php"  # Replace with the path to your source file
$destinationFolder = "$clientDomain"    # Replace with the path to your "site-folder"

# The new name for the copied file
$newFileName = "wp-config.php"

# Combine the destination folder path with the new filename
$destinationPath = Join-Path -Path $destinationFolder -ChildPath $newFileName

try {
    # Copy the source file to the destination folder with the new name
    Copy-Item -Path $sourceFile -Destination $destinationPath
    Write-Host "File copied to $destinationPath"
} catch {
    Write-Host "An error occurred: $_"
}
























# MOVE FOLDER THAT WAS JUST CREATED TO HTDOCS - IT WORKS - DON'T UNCOMMENT UNTIL ALLLLLLL OTHER WORDPRESS EDITS ARE DONE AND FOLDER IS READY TO SHIP


# # Specify the full path to the directory to be moved
# $directoryToMove = Join-Path -Path $PSScriptRoot -ChildPath $clientDomain

# # Check if the directory exists in the current root directory
# if (Test-Path -Path $directoryToMove -PathType Container) {
#     # Specify the target directory where you want to move the folder
#     $targetDirectory = Join-Path -Path $baseDirectory -ChildPath $clientDomain

#     # Move the folder to the target directory
#     Move-Item -Path $directoryToMove -Destination $targetDirectory -Force

#     Write-Host "Folder '$clientDomain' has been moved to '$targetDirectory'."
# } else {
#     Write-Host "Folder '$clientDomain' does not exist in the current root directory. No changes were made."
# }