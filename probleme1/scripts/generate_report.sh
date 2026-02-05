#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

OUT_FILE="$BASE_DIR/reports/report-$(date +%Y).txt"
TMP_FILE="$BASE_DIR/data/ca_raw.txt"

sudo mariadb -B < "$SCRIPT_DIR/export_ca.sql" > "$TMP_FILE"
awk -f "$SCRIPT_DIR/report.awk" "$TMP_FILE" > "$OUT_FILE"

