#!/bin/bash
set -euo pipefail

REPO="95kjcwtv29-oss/MarketPulseMac"
BASE="https://raw.githubusercontent.com/$REPO/main/mac-app"
TMP="$(/usr/bin/mktemp -d)"
trap '/bin/rm -rf "$TMP"' EXIT

APP_DIRS=()
for candidate in "$HOME/Applications/MarketPulse.app" "/Applications/MarketPulse.app"; do
  if [ -d "$candidate/Contents/Resources" ]; then
    APP_DIRS+=("$candidate")
  fi
done

# If the app bundle is missing, reinstall it from the GitHub source archive.
if [ "${#APP_DIRS[@]}" -eq 0 ]; then
  echo "App bundle non trovato: reinstallo dal repository GitHub…"
  /usr/bin/curl -fLsS --retry 2 "https://github.com/$REPO/archive/refs/heads/main.zip" -o "$TMP/MarketPulseMac.zip"
  /usr/bin/ditto -x -k "$TMP/MarketPulseMac.zip" "$TMP"
  /bin/bash "$TMP/MarketPulseMac-main/mac-app/install-macos.sh"
  APP_DIRS=("$HOME/Applications/MarketPulse.app")
fi

echo "Scarico l'ultima versione dei file da GitHub…"
/usr/bin/curl -fLsS --retry 2 "$BASE/marketpulse.py" -o "$TMP/marketpulse.py"
/usr/bin/curl -fLsS --retry 2 "$BASE/index.html" -o "$TMP/index.html"

# Stop the running server once before replacing any bundle resources.
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

for APP_DIR in "${APP_DIRS[@]}"; do
  RES="$APP_DIR/Contents/Resources"
  echo "Aggiorno: $APP_DIR"
  if [ -w "$RES" ]; then
    /bin/cp "$TMP/marketpulse.py" "$RES/marketpulse.py"
    /bin/cp "$TMP/index.html" "$RES/index.html"
  else
    echo "Questa copia richiede autorizzazione amministratore per aggiornarsi."
    if sudo /bin/cp "$TMP/marketpulse.py" "$RES/marketpulse.py" && sudo /bin/cp "$TMP/index.html" "$RES/index.html"; then
      echo "Copia aggiornata: $APP_DIR"
    else
      echo "Non sono riuscito ad aggiornare questa copia. Continuerò con la copia utente, se presente."
    fi
  fi
done

OPEN_APP="$HOME/Applications/MarketPulse.app"
if [ ! -d "$OPEN_APP" ]; then OPEN_APP="${APP_DIRS[0]}"; fi
echo "Avvio MarketPulse aggiornato…"
/usr/bin/open "$OPEN_APP"
for i in {1..40}; do
  if /usr/bin/curl -fsS "http://127.0.0.1:8765/api/health" >/dev/null 2>&1; then
    echo "Aggiornamento completato. Dashboard: http://127.0.0.1:8765"
    exit 0
  fi
  /bin/sleep 0.25
done

echo "I file sono stati copiati, ma il server non risponde."
echo "Log diagnostico: $HOME/Library/Logs/MarketPulse.log"
exit 1
