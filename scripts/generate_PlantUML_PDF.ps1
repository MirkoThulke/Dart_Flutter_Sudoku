#!/usr/bin/env pwsh
# ======================================================
# Cross-platform PlantUML PNG + PDF generator
# PowerShell Core : Works on Windows, Linux, macOS, Docker, Jenkins
# ======================================================

# HOW TO RUN THE SCRIPT : 
# pwsh Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# pwsh .\generate_PlantUML_PDF.ps1

# -------------------------------
# Validate PLANTUML_HOME
# -------------------------------
if (-not $env:PLANTUML_HOME) {
    Write-Error "PLANTUML_HOME environment variable is not set."
    exit 1
}

$PlantUMLJar = Join-Path $env:PLANTUML_HOME "plantuml-mit-1.2025.7.jar"

if (-not (Test-Path $PlantUMLJar)) {
    Write-Error "PlantUML JAR not found at: $PlantUMLJar"
    exit 1
}

# -------------------------------
# Output folder
# -------------------------------
$OutFolder = "../doc/diagrams"
$OutFolderFull = [System.IO.Path]::GetFullPath($OutFolder)

if (-not (Test-Path $OutFolderFull)) {
    Write-Host "📁 Creating output folder: $OutFolderFull"
    New-Item -ItemType Directory -Path $OutFolderFull | Out-Null
}

# -------------------------------
# Find PUML files
# -------------------------------
$PumlFiles = Get-ChildItem -Path ".." -Recurse -File -Filter "*.puml"

if ($PumlFiles.Count -eq 0) {
    Write-Warning "No .puml files found."
    exit 0
}

Write-Host "📄 Found $($PumlFiles.Count) PUML files."

# -------------------------------
# Generate PNG + PDF per file
# -------------------------------
foreach ($File in $PumlFiles) {
    Write-Host "🖼️ Processing $($File.FullName)"

    # PNG
    java -jar "$PlantUMLJar" -tpng "$($File.FullName)"

    # PDF
    java -jar "$PlantUMLJar" -tpdf "$($File.FullName)"

    # Pick up generated PNG + PDF
    $GeneratedPNG = Join-Path $File.Directory ($File.BaseName + ".png")
    $GeneratedPDF = Join-Path $File.Directory ($File.BaseName + ".pdf")

    # Move PNG
    if (Test-Path $GeneratedPNG) {
        Move-Item -Force -Path $GeneratedPNG -Destination $OutFolderFull
    }

    # Move PDF
    if (Test-Path $GeneratedPDF) {
        Move-Item -Force -Path $GeneratedPDF -Destination $OutFolderFull
    }
}

Write-Host "🎉 All diagrams generated in: $OutFolderFull"
Write-Host "PNG files and individual PDFs are ready."
