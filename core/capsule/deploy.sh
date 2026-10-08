#!/usr/bin/env bash
set -euo pipefail

NAME="vtfk-capsule"
IMAGE="ubuntu:24.04"
HOST_PORT="${HOST_PORT:-8082}"

# --- ідемпотентність ---
docker rm -f "$NAME" 2>/dev/null || true

# --- піднімаємо капсулу ---
docker run -d \
  --name "$NAME" \
  -p "${HOST_PORT}:80" \
  "$IMAGE" \
  sleep infinity

# --- ставимо утиліти для огляду просторів імен ---
docker exec "$NAME" bash -c '
  apt-get update -y >/dev/null
  apt-get install -y --no-install-recommends \
    curl git procps iproute2 python3 >/dev/null
'

# --- перевірка, що все на місці ---
echo "=== Перевірка утиліт у контейнері $NAME ==="
docker exec "$NAME" bash -c '
  curl --version | head -1
  git --version
  ps --version | head -1
  ip -V
  python3 --version
'

# --- HTTP-сервер на :80 усередині контейнера (демонстрація пробросу) ---
docker exec -d "$NAME" bash -c 'cd /tmp && python3 -m http.server 80'

# --- чекаємо, поки сервер підніметься ---
for i in $(seq 1 10); do
  if curl -sf -o /dev/null "http://localhost:${HOST_PORT}/"; then
    break
  fi
  sleep 0.5
done

# --- демонстрація: порт доступний з хоста (200 OK) ---
echo ""
echo "=== curl з хоста: http://localhost:${HOST_PORT}/ ==="
curl -i "http://localhost:${HOST_PORT}/" | head -n 5

echo ""
echo "Контейнер $NAME працює. Порт $HOST_PORT -> 80."
exit 0