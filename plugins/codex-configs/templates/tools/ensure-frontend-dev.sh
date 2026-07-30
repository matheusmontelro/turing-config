#!/usr/bin/env bash
set -euo pipefail

# Template for projects that use a shared frontend dev server, usually Vite.
# Copy to tools/ensure-frontend-dev.sh, make it executable, and replace
# placeholders or configure the environment variables below.

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

default_if_placeholder() {
  local value="${1:-}"
  local fallback="$2"

  if [[ -z "${value}" || "${value}" == \{*\} ]]; then
    printf '%s\n' "${fallback}"
    return
  fi

  printf '%s\n' "${value}"
}

FRONTEND_RELATIVE_DIR="$(default_if_placeholder "${FRONTEND_DEV_FRONTEND_DIR:-{FRONTEND_DIR}}" "frontend")"
CANONICAL_ROOT_CONFIG="$(default_if_placeholder "${FRONTEND_DEV_CANONICAL_ROOT:-{PROJECT_ROOT}}" "")"

if [[ -n "${CANONICAL_ROOT_CONFIG}" && -d "${CANONICAL_ROOT_CONFIG}/${FRONTEND_RELATIVE_DIR}" && -f "${CANONICAL_ROOT_CONFIG}/tools/ensure-frontend-dev.sh" ]]; then
  ROOT_DIR="${CANONICAL_ROOT_CONFIG}"
else
  ROOT_DIR="${SCRIPT_ROOT}"
fi

FRONTEND_DIR="${ROOT_DIR}/${FRONTEND_RELATIVE_DIR}"
PROJECT_NAME="$(default_if_placeholder "${FRONTEND_DEV_PROJECT_NAME:-{PROJECT_NAME}}" "frontend-app")"
DEFAULT_PROJECT_PORT="$(default_if_placeholder "${FRONTEND_DEV_DEFAULT_PORT:-{FRONTEND_DEV_PORT}}" "3000")"
DEFAULT_PUBLIC_HOST="$(default_if_placeholder "${FRONTEND_DEV_DEFAULT_PUBLIC_HOST:-{PUBLIC_DEV_HOST}}" "")"
PORT="${FRONTEND_DEV_PORT:-${VITE_DEV_PORT:-${DEFAULT_PROJECT_PORT}}}"
BIND_HOST="${FRONTEND_DEV_BIND_HOST:-${VITE_DEV_HOST:-0.0.0.0}}"
PROXY_TARGET="$(default_if_placeholder "${VITE_DEV_PROXY_TARGET:-{BACKEND_PROXY_TARGET}}" "http://127.0.0.1:8000")"
START_SCRIPT="${FRONTEND_DEV_NPM_SCRIPT:-dev}"
CUSTOM_START_COMMAND="${FRONTEND_DEV_START_COMMAND:-}"
HEALTH_PATH="${FRONTEND_DEV_HEALTH_PATH:-/@vite/client}"
LOG_DIR="${ROOT_DIR}/.codex/dev-logs"
LOG_FILE="${LOG_DIR}/frontend-dev.log"
PID_FILE="${LOG_DIR}/frontend-dev.pid"
HEALTH_URL="http://127.0.0.1:${PORT}${HEALTH_PATH}"
TMUX_SESSION="${PROJECT_NAME}-frontend-dev-${PORT}"

is_dev_server_running() {
  curl -fsS --max-time 2 "${HEALTH_URL}" >/dev/null 2>&1
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

detect_public_host() {
  if [[ -n "${FRONTEND_DEV_PUBLIC_HOST:-}" ]]; then
    printf '%s\n' "${FRONTEND_DEV_PUBLIC_HOST}"
    return
  fi

  if [[ -n "${DEV_PUBLIC_HOST:-}" ]]; then
    printf '%s\n' "${DEV_PUBLIC_HOST}"
    return
  fi

  if [[ -n "${DEFAULT_PUBLIC_HOST}" ]]; then
    printf '%s\n' "${DEFAULT_PUBLIC_HOST}"
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

build_start_command() {
  local output_log="$1"
  local command

  if [[ -n "${CUSTOM_START_COMMAND}" ]]; then
    printf -v command 'cd %q && FRONTEND_DEV_BIND_HOST=%q FRONTEND_DEV_PORT=%q VITE_DEV_HOST=%q VITE_DEV_PORT=%q VITE_DEV_PROXY_TARGET=%q bash -lc %q >%q 2>&1' \
      "${FRONTEND_DIR}" "${BIND_HOST}" "${PORT}" "${BIND_HOST}" "${PORT}" "${PROXY_TARGET}" "${CUSTOM_START_COMMAND}" "${output_log}"
  else
    printf -v command 'cd %q && VITE_DEV_PROXY_TARGET=%q npm run %q -- --host %q --port %q >%q 2>&1' \
      "${FRONTEND_DIR}" "${PROXY_TARGET}" "${START_SCRIPT}" "${BIND_HOST}" "${PORT}" "${output_log}"
  fi

  printf '%s\n' "${command}"
}

start_dev_server() {
  mkdir -p "${LOG_DIR}"

  if [[ ! -d "${FRONTEND_DIR}" ]]; then
    echo "Frontend directory not found: ${FRONTEND_DIR}"
    echo "Set FRONTEND_DEV_FRONTEND_DIR or FRONTEND_DEV_CANONICAL_ROOT for this project."
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
    if [[ -n "${CUSTOM_START_COMMAND}" ]]; then
      FRONTEND_DEV_BIND_HOST="${BIND_HOST}" \
      FRONTEND_DEV_PORT="${PORT}" \
      VITE_DEV_HOST="${BIND_HOST}" \
      VITE_DEV_PORT="${PORT}" \
      VITE_DEV_PROXY_TARGET="${PROXY_TARGET}" \
      nohup bash -lc "${CUSTOM_START_COMMAND}" >"${LOG_FILE}" 2>&1 &
    else
      VITE_DEV_PROXY_TARGET="${PROXY_TARGET}" \
      nohup npm run "${START_SCRIPT}" -- --host "${BIND_HOST}" --port "${PORT}" >"${LOG_FILE}" 2>&1 &
    fi
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
    echo "Inspect the current listener with: ss -ltnp 'sport = :${PORT}'"
    echo "If the shared dev server is broken, fix or restart it from the canonical checkout: ${ROOT_DIR}"
    exit 1
  fi

  start_dev_server

  for _ in $(seq 1 30); do
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
echo "Mode: shared singleton dev server"
echo "Source root: ${ROOT_DIR}"
if [[ "${SCRIPT_ROOT}" != "${ROOT_DIR}" ]]; then
  echo "Requested from: ${SCRIPT_ROOT}"
  echo "Using canonical checkout so task worktrees do not start separate dev servers."
fi
echo "Open: http://${PUBLIC_HOST}:${PORT}"
echo "Backend proxy target: ${PROXY_TARGET}"
echo "Local health check: ${HEALTH_URL}"
echo "Log: ${LOG_FILE}"
print_firewall_status
