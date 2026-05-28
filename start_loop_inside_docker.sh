#!/usr/bin/env bash
set -e

CONTAINER_NAME="${CONTAINER_NAME:-joko-terminal-data-v5}"

echo "[1] Cek container..."
docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME" || {
  echo "Container $CONTAINER_NAME belum running."
  echo "Jalankan dulu: bash run"
  exit 1
}

echo "[2] Start loop.py detached langsung dari Docker, bukan dari terminal Firebase..."
docker exec -d "$CONTAINER_NAME" bash -lc '
  CODE_DIR="${CODE_DIR:-/joko-app}"
  BASE_DIR="${BASE_DIR:-/joko-app/data}"
  SCREEN_LOOP="${SCREEN_LOOP:-1300x800x24}"
  mkdir -p "$BASE_DIR"
  if pgrep -af "[l]oop.py" >/dev/null 2>&1; then
    echo "loop.py already running" >> "$BASE_DIR/bot_log.txt"
    exit 0
  fi
  cd "$CODE_DIR"
  setsid nohup xvfb-run -a --server-args="-screen 0 ${SCREEN_LOOP}" \
    python3 -u "$CODE_DIR/loop.py" >> "$BASE_DIR/loop_log.txt" 2>&1 < /dev/null &
  echo $! > "$BASE_DIR/loop.pid"
  disown || true
'

sleep 2

echo "[3] Cek proses loop.py:"
docker exec -it "$CONTAINER_NAME" pgrep -af loop.py || true
