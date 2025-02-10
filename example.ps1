# Import the GitHubReleases module
Import-Module .\GitHubReleases.psm1

# Define the repository
$Repo = "k3s-io/k3s"

# Get the latest stable release (excluding pre-releases)
$latestRelease = Get-GitHubReleases -Repo $Repo -Count 1 -ExcludePreReleases

# Get the assets for the latest release
$assets = Get-GitHubReleaseAssets -Repo $Repo -ReleaseTag $latestRelease.Tag

# Find a specific asset (e.g., an amd64 binary)
$selectedAsset = $assets | Where-Object { $_.Name -like "*amd64.tar.gz*" }

# Download the asset using its original filename
if ($selectedAsset) {
    $destinationFolder = "."
    $destinationPath = Join-Path -Path $destinationFolder -ChildPath $selectedAsset.Name
    $selectedAsset | Save-GitHubAsset -DestinationPath $destinationPath
}
else {
    Write-Host "No matching asset found."
}