#!/bin/bash
set -euo pipefail

REPO="95kjcwtv29-oss/MarketPulseMac"
BASE="https://raw.githubusercontent.com/$REPO/main/mac-app"
TMP="$(/usr/bin/mktemp -d)"
trap '/bin/rm -rf "$TMP"' EXIT

APP_DIR=""
for candidate in "$HOME/Applications/MarketPulse.app" "/Applications/MarketPulse.app"; do
  if [ -d "$candidate/Contents/Resources" ]; then
    APP_DIR="$candidate"
    break
  fi
done

# If the app bundle is missing, reinstall it from the GitHub source archive.
if [ -z "$APP_DIR" ]; then
  echo "App bundle non trovato nelle cartelle Applicazioni: reinstallo dal repository GitHub…"
  /usr/bin/curl -fLsS --retry 2 "https://github.com/$REPO/archive/refs/heads/main.zip" -o "$TMP/MarketPulseMac.zip"
  /usr/bin/ditto -x -k "$TMP/MarketPulseMac.zip" "$TMP"
  /bin/bash "$TMP/MarketPulseMac-main/mac-app/install-macos.sh"
  APP_DIR="$HOME/Applications/MarketPulse.app"
fi

RES="$APP_DIR/Contents/Resources"
if [ ! -d "$RES" ]; then
  echo "Errore: cartella Resources non trovata dentro: $APP_DIR"
  exit 1
fi

echo "Scarico l'ultima versione dei file da GitHub…"
/usr/bin/curl -fLsS --retry 2 "$BASE/marketpulse.py" -o "$TMP/marketpulse.py"
/usr/bin/curl -fLsS --retry 2 "$BASE/index.html" -o "$TMP/index.html"

# Stop the old local server before replacing its files.
PID_FILE="$HOME/Library/Application Support/MarketPulse/server.pid"
if [ -f "$PID_FILE" ]; then
  PID="$(/bin/cat "$PID_FILE" 2>/dev/null || true)"
  if [[ "$PID" =~ ^[0-9]+$ ]]; then
    /bin/kill "$PID" 2>/dev/null || true
    for i in {1..20}; do
      if ! /bin/kill -0 "$PID" 2>/dev/null; then break; fi
      /bin/sleep 0.2
    done
  fi
  /bin/rm -f "$PID_FILE"
fi

/bin/cp "$TMP/marketpulse.py" "$RES/marketpulse.py"
/bin/cp "$TMP/index.html" "$RES/index.html"

echo "Avvio MarketPulse aggiornato…"
/usr/bin/open "$APP_DIR"
for i in {1..40}; do
  if /usr/bin/curl -fsS "http://127.0.0.1:8765/api/health" >/dev/null 2>&1; then
    echo "Aggiornamento completato. La dashboard è disponibile su http://127.0.0.1:8765"
    exit 0
  fi
  /bin/sleep 0.25
done

echo "L'aggiornamento è stato copiato, ma il server non risponde."
echo "Log diagnostico: $HOME/Library/Logs/MarketPulse.log"
exit 1
