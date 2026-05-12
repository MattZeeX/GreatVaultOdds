$ErrorActionPreference = "Stop"

$tocFile = "GreatVaultOdds.toc"
$missingFiles = @()
$fileCount = 0
$nativeSeparator = [System.IO.Path]::DirectorySeparatorChar

foreach ($line in Get-Content $tocFile) {
    $entry = $line.Trim()

    # Ignores blank lines and comments/TOC metadata
    if ($entry -eq "" -or $entry.StartsWith("#")) {
        continue
    }

    $fileCount++
    $path = $entry.Replace("\", $nativeSeparator) # Ensures system-specific directory separator is used

    # Tracks missing files
    if (-not (Test-Path $path -PathType Leaf)) {
        $missingFiles += $entry
    }
}

if ($fileCount -eq 0) {
    Write-Host "No addon file entries found in $tocFile."
    exit 1
}

if ($missingFiles.Count -gt 0) {
    Write-Host "Missing files listed in ${tocFile}:"

    foreach ($file in $missingFiles) {
        Write-Host " - $file"
    }

    exit 1
}

Write-Host "TOC validation passed: $fileCount file entries checked."
exit 0
