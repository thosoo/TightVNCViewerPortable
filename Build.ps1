$directoryPath = (Get-Location).Path
$name = Split-Path -Path $directoryPath -Leaf
Get-ChildItem $directoryPath

Write-Host "Starting Installer Generator"
$installerGeneratorPath = "D:\a\$name\PortableApps.comInstaller\PortableApps.comInstaller.exe"
Start-Process -FilePath $installerGeneratorPath -ArgumentList "D:\a\$name\$name" -NoNewWindow -Wait

Get-ChildItem $directoryPath