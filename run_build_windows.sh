perl Configure_modified

# Read the content of Makefile
$content = Get-Content Makefile

# Perform the replacements
$content = $content -replace 'configdata\.pm', 'configdata_modified.pm'
$content = $content -replace '/Configure', '/Configure_modified'
$content = $content -replaec '/config', '/config_modified'
$content = $content -replace 'dofile.pl', 'dofile_modified.pl'

# Save the modified content to a temporary file
Set-Content -Path Makefile_tmp -Value $content

# Remove the original Makefile
Remove-Item -Path Makefile

# Rename the temporary file to Makefile
Move-Item -Path Makefile_tmp -Destination Makefile
nmake
