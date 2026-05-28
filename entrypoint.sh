#!/usr/bin/env bash
set -e

CODE_DIR="${CODE_DIR:-/joko-app}"
BASE_DIR="${BASE_DIR:-/joko-app/data}"
PYTHON_BIN="${PYTHON_BIN:-$(command -v python3 || command -v python || echo python3)}"
SCREEN_LOOP="${SCREEN_LOOP:-1300x800x24}"

# 1 = loop otomatis nyala saat container hidup/restart.
# 0 = loop hanya jalan kalau start manual dari menu/start_loop_inside_docker.sh.
AUTO_START_LOOP="${AUTO_START_LOOP:-1}"

export CODE_DIR BASE_DIR PYTHONUNBUFFERED=1

BOT_LOG="$BASE_DIR/bot_log.txt"
LOOP_LOG="$BASE_DIR/loop_log.txt"
LOOP_PID="$BASE_DIR/loop.pid"

echo "=================================================="
echo " JOKO BOT TERMINAL "
echo " CODE_DIR : $CODE_DIR"
echo " BASE_DIR : $BASE_DIR"
echo " MODE     : DOCKER BACKGROUND LOOP MODE "
echo "=================================================="

mkdir -p "$BASE_DIR/chrome_profiles" "$BASE_DIR/screenshots" "$BASE_DIR/snapshots"
touch "$BASE_DIR/email.txt"
touch "$BASE_DIR/emailshare.txt"
touch "$BASE_DIR/mapping_profil.txt"
touch "$BASE_DIR/bot_log.txt"
touch "$BASE_DIR/login_log.txt"
touch "$BASE_DIR/loop_log.txt"
touch "$BASE_DIR/buat_link_log.txt"
touch "$BASE_DIR/loop_status.json"

# ==================================================
# SAFE CHROME PROFILE RECOVERY
# Aman: tidak hapus cookies/session/login Google
# ==================================================
echo "[RECOVERY] Cleaning stale Chrome locks/cache..."

pkill -f chromedriver >/dev/null 2>&1 || true
pkill -f google-chrome >/dev/null 2>&1 || true
pkill -f chrome >/dev/null 2>&1 || true
pkill -f chromium >/dev/null 2>&1 || true
pkill -f Xvfb >/dev/null 2>&1 || true

if [ -d "$BASE_DIR/chrome_profiles" ]; then
  find "$BASE_DIR/chrome_profiles" -name "Singleton*" -delete 2>/dev/null || true
  find "$BASE_DIR/chrome_profiles" -name "*.lock" -delete 2>/dev/null || true
  find "$BASE_DIR/chrome_profiles" -name "Crashpad" -type d -exec rm -rf {} + 2>/dev/null || true
  find "$BASE_DIR/chrome_profiles" -path "*/Cache" -type d -exec rm -rf {} + 2>/dev/null || true
  find "$BASE_DIR/chrome_profiles" -path "*/Code Cache" -type d -exec rm -rf {} + 2>/dev/null || true
  find "$BASE_DIR/chrome_profiles" -path "*/GPUCache" -type d -exec rm -rf {} + 2>/dev/null || true
  find "$BASE_DIR/chrome_profiles" -path "*/DawnCache" -type d -exec rm -rf {} + 2>/dev/null || true
  find "$BASE_DIR/chrome_profiles" -path "*/GrShaderCache" -type d -exec rm -rf {} + 2>/dev/null || true
fi

rm -f /tmp/.X99-lock /tmp/.X*-lock 2>/dev/null || true
echo "[RECOVERY] Done."

start_loop_detached() {
  if [ ! -f "$CODE_DIR/loop.py" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] loop.py tidak ditemukan: $CODE_DIR/loop.py" >> "$BOT_LOG"
    return 1
  fi

  if pgrep -af "[l]oop.py" >/dev/null 2>&1; then
    return 0
  fi

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] DOCKER START loop.py detached" >> "$BOT_LOG"
  printf '[%s] ===== DOCKER START loop detached =====\n' "$(date '+%Y-%m-%d %H:%M:%S')" >> "$LOOP_LOG"

  cd "$CODE_DIR"
  setsid nohup xvfb-run -a --server-args="-screen 0 ${SCREEN_LOOP}" \
    "$PYTHON_BIN" -u "$CODE_DIR/loop.py" >> "$LOOP_LOG" 2>&1 < /dev/null &

  echo $! > "$LOOP_PID"
  disown || true
}

loop_docker_keeper() {
  echo "[DOCKER-LOOP] Keeper aktif. Loop mengikuti container Docker."
  while true; do
    if [ "$AUTO_START_LOOP" = "1" ]; then
      if ! pgrep -af "[l]oop.py" >/dev/null 2>&1; then
        start_loop_detached || true
      fi
    fi
    sleep 20
  done
}

if [ "$AUTO_START_LOOP" = "1" ]; then
  loop_docker_keeper &
  echo "[DOCKER-LOOP] Auto start loop aktif."
else
  echo "[DOCKER-LOOP] Auto start loop OFF."
fi

echo "Container started successfully."
echo "Buka menu: docker exec -it joko-terminal-data-v5 bash /joko-app/menu.sh"
echo "Cek loop: docker exec -it joko-terminal-data-v5 pgrep -af loop.py"

tail -f /dev/null
