# Scrape TightVNC version from website
$webContent = Invoke-WebRequest -Uri "https://www.tightvnc.com/download.php"
$tag = ($webContent.Content | Select-String -Pattern 'Download TightVNC for Windows \(Version (\d+\.\d+\.\d+)\)' | ForEach-Object { $_.Matches[0].Groups[1].Value })

Write-Host $tag

# Set UPSTREAM_TAG to the TightVNC version
echo "UPSTREAM_TAG=$tag" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
    
# Here, we assume you have a secondary repository or location where you check for the latest version.
# For this example, I'm using a GitHub repository. You might want to change this based on your use case.
$repoName2 = "thosoo/TightVNCViewerPortable"
$releasesUri2 = "https://api.github.com/repos/$repoName2/releases/latest"
$local_tag = (Invoke-RestMethod $releasesUri2).tag_name
    
# If the local tag is not the same as the upstream tag, set SHOULD_BUILD to "yes"
if ($local_tag -ne $tag){
    echo "SHOULD_BUILD=yes" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
}
else{
    # If the local tag is the same as the upstream tag, set SHOULD_BUILD to "no"
    Write-Host "No changes."
    echo "SHOULD_BUILD=no" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
}
