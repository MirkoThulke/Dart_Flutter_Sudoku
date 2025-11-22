# ======================================================
# PowerShell script to generate PlantUML diagrams and PDF
# ======================================================

# HOW TO RUN THE SCRIPT : 
# powershell Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# powershell .\generate_PlantUML_PDF.ps1

# Path to PlantUML JAR
$PlantUMLJar = Join-Path $env:PLANTUML_HOME "plantuml-mit-1.2025.7.jar"
if (-not (Test-Path $PlantUMLJar)) {
    Write-Error "PlantUML JAR not found at $PlantUMLJar. Please set PLANTUML_HOME environment variable correctly."
    exit 1
}

# Output folder for PNGs and PDF
$OutFolder = "..\doc\diagrams"
$OutFolderFull = [System.IO.Path]::GetFullPath($OutFolder)

if (-not (Test-Path $OutFolderFull)) {
    Write-Host "Creating output folder: $OutFolderFull"
    New-Item -ItemType Directory -Path $OutFolderFull | Out-Null
}

# Find all .puml files recursively starting from current parent directory
$PumlFiles = Get-ChildItem -Path ".." -Recurse -File -Filter *.puml -ErrorAction SilentlyContinue

if ($PumlFiles.Count -eq 0) {
    Write-Host "No .puml files found in current directory or subfolders."
    exit
}

# -------------------------------
# Generate PNGs, all in the same folder
# -------------------------------
foreach ($File in $PumlFiles) {
    $FileName = $File.BaseName + ".png"
    $OutFile = Join-Path $OutFolderFull $FileName

    # Generate diagram in the same folder as the PUML file
    java -jar "$PlantUMLJar" -tpng -verbose "$($File.FullName)"

    # PlantUML puts the PNG in the same folder as the PUML by default
    $GeneratedFile = Join-Path $File.Directory ($File.BaseName + ".png")

    # Move PNG to the common output folder
    if ((Test-Path $GeneratedFile) -and ($GeneratedFile -ne $OutFile)) {
        Move-Item $GeneratedFile $OutFile -Force
    }
}
# Uses absolute paths for both PNG output and PDF.

# Moves all PNGs into a single folder, no subfolders.

# Handles existing files safely.

# Word COM is run with DisplayAlerts=0 and try/catch to avoid silent failures.

# Fully bulletproof for repeated runs on Windows.


Write-Host "All PNG diagrams generated in $OutFolderFull."

# -------------------------------
# Create PDF from all PNGs
# -------------------------------
# PDF file path as a plain string
$PdfFile = [string](Join-Path $OutFolderFull "AllDiagrams.pdf")

# Remove existing PDF
if (Test-Path $PdfFile) { Remove-Item $PdfFile -Force }

# Open Word COM
$Word = New-Object -ComObject Word.Application
$Word.Visible = $false
$Word.DisplayAlerts = 0  # wdAlertsNone
$Doc = $Word.Documents.Add()

# Reload PNG files
$PngFiles = Get-ChildItem -Path $OutFolderFull -Filter *.png | Sort-Object Name

foreach ($Png in $PngFiles) {
    $Selection = $Word.Selection
    $Selection.InlineShapes.AddPicture($Png.FullName)
    $Selection.TypeParagraph()
}

# Save PDF (use a temp variable for [ref])
$refPath = $PdfFile
try {
    $Doc.SaveAs([ref] $refPath, [ref] 17)  # wdFormatPDF = 17
    Write-Host "PDF created at $PdfFile"
} catch {
    Write-Error "Failed to save PDF: $_"
} finally {
    $Doc.Close()
    $Word.Quit()
}
