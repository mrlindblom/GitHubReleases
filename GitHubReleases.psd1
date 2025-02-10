@{
    ModuleVersion     = '1.0.0'
    GUID              = '12345678-90ab-cdef-1234-567890abcdef'
    Author            = 'Peter Lindblom'
    Description       = 'PowerShell module to list and download GitHub releases and assets.'
    PowerShellVersion = '5.1'

    FunctionsToExport = @('Get-GitHubReleases', 'Get-GitHubReleaseAssets', 'Save-GitHubAsset')

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData       = @{
        PSData = @{
            Tags       = @('GitHub', 'Releases', 'API', 'Download')
            LicenseUri = 'https://opensource.org/licenses/MIT'
            ProjectUri = 'https://github.com/your-repo'
        }
    }
}
