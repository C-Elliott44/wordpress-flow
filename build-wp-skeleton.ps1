# ------------------------------ USER INPUT ------------------------------
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



















# ------------------------------ VARIABLES ------------------------------
$dhaliWebsitesDir = "C:\xampp\htdocs"                                                   # Directory where Cameron Codes
$wpCoreURL = "http://wordpress.org/latest.zip"                                          # URL for WordPress Download
$themeURL = "https://github.com/Automattic/_s.git"                                      # URL for Theme To Download for Site
$finalDirLocation = Join-Path -Path $dhaliWebsitesDir -ChildPath $clientDomain          # Final Location of PowerShell Output
$clientDomainNoExtention = $clientDomain -replace '\..*$', ''                           # Client's Domain without Extention

$allThemesDir = Join-Path $PSScriptRoot "$clientDomain\wp-content\themes"               # themes dir Folder Location
$themeDir = "$allThemesDir\$clientDomainNoExtention"                                    # Downloaded Theme Folder Location

$wpSampleConfigFile = "$clientDomain/wp-config-sample.php"                              # wp-config-sample.php File Location
$wpConfigFile = "$PSScriptRoot\$clientDomain\wp-config.php"                             # wp-config.php File Location
$wpConfigDatabase = $clientDomainNoExtention + "_main"                                  # wp-config.php Database Name
$wpConfigUsername = $clientDomainNoExtention + "_admin"                                 # wp-config.php Username Name
$oldSalts = @"
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );
"@                                                                                      # Salts in wp-config.php to REPLACE
$saltUrl = "https://api.wordpress.org/secret-key/1.1/salt/"                             # URL for WP Salts

$themeTextDomain = "'$clientDomainNoExtention'"                                         # Underscore "Find & Replace" variables
$themeFunctions = $clientDomainNoExtention + "_"                                        # Underscore "Find & Replace" variables
$themeStyleDomain = "Text Domain: " + $clientDomainNoExtention                          # Underscore "Find & Replace" variables
$themeDocBlocks = " $clientDomainNoExtention"                                           # Underscore "Find & Replace" variables
$themePrefixHandlers = "$clientDomainNoExtention-"                                      # Underscore "Find & Replace" variables
$themeConstants = $clientDomainNoExtention.ToUpper() + "_"                              # Underscore "Find & Replace" variables













# ------------------------------ Check htdocs (FOLDER SHOULD NOT EXIST - IF IT DOES... RENAME IT!) ------------------------------
# Check if the directory exists
if (Test-Path -Path $finalDirLocation -PathType Container) {
    # The directory exists, so prompt the user
    $choice = Read-Host "Directory '$clientDomain' already exists. Do you want to rename it to '$clientDomain-old'? (Y/N)"

    if ($choice -eq "Y" -or $choice -eq "y") {
        # Rename the existing directory to add "-old"
        $newDirectoryPath = Join-Path -Path $dhaliWebsitesDir -ChildPath "$clientDomain-old"
        Rename-Item -Path $finalDirLocation -NewName $newDirectoryPath
        Write-Host "Directory in $dhaliWebsitesDir renamed to '$clientDomain-old'."
    } else {
        Write-Host "No changes were made. Exiting..."
        exit
    }
} else {
    Write-Host "Directory '$clientDomain' is avalible in '$dhaliWebsitesDir'. script continuing..."
}





















# ------------------------------ WP CORE .ZIP - DOWNLOAD, EXPAND, RENAME, & DELETE OLD ZIP ------------------------------
# Download the latest WordPress core zip file
Invoke-WebRequest -Uri $wpCoreURL -OutFile "$PSScriptRoot\latest.zip"

# Extract the zip file to the destination folder
Expand-Archive -Path "$PSScriptRoot\latest.zip" -DestinationPath $PSScriptRoot

# Rename the extracted folder to the client's domain
Rename-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath "wordpress") -NewName $clientDomain

# Clean up the downloaded zip file
Remove-Item -Path "$PSScriptRoot\latest.zip"

Write-Host "WordPress has been downloaded and extracted to the folder: $clientDomain"

















