#!/usr/bin/env pwsh

function Replace-StringInFile {
    param (
        [string]$FilePath,
        [string]$OldString,
        [string]$NewString
    )

    if (-Not (Test-Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        return
    }

    try {
        # Read the file contents
        $fileContent = Get-Content -Path $FilePath -Raw

        # Replace the old string with the new string
        $modifiedContent = $fileContent -replace [regex]::Escape($OldString), [regex]::Escape($NewString)

        # Write the modified content back to the file
        Set-Content -Path $FilePath -Value $modifiedContent

        Write-Output "String replaced successfully in $FilePath"
    } catch {
        Write-Error "An error occurred: $_"
    }
}

Replace-StringInFile -FilePath 'Configure' -OldString 'external/perl/MODULES.txt' -NewString 'external/external~/perl/MODULES.txt'
Replace-StringInFile -FilePath 'Configure' -OldString 'die \"[*]\\{5\\} Unsupported options:' -NewString 'warn \"***** Unsupported options:'


Replace-StringInFile -FilePath 'congigdata.pm.in' -OldString \"'external', 'perl', 'MODULES.txt'\" -NewString \"'external', 'external~', 'perl', 'MODULES.txt'\"


Replace-StringInFile -FilePath 'util/dofile.pl' -OldString 'external/perl/MODULES.txt' -NewString 'external/external~/perl/MODULES.txt'


perl Configure no-comp no-idea no-weak-ssl-ciphers
# Unset Microsoft Assembler (MASM) flags set by built-in MSVC toolchain,
# as NASM is unsed to build OpenSSL rather than MASM
& nmake no-comp no-idea no-weak-ssl-ciphers VC-WIN64A ASFLAGS=\"\"

if ($args[0] -eq "true") {

    Replace-StringInFile -FilePath 'test/generate_ssl_tests.pl' -OldString 'external/perl/MODULES.txt' -NewString 'external/external~/perl/MODULES.txt'

    & nmake test
}