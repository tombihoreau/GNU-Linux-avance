#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

sudo mariadb < "$SCRIPT_DIR/archive_and_anonymize.sql"
