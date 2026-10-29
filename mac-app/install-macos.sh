#!/bin/bash
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$HOME/Applications/MarketPulse.app"
CONTENTS="$APP_DIR/Contents"
RESOURCES="$CONTENTS/Resources"
MACOS="$CONTENTS/MacOS"
STOP_SCRIPT="$HOME/Applications/Ferma-MarketPulse.command"

if ! command -v python3 >/dev/null 2>&1; then
  echo "MarketPulse richiede Python 3. Non lo trovo in questo Mac."
  echo "Installa Python 3 da https://www.python.org/downloads/macos/ e poi riesegui questo installatore."
  exit 1
fi

if [[ ! -f "$SOURCE_DIR/marketpulse.py" || ! -f "$SOURCE_DIR/index.html" ]]; then
  echo "File mancanti: lancia questo installatore dalla cartella mac-app del repository."
  exit 1
fi

mkdir -p "$HOME/Applications" "$RESOURCES" "$MACOS"
cp "$SOURCE_DIR/marketpulse.py" "$RESOURCES/marketpulse.py"
cp "$SOURCE_DIR/index.html" "$RESOURCES/index.html"

cat > "$MACOS/MarketPulse" <<'LAUNCHER'
#!/bin/bash
set -u
RESOURCE_DIR="$(cd "$(dirname "$0")/../Resources" && pwd)"
URL="http://127.0.0.1:8765"
APP_SUPPORT="$HOME/Library/Application Support/MarketPulse"
LOG_DIR="$HOME/Library/Logs"
PID_FILE="$APP_SUPPORT/server.pid"
mkdir -p "$APP_SUPPORT" "$LOG_DIR"
if /usr/bin/curl -fsS "$URL/api/health" >/dev/null 2>&1; then
  /usr/bin/open "$URL"
  exit 0
fi
PYTHON_BIN="$(command -v python3 2>/dev/null || true)"
if [ -z "$PYTHON_BIN" ]; then
  /usr/bin/osascript -e 'display dialog "MarketPulse richiede Python 3. Installa Python 3 e riprova." buttons {"OK"} default button 1'
  exit 1
fi
nohup "$PYTHON_BIN" "$RESOURCE_DIR/marketpulse.py" >> "$LOG_DIR/MarketPulse.log" 2>&1 < /dev/null &
SERVER_PID=$!
echo "$SERVER_PID" > "$PID_FILE"
for i in $(seq 1 40); do
  if /usr/bin/curl -fsS "$URL/api/health" >/dev/null 2>&1; then
    /usr/bin/open "$URL"
    exit 0
  fi
  sleep 0.25
done
/usr/bin/osascript -e 'display dialog "MarketPulse non si è avviato. Controlla ~/Library/Logs/MarketPulse.log e verifica che la porta 8765 sia libera." buttons {"OK"} default button 1'
exit 1
LAUNCHER
chmod 755 "$MACOS/MarketPulse"

cat > "$CONTENTS/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key><string>MarketPulse</string>
  <key>CFBundleIdentifier</key><string>it.marketpulse.localdashboard</string>
  <key>CFBundleName</key><string>MarketPulse</string>
  <key>CFBundleDisplayName</key><string>MarketPulse Financial Intelligence</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1.0.0</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

cat > "$STOP_SCRIPT" <<'STOP'
#!/bin/bash
APP_SUPPORT="$HOME/Library/Application Support/MarketPulse"
PID_FILE="$APP_SUPPORT/server.pid"
if [[ ! -f "$PID_FILE" ]]; then
  echo "Il server MarketPulse non risulta attivo."
  exit 0
fi
PID="$(cat "$PID_FILE" 2>/dev/null || true)"
if [[ "$PID" =~ ^[0-9]+$ ]] && kill -0 "$PID" 2>/dev/null; then
  kill "$PID" 2>/dev/null || true
  echo "Richiesta di arresto inviata a MarketPulse."
else
  echo "Il processo MarketPulse non risulta attivo."
fi
rm -f "$PID_FILE"
STOP
chmod 755 "$STOP_SCRIPT"

echo
echo "Installazione completata: $APP_DIR"
echo "Avvio di MarketPulse…"
/usr/bin/open "$APP_DIR"
