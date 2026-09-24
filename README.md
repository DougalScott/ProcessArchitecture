# ProcessArchitecture

PowerShell module for identifying the architecture of running processes on Windows.

The module provides accurate process architecture detection for x86, x64, ARM64, System, and Unknown processes, along with summary and detailed reporting capabilities. It is designed to help administrators quickly identify process bitness, troubleshoot application compatibility issues, and verify whether applications are running natively or under emulation.

## Features

- Detect running process architecture:
  - x86
  - x64
  - ARM64
  - System
  - Unknown
- Summary view showing counts by architecture
- Detailed process listings including:
  - Process Name
  - PID
  - Executable Path
  - Architecture
- Handles inaccessible processes gracefully
- Shows warning information when process access restrictions prevent identification
- Works on Windows PowerShell 5.1 and PowerShell 7+

## Installation

### PowerShell Gallery

```powershell
Install-Module ProcessArchitecture
```

### Manual Installation

Copy the module folder into one of the PowerShell module paths:

```powershell
$env:ProgramFiles\WindowsPowerShell\Modules
```

or

```powershell
$HOME\Documents\WindowsPowerShell\Modules
```

Import the module:

```powershell
Import-Module ProcessArchitecture
```

## Usage

### Create a ProcessArchitecture Object

```powershell
$procs = [ProcessArchitecture\]::new()
```

### Default Output

Displaying the object shows a summary grouped by architecture:

```text
Architecture Count Process Names
------------ ----- -------------
x86          12    notepad, putty
x64          187   explorer, powershell, code
ARM64        0
System       5
Unknown      3
```

### Summary View

```powershell
$procs.ToString()
```

Example:

```text
Architecture Count Process Names
------------ ----- -------------
x86          12    notepad, putty
x64          187   explorer, powershell, code
ARM64        0
System       5
Unknown      3
```

### Detailed View

```powershell
$procs.Details()
```

Example:

```text
=== x86 (12) ===

ProcessName      PID Path
-----------      --- ----
notepad         4352 C:\Windows\SysWOW64\notepad.exe

=== x64 (187) ===

ProcessName      PID Path
-----------      --- ----
explorer        7856 C:\Windows\explorer.exe
powershell      9120 C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
```

### Access Individual Groups

```powershell
$procs.x86
$procs.x64
$procs.ARM64
$procs.System
$procs.Unknown
```

### Access Process Objects

```powershell
$procs.x64.Processes
```

Filter results:

```powershell
$procs.x64.Processes |
    Where-Object ProcessName -like '*powershell*'
```

## Running as Administrator

Some protected Windows processes cannot be queried by standard users.

If inaccessible processes are reported as **Unknown**, rerun PowerShell as Administrator to improve detection coverage.

Example protected processes:

- lsass
- csrss
- Secure System
- Registry
- Memory Compression

The module will continue to function without elevation and will clearly report inaccessible processes.

## Example Use Cases

### Find All x86 Processes

```powershell
$procs = [ProcessArchitecture\]::new()

$procs.x86.Processes
```

### Find x64 PowerShell Processes

```powershell
$procs = [ProcessArchitecture\]::new()

$procs.x64.Processes |
    Where-Object ProcessName -eq 'powershell'
```

### Troubleshoot Application Compatibility

```powershell
$procs = [ProcessArchitecture\]::new()

$procs.Details()
```

Use the detailed report to identify applications running under WoW64 or to locate unexpected x86 processes on x64 systems.

## Requirements

- Windows
- PowerShell 5.1 or later
- Administrative privileges recommended for maximum process visibility

## License

MIT License

## Contributing

Issues and pull requests are welcome.

Please include:

- PowerShell version
- Windows version/build
- Example output
- Reproduction steps

## Author

Dougal Scott

## Version History

### 1.0.0

Initial release.

Features:

- Process architecture
