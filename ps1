$ErrorActionPreference = "Stop"

$existing = Get-Command "hew.exe" -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "hew: already installed at '$($existing.Source)'"
    exit 0
}

$nativeArch = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
switch ($nativeArch) {
    "AMD64"   { $arch = "x86_64" }
    "ARM64"   { $arch = "aarch64" }
    "x86"     { $arch = "x86" }
    default   { Write-Host "error: unsupported architecture '$nativeArch'"; exit 1 }
}

$asset = "hew-$arch-windows.zip"
$downloadUrl = "https://github.com/marler8997/hew/releases/latest/download/$asset"

$tmpDir = Join-Path $env:TEMP "hew-bootstrap"
$zipPath = Join-Path $tmpDir $asset
$extractDir = Join-Path $tmpDir "extract"

New-Item -ItemType Directory -Force $tmpDir | Out-Null
if (Test-Path $extractDir) { Remove-Item -Recurse -Force $extractDir }

Write-Host "hew: downloading $downloadUrl..."
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

Write-Host "hew: extracting..."
Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

$hewExe = Join-Path $extractDir "hew.exe"
if (-not (Test-Path $hewExe)) {
    Write-Host "error: hew.exe not found in archive"
    exit 1
}

Write-Host "hew: installing..."
& $hewExe install github:marler8997/hew
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue
