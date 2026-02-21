#!/usr/bin/env bash
# ======================================================
# Cross-platform PlantUML PNG + PDF generator (Linux)
# ======================================================

set -e

# -------------------------------
# Validate PLANTUML_HOME
# -------------------------------
if [ -z "$PLANTUML_HOME" ]; then
  echo "ERROR: PLANTUML_HOME environment variable is not set."
  exit 1
fi

PLANTUML_JAR="$PLANTUML_HOME/plantuml-mit-1.2025.7.jar"

if [ ! -f "$PLANTUML_JAR" ]; then
  echo "ERROR: PlantUML JAR not found at: $PLANTUML_JAR"
  exit 1
fi

# -------------------------------
# Output folder
# -------------------------------
OUT_FOLDER="../doc/diagrams"
OUT_FOLDER_FULL="$(realpath "$OUT_FOLDER")"

if [ ! -d "$OUT_FOLDER_FULL" ]; then
  echo "Creating output folder: $OUT_FOLDER_FULL"
  mkdir -p "$OUT_FOLDER_FULL"
fi

# -------------------------------
# Find PUML files
# -------------------------------
mapfile -t PUML_FILES < <(find .. -type f -name "*.puml")

if [ ${#PUML_FILES[@]} -eq 0 ]; then
  echo "No .puml files found."
  exit 0
fi

echo "Found ${#PUML_FILES[@]} PUML files."

# -------------------------------
# Generate PNG + PDF per file
# -------------------------------
for FILE in "${PUML_FILES[@]}"; do
  echo "Processing $FILE"

  # Generate PNG
  java -jar "$PLANTUML_JAR" -tpng "$FILE"

  # Generate PDF
  java -jar "$PLANTUML_JAR" -tpdf "$FILE"

  DIR="$(dirname "$FILE")"
  BASENAME="$(basename "$FILE" .puml)"

  GENERATED_PNG="$DIR/$BASENAME.png"
  GENERATED_PDF="$DIR/$BASENAME.pdf"

  # Move PNG
  if [ -f "$GENERATED_PNG" ]; then
    mv -f "$GENERATED_PNG" "$OUT_FOLDER_FULL"
  fi

  # Move PDF
  if [ -f "$GENERATED_PDF" ]; then
    mv -f "$GENERATED_PDF" "$OUT_FOLDER_FULL"
  fi
done

echo "All diagrams generated in: $OUT_FOLDER_FULL"
echo "PNG files and individual PDFs are ready."