#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CANONICAL_ROOT="${GRUPOJF_CANONICAL_ROOT:-/opt/grupojf}"
if [[ -d "${CANONICAL_ROOT}/frontend" && -f "${CANONICAL_ROOT}/tools/ensure-frontend-dev.sh" ]]; then
  ROOT_DIR="${CANONICAL_ROOT}"
else
  ROOT_DIR="${SCRIPT_ROOT}"
fi

FRONTEND_DIR="${ROOT_DIR}/frontend"
PROJECT_NAME="${GRUPOJF_FRONTEND_PROJECT_NAME:-grupojf}"
PORT="${GRUPOJF_FRONTEND_PORT:-3000}"
BIND_HOST="${GRUPOJF_FRONTEND_BIND_HOST:-0.0.0.0}"
HEALTH_URL="http://127.0.0.1:${PORT}/"
LOG_DIR="${ROOT_DIR}/.codex/dev-logs"
LOG_FILE="${LOG_DIR}/frontend-dev.log"
PID_FILE="${LOG_DIR}/frontend-dev.pid"
TMUX_SESSION="${PROJECT_NAME}-frontend-dev-${PORT}"

is_dev_server_running() {
  curl -fsS --max-time 3 "${HEALTH_URL}" >/dev/null 2>&1
}

port_has_listener() {
  if command -v ss >/dev/null 2>&1; then
    ss -ltn "sport = :${PORT}" 2>/dev/null | grep -q 'LISTEN'
    return
  fi

  if command -v lsof >/dev/null 2>&1; then
    lsof -iTCP:"${PORT}" -sTCP:LISTEN -Pn >/dev/null 2>&1
    return
  fi

  return 1
}

detect_public_host() {
  if [[ -n "${GRUPOJF_FRONTEND_PUBLIC_HOST:-}" ]]; then
    printf '%s\n' "${GRUPOJF_FRONTEND_PUBLIC_HOST}"
    return
  fi

  if [[ -n "${DEV_PUBLIC_HOST:-}" ]]; then
    printf '%s\n' "${DEV_PUBLIC_HOST}"
    return
  fi

  local public_ip
  public_ip="$(curl -fsS --max-time 3 https://api.ipify.org 2>/dev/null || true)"
  if [[ -n "${public_ip}" ]]; then
    printf '%s\n' "${public_ip}"
    return
  fi

  hostname -I 2>/dev/null | awk '{print $1}'
}

print_firewall_status() {
  if ! command -v ufw >/dev/null 2>&1; then
    return
  fi

  local ufw_status
  ufw_status="$(ufw status 2>/dev/null || true)"
  if ! printf '%s\n' "${ufw_status}" | grep -q '^Status: active'; then
    echo "Firewall: ufw is not active."
    return
  fi

  if printf '%s\n' "${ufw_status}" | grep -Eq "^${PORT}/tcp[[:space:]]+ALLOW"; then
    echo "Firewall: ${PORT}/tcp is allowed for external access."
    return
  fi

  echo "Firewall: ${PORT}/tcp is not allowed in ufw."
  echo "To expose this project port, run: ufw allow ${PORT}/tcp comment '${PROJECT_NAME} frontend dev'"
}

build_start_command() {
  local output_log="$1"
  printf 'cd %q && HOST=%q PORT=%q BROWSER=none WDS_SOCKET_PORT=%q npm start >%q 2>&1' \
    "${FRONTEND_DIR}" "${BIND_HOST}" "${PORT}" "${PORT}" "${output_log}"
}

start_dev_server() {
  mkdir -p "${LOG_DIR}"

  if [[ ! -d "${FRONTEND_DIR}" ]]; then
    echo "Frontend directory not found: ${FRONTEND_DIR}"
    echo "Set GRUPOJF_CANONICAL_ROOT when running from a task worktree."
    exit 1
  fi

  if [[ ! -f "${FRONTEND_DIR}/package.json" ]]; then
    echo "Frontend package.json not found: ${FRONTEND_DIR}/package.json"
    exit 1
  fi

  if command -v tmux >/dev/null 2>&1; then
    local start_command
    start_command="$(build_start_command "${LOG_FILE}")"
    tmux has-session -t "${TMUX_SESSION}" 2>/dev/null && tmux kill-session -t "${TMUX_SESSION}"
    tmux new-session -d -s "${TMUX_SESSION}" "${start_command}"
    tmux display-message -p -t "${TMUX_SESSION}" '#{pane_pid}' >"${PID_FILE}"
    return
  fi

  (
    cd "${FRONTEND_DIR}"
    HOST="${BIND_HOST}" \
    PORT="${PORT}" \
    BROWSER=none \
    WDS_SOCKET_PORT="${PORT}" \
    nohup npm start >"${LOG_FILE}" 2>&1 &
    printf '%s\n' "$!" >"${PID_FILE}"
  )
}

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required for the frontend dev health check."
  exit 1
fi

if ! is_dev_server_running; then
  if port_has_listener; then
    echo "Frontend dev server health check failed on port ${PORT}, but the port is already in use."
    echo "This script will not stop or replace an existing process."
    echo "Inspect the listener with: ss -ltnp 'sport = :${PORT}'"
    echo "If the shared dev server is broken, fix or restart it from the canonical checkout: ${ROOT_DIR}"
    exit 1
  fi

  start_dev_server

  for _ in $(seq 1 60); do
    if is_dev_server_running; then
      break
    fi
    sleep 1
  done
fi

if ! is_dev_server_running; then
  echo "Frontend dev server did not become ready on port ${PORT}."
  echo "Last log lines from ${LOG_FILE}:"
  tail -n 80 "${LOG_FILE}" 2>/dev/null || true
  exit 1
fi

PUBLIC_HOST="$(detect_public_host)"
if [[ -z "${PUBLIC_HOST}" ]]; then
  PUBLIC_HOST="127.0.0.1"
fi

echo "Frontend dev server is active."
echo "Project: ${PROJECT_NAME}"
echo "Mode: shared singleton Create React App dev server"
echo "Source root: ${ROOT_DIR}"
if [[ "${SCRIPT_ROOT}" != "${ROOT_DIR}" ]]; then
  echo "Requested from: ${SCRIPT_ROOT}"
  echo "Using canonical checkout so task worktrees do not start separate dev servers."
fi
echo "Open: http://${PUBLIC_HOST}:${PORT}"
echo "Local health check: ${HEALTH_URL}"
echo "Log: ${LOG_FILE}"
print_firewall_status
