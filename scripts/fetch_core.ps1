# Fetch latest Mihomo core from XSong1205/LuminClashCore
param(
    [string]$Target = "all" # "windows", "android", "all"
)

$ErrorActionPreference = "Stop"
$Repo = "XSong1205/LuminClashCore"

Write-Host "==> Checking latest release from $Repo..." -ForegroundColor Cyan

if ($Target -eq "all" -or $Target -eq "windows") {
    Write-Host "==> Downloading Windows core..." -ForegroundColor Cyan
    $tempDir = Join-Path $PSScriptRoot "..\temp_core_win"
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
    gh release download --repo $Repo --pattern "LuminClashCore-windows-amd64-*.zip" --dir $tempDir
    $zipFile = Get-ChildItem -Path $tempDir -Filter "*.zip" | Select-Object -First 1
    Expand-Archive -Path $zipFile.FullName -DestinationPath "$tempDir\extracted" -Force
    
    $assetsCore = Join-Path $PSScriptRoot "..\assets\core"
    $winRunner = Join-Path $PSScriptRoot "..\windows\runner"
    New-Item -ItemType Directory -Force -Path $assetsCore | Out-Null
    New-Item -ItemType Directory -Force -Path $winRunner | Out-Null
    
    Copy-Item "$tempDir\extracted\mihomo.exe" "$assetsCore\mihomo.exe" -Force
    Copy-Item "$tempDir\extracted\mihomo.exe" "$winRunner\mihomo.exe" -Force
    Remove-Item -Recurse -Force $tempDir
    Write-Host "==> Windows core installed successfully!" -ForegroundColor Green
}

if ($Target -eq "all" -or $Target -eq "android") {
    Write-Host "==> Downloading Android dynamic libraries..." -ForegroundColor Cyan
    $tempDir = Join-Path $PSScriptRoot "..\temp_core_android"
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
    gh release download --repo $Repo --pattern "LuminClashCore-android-jniLibs-*.zip" --dir $tempDir
    $zipFile = Get-ChildItem -Path $tempDir -Filter "*.zip" | Select-Object -First 1
    $androidDest = Join-Path $PSScriptRoot "..\android\app\src\main"
    Expand-Archive -Path $zipFile.FullName -DestinationPath $androidDest -Force
    Remove-Item -Recurse -Force $tempDir
    Write-Host "==> Android jniLibs installed successfully!" -ForegroundColor Green
}
