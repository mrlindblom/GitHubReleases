# GitHubReleases

A PowerShell module that simplifies interaction with GitHub releases. This module provides functions to list releases, fetch release assets, and download assets from GitHub repositories.

Code mainly generated with https://github.com/cline/cline.

## Features

- List releases from any GitHub repository
- Filter out pre-releases
- Get latest release per minor version
- Fetch release assets
- Download release assets

## Requirements

- PowerShell 5.1 or later
- Internet connection for GitHub API access

## Installation

1. Clone or download this repository
2. Import the module using:
```powershell
Import-Module .\GitHubReleases.psm1
```

## Usage

### Get Latest Releases

```powershell
# Get the latest release
Get-GitHubReleases -Repo "microsoft/vscode" -Count 1

# Get latest 5 stable releases (excluding pre-releases)
Get-GitHubReleases -Repo "microsoft/vscode" -Count 5 -ExcludePreReleases

# Get latest release per minor version
Get-GitHubReleases -Repo "microsoft/vscode" -LatestPerMinor
```

### Get Release Assets

```powershell
# Get assets for a specific release tag
Get-GitHubReleaseAssets -Repo "microsoft/vscode" -ReleaseTag "1.85.1"
```

### Download Assets

```powershell
# Download a specific asset by its ID
Save-GitHubAsset -AssetId 123456 -DestinationPath "C:\Downloads\asset.zip"
```

### Practical Example

Here's a complete example that gets the latest stable release of a repository and downloads a specific asset:

```powershell
# Import the module
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
```

## Available Functions

### Get-GitHubReleases
Retrieves releases from a specified GitHub repository.

Parameters:
- `Repo`: The GitHub repository in the format "owner/repo"
- `Count`: Number of releases to retrieve
- `ExcludePreReleases`: Switch to exclude pre-releases
- `LatestPerMinor`: Switch to return only the latest release for each minor version

### Get-GitHubReleaseAssets
Retrieves assets for a specific release.

Parameters:
- `Repo`: The GitHub repository in the format "owner/repo"
- `ReleaseTag`: The tag of the release whose assets should be retrieved

### Save-GitHubAsset
Downloads a GitHub release asset.

Parameters:
- `AssetId`: The ID of the asset to download
- `DestinationPath`: The local path where the asset will be saved

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Peter Lindblom

## Version

1.0.0
