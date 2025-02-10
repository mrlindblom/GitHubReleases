<#
.SYNOPSIS
    Retrieves the latest releases from a specified GitHub repository.

.DESCRIPTION
    This function queries the GitHub API to fetch release information for a given repository.
    It supports filtering pre-releases, limiting the number of results, and fetching the latest release per minor version.

.PARAMETER Repo
    The GitHub repository in the format "owner/repo".

.PARAMETER Count
    The number of releases to retrieve.

.PARAMETER ExcludePreReleases
    A switch to exclude pre-releases from the results.

.PARAMETER LatestPerMinor
    A switch to return only the latest release for each minor version.

.EXAMPLE
    Get-GitHubReleases -Repo "microsoft/vscode" -Count 5 -ExcludePreReleases
#>
function Get-GitHubReleases {
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Repo,
        [int]$Count,
        [switch]$ExcludePreReleases,
        [switch]$LatestPerMinor
    )

    process {
        $apiUrl = "https://api.github.com/repos/$Repo/releases"
        try {
            $releases = Invoke-RestMethod -Uri $apiUrl -Method Get
        }
        catch {
            Write-Error "Error fetching releases: $_"
            return
        }

        if ($ExcludePreReleases) {
            $releases = $releases | Where-Object { -not $_.prerelease }
        }

        if ($LatestPerMinor) {
            $releases = $releases | Sort-Object tag_name -Descending
            $latestReleases = @{}
            $filteredReleases = @()

            foreach ($release in $releases) {
                if ($release.tag_name -match "^(\d+)\.(\d+)") {
                    $minorVersion = "$($matches[1]).$($matches[2])"
                    if (-not $latestReleases.ContainsKey($minorVersion)) {
                        $latestReleases[$minorVersion] = $release
                        $filteredReleases += $release
                    }
                }
            }
            $releases = $filteredReleases
        }

        $releases = $releases | Select-Object -First $Count

        return $releases | ForEach-Object {
            [PSCustomObject]@{
                Name        = $_.name
                Tag         = $_.tag_name
                PublishedAt = $_.published_at
                URL         = $_.html_url
                Assets      = $_.assets | ForEach-Object {
                    [PSCustomObject]@{
                        Name        = $_.name
                        AssetId     = $_.id
                        SizeBytes   = $_.size
                        DownloadURL = $_.browser_download_url
                    }
                }
            }
        }
    }
}

<#
.SYNOPSIS
    Retrieves the assets of a specific GitHub release.

.DESCRIPTION
    Queries the GitHub API for assets of a given release tag from a specified repository.

.PARAMETER Repo
    The GitHub repository in the format "owner/repo".

.PARAMETER ReleaseTag
    The tag of the release whose assets should be retrieved.

.EXAMPLE
    Get-GitHubReleaseAssets -Repo "microsoft/vscode" -ReleaseTag "v1.0.0"
#>
function Get-GitHubReleaseAssets {
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Repo,
        [string]$ReleaseTag
    )

    process {
        $apiUrl = "https://api.github.com/repos/$Repo/releases/tags/$ReleaseTag"
        try {
            $release = Invoke-RestMethod -Uri $apiUrl -Method Get
        }
        catch {
            Write-Error "Error fetching release assets: $_"
            return
        }

        return $release.assets | ForEach-Object {
            [PSCustomObject]@{
                Name        = $_.name
                AssetId     = $_.id
                SizeBytes   = $_.size
                DownloadURL = $_.browser_download_url
            }
        }
    }
}

<#
.SYNOPSIS
    Downloads a GitHub release asset.

.DESCRIPTION
    Fetches a specified asset by its ID and saves it to a designated local path.

.PARAMETER AssetId
    The ID of the asset to be downloaded.

.PARAMETER DestinationPath
    The local file path where the asset will be saved.

.EXAMPLE
    Save-GitHubAsset -AssetId 123456 -DestinationPath "C:\Downloads\file.zip"
#>
function Save-GitHubAsset {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [int]$AssetId,
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    process {
        $apiUrl = "https://api.github.com/repos/k3s-io/k3s/releases/assets/$AssetId"
        try {
            $headers = @{ Accept = "application/octet-stream" }
            Invoke-WebRequest -Uri $apiUrl -Headers $headers -OutFile $DestinationPath
            Write-Output "Asset downloaded successfully to $DestinationPath"
        }
        catch {
            Write-Error "Error downloading asset: $_"
        }
    }
}

# Export module functions
Export-ModuleMember -Function Get-GitHubReleases, Get-GitHubReleaseAssets, Save-GitHubAsset
