<# Self-update and recycle-only operations for the Galaxy Plugin Updater.
   Check is called inside one pre-parsed BAT block: after replacement that
   block must exit, never resume reading the old batch at its former offset.
   Library only defines functions; it does not access the network or files.
#>
param(
    [ValidateSet('Check','Library')][string]$Mode = 'Check',
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [string]$CurrentVersion,
    [ValidateSet('EN','DE')][string]$Lang = 'EN'
)

function Get-UpdaterFileNames {
    @('CHANGELOG.md','licenses/LICENSE','README.md','update-plugins.bat',
      'scripts/update-plugins-helpers.ps1','scripts/update-plugins-self-update.ps1','scripts/update-plugins-recycle.cs')
}

function Assert-UpdaterLocalPath([string]$Path) {
    $full = [IO.Path]::GetFullPath($Path)
    $drive = New-Object IO.DriveInfo([IO.Path]::GetPathRoot($full))
    if ($drive.DriveType -ne [IO.DriveType]::Fixed) { throw 'A local fixed drive is required for safe recycling.' }
    $cursor = $full
    while ($cursor) {
        if (Test-Path -LiteralPath $cursor) {
            $item = Get-Item -LiteralPath $cursor -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked path is not supported: $cursor" }
        }
        $parent = [IO.Path]::GetDirectoryName($cursor.TrimEnd('\'))
        if ($parent -eq $cursor) { break }
        $cursor = $parent
    }
    return $full
}

function Initialize-UpdaterRecycler {
    if ('GalaxyUpdater.RecycleOnly' -as [type]) { return }
    Add-Type -Path (Join-Path $PSScriptRoot 'update-plugins-recycle.cs')
}

function Move-ToUpdaterRecycleBin([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $full = Assert-UpdaterLocalPath $Path
    Initialize-UpdaterRecycler
    [GalaxyUpdater.RecycleOnly]::Send($full)
    if (Test-Path -LiteralPath $full) { throw "Item was not recycled: $full" }
}

function Get-UpdaterRelease([object[]]$Items, [string]$InstalledVersion) {
    if ($InstalledVersion -notmatch '^\d+\.\d+\.\d+$') { throw 'Invalid installed updater version.' }
    $prefix = 'tools/melcom-galaxy_plugin_updater/'
    $candidates = @(foreach ($item in $Items) {
        if ($item.type -ne 'file' -or $item.name -cnotmatch '^melcom-galaxy_plugin_updater-v(\d+\.\d+\.\d+)\.zip$') { continue }
        $versionText = $Matches[1]
        if ($item.path -cne ($prefix + $item.name) -or $item.sha -notmatch '^[a-fA-F0-9]{40}$' -or $item.size -le 0 -or $item.size -gt 5242880) { continue }
        [pscustomobject]@{Version=$versionText; Number=[version]$versionText; Name=$item.name; Sha=$item.sha; Size=[long]$item.size;
            Url=('https://raw.githubusercontent.com/melcom-creations/galaxy-integrations-64bit/main/' + $prefix + $item.name)}
    })
    $latest = $candidates | Sort-Object Number -Descending | Select-Object -First 1
    if (-not $latest) { throw 'No valid updater ZIP found in the GitHub folder.' }
    [pscustomobject]@{Available=($latest.Number -gt [version]$InstalledVersion); Release=$latest}
}

function Get-UpdaterSHA256([string]$Path) {
    $stream=[IO.File]::OpenRead($Path)
    $sha=[Security.Cryptography.SHA256]::Create()
    try { return [BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-','') }
    finally { $sha.Dispose(); $stream.Dispose() }
}

function Get-UpdaterGitBlobHash([string]$Path) {
    $data = [IO.File]::ReadAllBytes($Path)
    $header = [Text.Encoding]::ASCII.GetBytes(('blob ' + $data.Length + [char]0))
    $sha = [Security.Cryptography.SHA1]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash([byte[]]($header + $data)))).Replace('-','').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

function Expand-VerifiedUpdater([string]$Zip, [string]$Destination, [string]$Version) {
    if ($Version -notmatch '^\d+\.\d+\.\d+$') { throw 'Invalid release version.' }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $required = @(Get-UpdaterFileNames)
    $archive = [IO.Compression.ZipFile]::OpenRead($Zip)
    try {
        if (@($archive.Entries | Where-Object { $_.Name }).Count -ne $required.Count) { throw 'Unexpected updater ZIP contents.' }
        $seen = @{}
        $total = 0L
        foreach ($entry in $archive.Entries) {
            if (-not $entry.Name) {
                if ($entry.FullName -cnotin @('scripts/','licenses/')) { throw 'Unexpected ZIP directory.' }
                continue
            }
            if ($required -cnotcontains $entry.FullName -or $seen.ContainsKey($entry.FullName) -or $entry.Length -le 0) { throw 'Unsafe or unexpected ZIP entry.' }
            $seen[$entry.FullName] = $true
            $total += $entry.Length
            if ($total -gt 20971520) { throw 'Updater ZIP is too large.' }
        }
    } finally { $archive.Dispose() }
    if (Test-Path -LiteralPath $Destination) { throw 'Extraction destination already exists.' }
    [IO.Compression.ZipFile]::ExtractToDirectory($Zip,$Destination)
    $batch = [IO.File]::ReadAllText((Join-Path $Destination 'update-plugins.bat'))
    $versions = [regex]::Matches($batch,'(?m)^set "UPDATER_VERSION=(\d+\.\d+\.\d+)"\r?$')
    if ($versions.Count -ne 1 -or $versions[0].Groups[1].Value -cne $Version) { throw 'Updater ZIP version does not match its filename.' }
    $readme = [IO.File]::ReadAllText((Join-Path $Destination 'README.md'))
    if ($readme -notmatch ('(?m)^# melcom GOG Galaxy v2\.1\+ Plugin Updater v' + [regex]::Escape($Version) + '\r?$')) { throw 'README version mismatch.' }
    foreach ($name in @('scripts/update-plugins-helpers.ps1','scripts/update-plugins-self-update.ps1')) {
        $tokens=$null; $errors=$null
        [Management.Automation.Language.Parser]::ParseFile((Join-Path $Destination $name),[ref]$tokens,[ref]$errors) | Out-Null
        if ($errors.Count) { throw "Invalid PowerShell script: $name" }
    }
}

function Install-PreparedUpdater([string]$Target, [string]$Prepared, [string]$Workspace, [string]$InstalledVersion) {
    $Target = Assert-UpdaterLocalPath $Target
    $Workspace = Assert-UpdaterLocalPath $Workspace
    $boundary = $Target.TrimEnd('\') + '\.self-update\'
    if (-not $Workspace.StartsWith($boundary,[StringComparison]::OrdinalIgnoreCase) -or
        [IO.Path]::GetFullPath($Prepared) -ine (Join-Path $Workspace 'prepared')) { throw 'Invalid self-update workspace.' }
    $files = @(Get-UpdaterFileNames)
    foreach ($name in $files) {
        foreach ($base in @($Target,$Prepared)) {
            $path = Join-Path $base $name
            [void](Assert-UpdaterLocalPath $path)
            if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing updater file: $path" }
        }
    }
    $bat = [IO.File]::ReadAllText((Join-Path $Target 'update-plugins.bat'))
    if ($bat -notmatch ('(?m)^set "UPDATER_VERSION=' + [regex]::Escape($InstalledVersion) + '"\r?$')) { throw 'Installed updater changed during update preparation.' }
    $previous = Join-Path $Workspace ('previous-v' + $InstalledVersion)
    $failed = Join-Path $Workspace 'incomplete-new-version'
    [IO.Directory]::CreateDirectory($previous) | Out-Null
    $moved = New-Object 'System.Collections.Generic.List[string]'
    $created = New-Object 'System.Collections.Generic.List[string]'
    try {
        foreach ($name in $files) {
            [IO.Directory]::CreateDirectory((Split-Path -Parent (Join-Path $previous $name))) | Out-Null
            Move-Item -LiteralPath (Join-Path $Target $name) -Destination (Join-Path $previous $name) -ErrorAction Stop
            $moved.Add($name)
        }
        foreach ($name in $files) {
            $created.Add($name)
            Copy-UpdaterFile (Join-Path $Prepared $name) (Join-Path $Target $name)
            if ((Get-UpdaterSHA256 (Join-Path $Target $name)) -ne (Get-UpdaterSHA256 (Join-Path $Prepared $name))) { throw "Installed file hash mismatch: $name" }
        }
    } catch {
        $failure = $_.Exception.Message
        try {
            [IO.Directory]::CreateDirectory($failed) | Out-Null
            foreach ($name in $created) {
                $path = Join-Path $Target $name
                if (Test-Path -LiteralPath $path) { [IO.Directory]::CreateDirectory((Split-Path -Parent (Join-Path $failed $name))) | Out-Null; Move-Item -LiteralPath $path -Destination (Join-Path $failed $name) -ErrorAction Stop }
            }
            foreach ($name in $moved) { Move-Item -LiteralPath (Join-Path $previous $name) -Destination (Join-Path $Target $name) -ErrorAction Stop }
        } catch { throw "ROLLBACK_FAILED. Recovery files: $previous. $($_.Exception.Message)" }
        throw "Update canceled; previous version restored. $failure"
    }
    $recycled = $false
    try { Move-ToUpdaterRecycleBin $previous; $recycled=$true } catch { Write-Warning "Previous version retained at $previous. $($_.Exception.Message)" }
    return [pscustomobject]@{Recycled=$recycled; RecoveryPath=$previous}
}

function Copy-UpdaterFile([string]$Source, [string]$Destination) {
    [IO.Directory]::CreateDirectory((Split-Path -Parent $Destination)) | Out-Null
    [IO.File]::Copy($Source,$Destination,$false)
}

function Restart-GalaxyUpdater([string]$Target) {
    # Inherit this console so no hidden interactive prompt or extra window is needed.
    $start = New-Object Diagnostics.ProcessStartInfo
    $start.FileName = $env:ComSpec
    $start.Arguments = '/d /s /c ""' + (Join-Path $Target 'update-plugins.bat') + '""'
    $start.WorkingDirectory = $Target
    $start.UseShellExecute = $false
    $process = [Diagnostics.Process]::Start($start)
    try { $process.WaitForExit() } finally { $process.Dispose() }
}

function Invoke-UpdaterSelfCheck([string]$Target, [string]$InstalledVersion, [string]$Language) {
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $headers = @{'User-Agent'='melcom-galaxy-updater'; Accept='application/vnd.github+json'}
        if ($env:GITHUB_TOKEN) { $headers.Authorization = 'Bearer ' + $env:GITHUB_TOKEN }
        $items = Invoke-RestMethod -UseBasicParsing -Uri 'https://api.github.com/repos/melcom-creations/galaxy-integrations-64bit/contents/tools/melcom-galaxy_plugin_updater?ref=main' -Headers $headers -TimeoutSec 5
        $check = Get-UpdaterRelease @($items) $InstalledVersion
        if ($check.Available) {
            Write-Output "UPDATE|$($check.Release.Version)"
            return
        }
        Write-Output "OK|UPTODATE"
    } catch {
        Write-Output "ERROR|$($_.Exception.Message)"
    }
}

if ($Mode -eq 'Check') {
    $ErrorActionPreference = 'Stop'
    Invoke-UpdaterSelfCheck $Root $CurrentVersion $Lang
    exit 0
}
