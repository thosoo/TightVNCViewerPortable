# Import PsIni module, install it if not found
$module = Get-Module -Name PsIni -ErrorAction SilentlyContinue
if (!$module) {
    Install-Module -Scope CurrentUser PsIni
    Import-Module PsIni
} else {
    Import-Module PsIni
}

# Scrape TightVNC version from website
try {
    $webContent = Invoke-WebRequest -Uri "https://www.tightvnc.com/download.php"
    $tag2 = ($webContent.Content | Select-String -Pattern 'Download TightVNC for Windows \(Version (\d+\.\d+\.\d+)\)' | ForEach-Object { $_.Matches[0].Groups[1].Value })
} catch {
    Write-Host "Error while scraping website."
    echo "SHOULD_COMMIT=no" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
    break
}

Write-Host $tag2

# Set the UPSTREAM_TAG variable in the GitHub environment file
echo "UPSTREAM_TAG=$tag2" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append

# Get the contents of the appinfo.ini file and check if the DisplayVersion matches the version
$appinfo = Get-IniContent ".\App\AppInfo\appinfo.ini"
if ($appinfo["Version"]["DisplayVersion"] -ne $tag2){

    # Update the PackageVersion and DisplayVersion in appinfo.ini
    $appinfo["Version"]["PackageVersion"]=-join($tag2,".0")
    $appinfo["Version"]["DisplayVersion"]=$tag2
    $appinfo | Out-IniFile -Force -Encoding ASCII -FilePath ".\App\AppInfo\appinfo.ini"

    $directoryPath = (Get-Location).Path
    $name = Split-Path -Path $directoryPath -Leaf
    Get-ChildItem $directoryPath
    
    # Downloading the MSI files
    $downloadUrls = @(
        "https://www.tightvnc.com/download/$tag2/tightvnc-$tag2-gpl-setup-32bit.msi",
        "https://www.tightvnc.com/download/$tag2/tightvnc-$tag2-gpl-setup-64bit.msi"
    )

    foreach ($url in $downloadUrls) {
        $filename = [System.IO.Path]::GetFileName($url)
        Invoke-WebRequest -Uri $url -OutFile $filename
    }

    # Extract MSI files using a specific path to 7z.exe
    $sevenZipPath = "D:\a\$name\7Zip\win\7za.exe"
    $msiFiles = @("tightvnc-$tag2-gpl-setup-32bit.msi", "tightvnc-$tag2-gpl-setup-64bit.msi")
    $extractDirs = @("32bit", "64bit")
    for ($i = 0; $i -lt $msiFiles.Length; $i++) {
        $msi = $msiFiles[$i]
        $extractDir = $extractDirs[$i]
        & $sevenZipPath x $msi -o"$extractDir" -aoa
    }

    # Rename and move viewerEXE
    $destDirs = @("App\TightVNC", "App\TightVNC64")
    for ($i = 0; $i -lt $extractDirs.Length; $i++) {
        $dir = $extractDirs[$i]
        $destDir = $destDirs[$i]
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir
        }
        Move-Item -Path ".\$dir\viewerEXE" -Destination ".\$destDir\viewer.exe" -Force
    }

    # Cleanup: Remove downloaded MSI files and extracted directories
    $msiFiles + $extractDirs | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item $_ -Recurse -Force
        }
    }

    Remove-Item "D:\a\$name\7Zip\" -Recurse -Force

    # Print a message indicating the version has been bumped and set SHOULD_COMMIT to yes in the GitHub environment file
    Write-Host "Bumped to "+$tag2
    echo "SHOULD_COMMIT=yes" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append

} else {
    Write-Host "No changes."
    echo "SHOULD_COMMIT=no" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
}
