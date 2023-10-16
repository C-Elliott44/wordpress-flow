$wp_folder = 'wp'

"Test to see if folder []  exists"
if (Test-Path -Path $wp_folder) {
    Remove-Item $wp_folder -Verbose -Recurse
}


New-Item -Path $wp_folder -ItemType Directory