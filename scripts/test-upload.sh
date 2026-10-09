#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Uso: $0 <UPLOAD_URL> <ARCHIVO>"
  exit 1
fi

UPLOAD_URL="$1"
FILE_PATH="$2"

if [ ! -f "$FILE_PATH" ]; then
  echo "Error: archivo no encontrado: $FILE_PATH"
  exit 1
fi

RESPONSE_FILE=$(mktemp)
trap 'rm -f "$RESPONSE_FILE"' EXIT

echo "Probando POST /upload"
echo "URL: $UPLOAD_URL"
echo "Archivo: $FILE_PATH"

if ! HTTP_STATUS=$(curl \
  --silent \
  --show-error \
  --max-time 45 \
  --output "$RESPONSE_FILE" \
  --write-out "%{http_code}" \
  --form "file=@${FILE_PATH}" \
  "$UPLOAD_URL"); then

  echo "Error de conexión o transferencia HTTP"
  cat "$RESPONSE_FILE"
  exit 1
fi

echo "HTTP Status: $HTTP_STATUS"
echo "Respuesta:"
cat "$RESPONSE_FILE"
echo ""

if [ "$HTTP_STATUS" -ge 200 ] &&
   [ "$HTTP_STATUS" -lt 300 ]; then
  echo "PASS: API respondió exitosamente"
else
  echo "FAIL: API respondió HTTP $HTTP_STATUS"
  exit 1
fi
