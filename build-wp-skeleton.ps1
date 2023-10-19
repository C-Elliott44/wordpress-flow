# Specify the base directory where you want to check for the directory
$baseDirectory = "C:\xampp\htdocs"

# Get the client's domain and password from the user
$clientDomain = Read-Host "Enter the client's domain (e.g., example.com)"
$clientPassword = Read-Host "Enter the client's password (e.g., wxa.kgj4mgw2MYB4zhg)"
$clientPrefix = Read-Host "Enter the client's DB Prefix (e.g., dh_)"

# Ensure the client's domain is not empty
if ([string]::IsNullOrEmpty($clientDomain)) {
    Write-Host "Client's domain cannot be empty. Exiting."
    exit
}

# Ensure the client's password is not empty
if ([string]::IsNullOrEmpty($clientPassword)) {
    Write-Host "Client's password cannot be empty. Exiting."
    exit
}

# Ensure the client's prefix is not empty
if ([string]::IsNullOrEmpty($clientPrefix)) {
    Write-Host "Client's prefix cannot be empty. Exiting."
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

# Remove everything from the period to the end
$clientDomainNoExtention = $clientDomain -replace '\..*$', ''

# Set concatinate config.php values
$database = $clientDomainNoExtention + "_main"
$username = $clientDomainNoExtention + "_admin"

# Define the file path
$filePath = "$PSScriptRoot\$clientDomain\wp-config.php"

# Read the content of the file into a variable
$content = Get-Content -Path $filePath -Raw

# Define the URL
$saltUrl = "https://api.wordpress.org/secret-key/1.1/salt/"

# Use Invoke-RestMethod to retrieve the content from the saltURL
$newSalts = Invoke-RestMethod -Uri $saltUrl

# Set the old salts to be found and replaced
$oldSalts = @"
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );
"@

# Define an array of replacement patterns and corresponding new text
$replacements = @(
    @("database_name_here", $database),
    @("username_here", $username),
    @("password_here", $clientPassword),
    @("'wp_'", "'$clientPrefix'"),
    @($oldSalts, $newSalts)
)

# Loop through each replacement pattern and update the content
foreach ($replacement in $replacements) {
    $oldText, $newText = $replacement
    $content = $content -replace [regex]::Escape($oldText), $newText
}

# Write the modified content back to the file
$content | Set-Content -Path $filePath






















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