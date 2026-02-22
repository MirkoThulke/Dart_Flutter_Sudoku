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

echo "All diagrams generated in: $OUT_FOLDER_FULL"
echo "PNG files and individual PDFs are ready."