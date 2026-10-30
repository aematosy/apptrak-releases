$ErrorActionPreference = "Stop"

$Repo = "aematosy/apptrak-releases"
$Asset = "apptrak-windows-x64.zip"
$InstallDir = Join-Path $env:LOCALAPPDATA "Apptrak"
$Binary = Join-Path $InstallDir "apptrak.exe"

Write-Host ""
Write-Host "APPTRAK · INSTALLER"
Write-Host "----------------------------------------"
Write-Host ""

if (-not [Environment]::Is64BitOperatingSystem) {
    throw "Apptrak requires Windows x64."
}

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("apptrak-" + [Guid]::NewGuid())

New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

try {
    $Zip = Join-Path $TempDir $Asset
    $Url = "https://github.com/$Repo/releases/latest/download/$Asset"

    Write-Host "Downloading latest Apptrak..."

    Invoke-WebRequest `
        -Uri $Url `
        -OutFile $Zip

    Expand-Archive `
        -Path $Zip `
        -DestinationPath $TempDir `
        -Force

    Copy-Item `
        (Join-Path $TempDir "apptrak-windows-x64.exe") `
        $Binary `
        -Force

    $UserPath = [Environment]::GetEnvironmentVariable(
        "Path",
        "User"
    )

    $Paths = @(
        $UserPath -split ";" |
        Where-Object { $_ -ne "" }
    )

    if ($Paths -notcontains $InstallDir) {
        $NewPath = if ([string]::IsNullOrWhiteSpace($UserPath)) {
            $InstallDir
        }
        else {
            "$UserPath;$InstallDir"
        }

        [Environment]::SetEnvironmentVariable(
            "Path",
            $NewPath,
            "User"
        )

        Write-Host "Added Apptrak to the user PATH."
    }

    Write-Host ""
    Write-Host "Installed:"
    Write-Host "  $Binary"
    Write-Host ""
    Write-Host "Open a new terminal and run:"
    Write-Host ""
    Write-Host "  apptrak"
    Write-Host ""
}
finally {
    Remove-Item `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue `
        $TempDir
}