# ------------------------------ CREATE WP-CONFIG.PHP FILE ------------------------------
try {
    # Copy the source file to the destination folder with the new name
    Copy-Item -Path $wpSampleConfigFile -Destination $wpConfigFile
    Write-Host "File copied to $wpConfigFile"
} catch {
    Write-Host "An error occurred: $_"
}



















# ------------------------------ EDIT WP-CONFIG.PHP FILE ------------------------------

# RAW content output of wp-config.php File
$rawWpConfigContent = Get-Content -Path $wpConfigFile -Raw

# Use Invoke-RestMethod to retrieve the content from the saltURL
$newSalts = Invoke-RestMethod -Uri $saltUrl

# Define an array of replacement patterns and corresponding new text
$replacements = @(
    @("database_name_here", $wpConfigDatabase),
    @("username_here", $wpConfigUsername),
    @("password_here", $clientPassword),
    @("'wp_'", "'$clientPrefix'"),
    @($oldSalts, $newSalts)
)

# Loop through each replacement pattern and update the content
foreach ($replacement in $replacements) {
    $oldText, $newText = $replacement
    $rawWpConfigContent = $rawWpConfigContent -replace [regex]::Escape($oldText), $newText
}

# Write the modified content back to the file
$rawWpConfigContent | Set-Content -Path $wpConfigFile














# ------------------------------ DOWNLOAD UNDERSCORES THEME ------------------------------

# Create the target directory if it doesn't exist
if (-not (Test-Path -Path $allThemesDir -PathType Container)) {
    New-Item -Path $allThemesDir -ItemType Directory -Force
}

# Clone the GitHub repository into the target directory
git clone $themeURL $allThemesDir\_s

# Rename the folder to $ClientsDomain
Rename-Item -Path (Join-Path $allThemesDir "_s") -NewName (Join-Path $allThemesDir $clientDomainNoExtention) -Force

$findReplacePairs = @(
    @{"Find" = "'_s'"; "Replace" = $themeTextDomain},
    @{"Find" = "_s_"; "Replace" = $themeFunctions},
    @{"Find" = "Text Domain: _s"; "Replace" = $themeStyleDomain},
    @{"Find" = " _s"; "Replace" = $themeDocBlocks},
    @{"Find" = "_s-"; "Replace" = $themePrefixHandlers},
    @{"Find" = "_S_"; "Replace" = $themeConstants}
)

# Get a list of files in the specified directory and its subdirectories
$files = Get-ChildItem -Path $themeDir -File -Recurse

# Iterate through each file
foreach ($file in $files) {
    # Read the content of the file
    $content = Get-Content $file.FullName

    # Perform each find and replace pair
    foreach ($pair in $findReplacePairs) {
        $findText = $pair["Find"]
        $replaceText = $pair["Replace"]
        $content = $content -creplace [regex]::Escape($findText), $replaceText
    }

    # Save the modified content back to the file
    Set-Content -Path $file.FullName -Value $content
}

# Output a message to indicate the process is complete
Write-Host "Text replacements complete."


















# MOVE FOLDER THAT WAS JUST CREATED TO HTDOCS - IT WORKS - DON'T UNCOMMENT UNTIL ALLLLLLL OTHER WORDPRESS EDITS ARE DONE AND FOLDER IS READY TO SHIP


# # Specify the full path to the directory to be moved
# $directoryToMove = Join-Path -Path $PSScriptRoot -ChildPath $clientDomain

# # Check if the directory exists in the current root directory
# if (Test-Path -Path $directoryToMove -PathType Container) {
#     # Specify the target directory where you want to move the folder
#     $targetDirectory = Join-Path -Path $dhaliWebsitesDir -ChildPath $clientDomain

#     # Move the folder to the target directory
#     Move-Item -Path $directoryToMove -Destination $targetDirectory -Force

#     Write-Host "Folder '$clientDomain' has been moved to '$targetDirectory'."
# } else {
#     Write-Host "Folder '$clientDomain' does not exist in the current root directory. No changes were made."
# }