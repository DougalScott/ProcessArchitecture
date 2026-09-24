@{
    RootModule        = 'ProcessArchitecture.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '6d11f68e-bc8f-4f33-8ac8-6c9131d7d522'
    Author            = 'Dougal Scott'
    CompanyName       = ''
    Copyright         = '(c) Dougal Scott. All rights reserved.'
    Description       = 'Enumerates running processes and groups them by architecture.'

    PowerShellVersion = '5.1'

    FunctionsToExport = @(
        'Get-ProcessArchitectureInventory'
    )

    CmdletsToExport   = @()

    VariablesToExport = @()

    AliasesToExport   = @(
        'gpai'
    )

    PrivateData = @{
        PSData = @{
            Tags = @(
                'Process'
                'Architecture'
                'x86'
                'x64'
                'ARM64'
            )

            ProjectUri = ''
            LicenseUri = ''
        }
    }
}