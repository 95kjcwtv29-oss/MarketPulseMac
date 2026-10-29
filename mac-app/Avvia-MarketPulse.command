#!/bin/bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
URL="http://127.0.0.1:8765"
APP_SUPPORT="$HOME/Library/Application Support/MarketPulse"
LOG_DIR="$HOME/Library/Logs"
mkdir -p "$APP_SUPPORT" "$LOG_DIR"
if /usr/bin/curl -fsS "$URL/api/health" >/dev/null 2>&1; then
  /usr/bin/open "$URL"
  exit 0
fi
PYTHON_BIN="$(command -v python3 2>/dev/null || true)"
if [ -z "$PYTHON_BIN" ]; then
  for candidate in /opt/homebrew/bin/python3 /usr/local/bin/python3 /usr/bin/python3; do
    if [ -x "$candidate" ]; then PYTHON_BIN="$candidate"; break; fi
  done
fi
if [ -z "$PYTHON_BIN" ]; then
  echo "Errore: Python 3 non trovato. Installa Python 3 e riprova."
  read -r -p "Premi Invio per chiudere…" _
  exit 1
fi
nohup "$PYTHON_BIN" "$HERE/marketpulse.py" >> "$LOG_DIR/MarketPulse.log" 2>&1 < /dev/null &
echo "$!" > "$APP_SUPPORT/server.pid"
for i in $(seq 1 40); do
  if /usr/bin/curl -fsS "$URL/api/health" >/dev/null 2>&1; then /usr/bin/open "$URL"; exit 0; fi
  sleep 0.25
done
echo "MarketPulse non si è avviato. Log: ~/Library/Logs/MarketPulse.log"
read -r -p "Premi Invio per chiudere…" _