#!/usr/bin/env bash
# ======================================================
# Cross-platform PlantUML PNG + PDF generator (Linux)
# Uses system-installed plantuml + graphviz
# ======================================================

set -Eeuo pipefail

# -------------------------------
# Check dependencies
# -------------------------------
if ! command -v plantuml >/dev/null 2>&1; then
  echo "ERROR: plantuml command not found."
  exit 1
fi

if ! command -v dot >/dev/null 2>&1; then
  echo "ERROR: graphviz (dot) not found."
  exit 1
fi

if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
  echo "ERROR: ImageMagick not found (magick/convert)."
  exit 1
fi

# -------------------------------
# Output folder
# -------------------------------
OUT_FOLDER="../doc/diagrams"
OUT_FOLDER_FULL="$(realpath -m "$OUT_FOLDER")"

mkdir -p "$OUT_FOLDER_FULL"

echo "Output folder: $OUT_FOLDER_FULL"

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
# Generate PNG + PDF
# -------------------------------
for FILE in "${PUML_FILES[@]}"; do
  echo "Processing $FILE"

  plantuml -tpng -o "$OUT_FOLDER_FULL" "$FILE"
  plantuml -tpdf -o "$OUT_FOLDER_FULL" "$FILE"
done


# -------------------------------
# Create combined PDF from all PNGs
# -------------------------------

echo "Creating combined PDF..."

mapfile -t PNG_FILES < <(find "$OUT_FOLDER_FULL" -type f -name "*.png" | sort)

if [ ${#PNG_FILES[@]} -eq 0 ]; then
  echo "No PNG files found for PDF merge."
  exit 0
fi

COMBINED_PDF="$OUT_FOLDER_FULL/all_diagrams.pdf"

if command -v magick >/dev/null 2>&1; then
  magick "${PNG_FILES[@]}" "$COMBINED_PDF"
else
  convert "${PNG_FILES[@]}" "$COMBINED_PDF"
fi

echo "All diagrams generated in: $OUT_FOLDER_FULL"
echo "Combined PDF created:"
echo "$COMBINED_PDF"