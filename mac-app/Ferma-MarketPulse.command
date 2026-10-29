#!/bin/bash
APP_SUPPORT="$HOME/Library/Application Support/MarketPulse"
PID_FILE="$APP_SUPPORT/server.pid"
if [ ! -f "$PID_FILE" ]; then
  echo "PID MarketPulse non trovato. Se il server è ancora attivo, riavvia il Mac o consulta il log."
  read -r -p "Premi Invio per chiudere…" _
  exit 0
fi
PID="$(cat "$PID_FILE" 2>/dev/null)"
if [[ "$PID" =~ ^[0-9]+$ ]] && kill -0 "$PID" 2>/dev/null; then
  kill "$PID" 2>/dev/null || true
  echo "Richiesta di arresto inviata a MarketPulse (PID $PID)."
else
  echo "Il processo MarketPulse non risulta attivo."
fi
rm -f "$PID_FILE"
read -r -p "Premi Invio per chiudere…" _