# Determine current directory and its parent
$directoryPath = (Get-Location).Path
$parentDirectory = (Get-Item $directoryPath).Parent.FullName
$name = Split-Path -Path $directoryPath -Leaf

# Move PortableApps.comLauncher and PortableApps.comInstaller up one directory
Move-Item -Path "$directoryPath\PortableApps.comLauncher" -Destination $parentDirectory -Force
Move-Item -Path "$directoryPath\PortableApps.comInstaller" -Destination $parentDirectory -Force

Get-ChildItem $directoryPath

Write-Host "Starting Launcher Generator"
$launcherGeneratorPath = "D:\a\$name\PortableApps.comLauncher\PortableApps.comLauncherGenerator.exe"
Start-Process -FilePath $launcherGeneratorPath -ArgumentList "D:\a\$name\$name" -NoNewWindow -Wait

Write-Host "Starting Installer Generator"
$installerGeneratorPath = "D:\a\$name\PortableApps.comInstaller\PortableApps.comInstaller.exe"
Start-Process -FilePath $installerGeneratorPath -ArgumentList "D:\a\$name\$name" -NoNewWindow -Wait

Get-ChildItem $directoryPath
Get-ChildItem $parentDirectory
