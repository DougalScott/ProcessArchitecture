class ProcessArchitectureInventory {
    [bool]$IsAdmin
    [pscustomobject]$x86
    [pscustomobject]$x64
    [pscustomobject]$ARM64
    [pscustomobject]$Inaccessible
    ProcessArchitectureInventory() {
        # empty parameter constructor
        $this.ProcessArchitectureInventory('*')
    }
    ProcessArchitectureInventory([string]$Filter) {
        $this.IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator
        )
        $groups = @{}
        # get architecture for each process and add to PSCustomObject
        foreach ($Process in (Get-Process $Filter -ErrorAction SilentlyContinue)) {
            $architecture = 'Inaccessible'
            try {
                if (-not $Process.Path) {
                    throw 'Process path unavailable'
                }
                $fs = [IO.File]::OpenRead($Process.Path)
                try {
                    $br = [IO.BinaryReader]$fs
                    $fs.Position = 0x3C
                    $peOffset = $br.ReadInt32()
                    $fs.Position = $peOffset + 4
                    $machine = $br.ReadUInt16()
                    $architecture = switch ($machine) {
                        0x014C { 'x86' }
                        0x8664 { 'x64' }
                        0xAA64 { 'ARM64' }
                        default { 'Inaccessible' }
                    }
                } finally {
                    $fs.Dispose()
                }
            } catch {
                $architecture = 'Inaccessible'
            }
            if (-not $groups.ContainsKey($architecture)) {
                $groups[$architecture] = [pscustomobject]@{
                    Count     = 0
                    Processes = [System.Collections.Generic.List[object]]::new()
                }
            }
            $groups[$architecture].Count++
            $groups[$architecture].Processes.Add(
                [pscustomobject]@{
                    Name = $Process.ProcessName
                    Id   = $Process.Id
                    Path = $Process.Path
                }
            )
        }
        # create grouped PSCustomObject from processes object
        foreach ($Architecture in 'x86', 'x64', 'ARM64', 'Inaccessible') {
            $this.$Architecture = if ($groups.ContainsKey($Architecture)) {
                [pscustomobject]@{
                    Count     = $groups[$Architecture].Count
                    Processes = @($groups[$Architecture].Processes)
                }
            } else {
                [pscustomobject]@{
                    Count     = 0
                    Processes = @()
                }
            }
        }
        # notify if non-elevated and inaccessible processes (expected)
        if (-not $this.IsAdmin -and $this.Inaccessible.Count) {
            Write-Warning "$($this.Inaccessible.Count) processes could not be inspected. Run elevated to identify additional processes."
        }
        $this.ToString() | Out-Host
    }
    [string] ToString() {
        # formatted report output
        return (
            $this.GetSummary() |
                Format-Table Architecture, Count, Names, ProcessNames -AutoSize |
                Out-String
        ).TrimEnd() + [System.Environment]::NewLine
    }
    hidden [object[]] GetSummary() {
        # summary object
        return @(
            [pscustomobject]@{
                Architecture = 'x86'
                Count        = $this.x86.Count
                Names        = ($this.x86.Processes.Name | Sort-Object -Unique).Count
                ProcessNames = ($this.x86.Processes.Name | Sort-Object -Unique) -join ', '
            }
            [pscustomobject]@{
                Architecture = 'x64'
                Count        = $this.x64.Count
                Names        = ($this.x64.Processes.Name | Sort-Object -Unique).Count
                ProcessNames = ($this.x64.Processes.Name | Sort-Object -Unique) -join ', '
            }
            [pscustomobject]@{
                Architecture = 'ARM64'
                Count        = $this.ARM64.Count
                Names        = ($this.ARM64.Processes.Name | Sort-Object -Unique).Count
                ProcessNames = ($this.ARM64.Processes.Name | Sort-Object -Unique) -join ', '
            }
            [pscustomobject]@{
                Architecture = 'Inaccessible'
                Count        = $this.Inaccessible.Count
                Names        = ($this.Inaccessible.Processes.Name | Sort-Object -Unique).Count
                ProcessNames = ($this.Inaccessible.Processes.Name | Sort-Object -Unique) -join ', '
            }
        ) | Where-Object Count
    }
    [string] Details() {
        # default details for interesting platforms
        return $this.Details('x86,x64,ARM64')
    }
    [string] Details([string]$Architecture) {
        # output grouped list of processes by platform with count
        $Output = [System.Collections.Generic.List[string]]::new()
        if ($Architecture -eq '*') {
            # optional all platforms
            $Architecture = 'x86,x64,ARM64,Inaccessible'
        }
        foreach ($Arch in $Architecture.Split(',').Trim()) {
            $Property = $this.PSObject.Properties.Match($Arch) |
                Select-Object -ExpandProperty Name -First 1
            if (-not $Property) {
                continue
            }
            $Group = $this.$Property
            if ($Group.Count -eq 0) { continue }
            $header = "Platform: $Arch Count: $($Group.Count)"
            $Output.AddRange([string[]]@(
                    $header
                    '=' * $header.Length
                )
            )
            $Group.Processes |
                Sort-Object Name, Id |
                Format-Table Name, Id, Path -AutoSize |
                Out-String -Stream |
                ForEach-Object {
                    $Output.Add($_)
                }
        }
        return [System.Environment]::NewLine + ($Output -join [Environment]::NewLine).TrimEnd() + [System.Environment]::NewLine
    }
}
function Get-ProcessArchitectureInventory {
    # helper function
    param(
        [string]$Name = '*'
    )
    [ProcessArchitectureInventory]::new($Name)
}
Export-ModuleMember -Function Get-ProcessArchitectureInventory