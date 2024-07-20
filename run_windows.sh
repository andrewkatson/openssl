#!/usr/bin/env pwsh

# Read the content of Configure
$content = Get-Content Configure

# Perform the replacements
$content = $content -replace 'external/perl/MODULES.txt', 'external/external~/perl/MODULES.txt'
$content = $content -replace 'die \"[*]\\{5\\} Unsupported options:', 'warn \"***** Unsupported options:'

# Save the modified content to a temporary file
Set-Content -Path Configure_tmp -Value $content

# Remove the original Configure
Remove-Item -Path Configure

# Rename the temporary file to Configure
Move-Item -Path Configure_tmp -Destination Configure

# Read the content of congigdata.pm.in
$content = Get-Content congigdata.pm.in

# Perform the replacements
$content = $content -replace \"'external', 'perl', 'MODULES.txt\", \"'external', 'external~', 'perl', 'MODULES.txt\"

# Save the modified content to a temporary file
Set-Content -Path congigdata.pm.in_tmp -Value $content

# Remove the original configdata.pm.in
Remove-Item -Path congigdata.pm.in

# Rename the temporary file to configdata.pm.in
Move-Item -Path congigdata.pm.in_tmp -Destination congigdata.pm.in



# Read the content of util/dofile.pl
$content = Get-Content util/dofile.pl

# Perform the replacements
$content = $content -replace 'external/perl/MODULES.txt', 'external/external~/perl/MODULES.txt'

# Save the modified content to a temporary file
Set-Content -Path util/dofile.pl_tmp -Value $content

# Remove the original util/dofile.pl
Remove-Item -Path util/dofile.pl

# Rename the temporary file to util/dofile.pl
Move-Item -Path util/dofile.pl_tmp -Destination util/dofile.pl

perl Configure
& nmake

if ($args[0] -eq "true") {
    & nmake test
}
