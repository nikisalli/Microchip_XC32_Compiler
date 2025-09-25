#!/usr/bin/env bash
set -euo pipefail

SCRIPT_TO_RUN=${SCRIPT_TO_RUN:-both}
BUILD_BOTH=${BUILD_BOTH:-1}

export WINE_BIN=${WINE_BIN:-/usr/bin/wine64}
export WINE=${WINE:-/usr/bin/wine64}
export PATH=/usr/bin:/bin:${PATH}

export WINEPATH=${WINEPATH:-Z:\\usr\\x86_64-w64-mingw32\\bin}

echo "[xc32-builder] Starting build. SCRIPT_TO_RUN=${SCRIPT_TO_RUN} BUILD_BOTH=${BUILD_BOTH}"

cd /workspace

export STATIC_LINK=${STATIC_LINK:-1}

echo "[xc32-builder] PATH=${PATH}"
echo "[xc32-builder] wine path: $(command -v wine || echo 'not found')"
echo "[xc32-builder] wine64 path: $(command -v wine64 || echo 'not found')"
if command -v wine64 >/dev/null 2>&1; then /usr/bin/wine64 --version || true; fi

if [[ "${BUILD_BOTH}" = "1" || "${SCRIPT_TO_RUN}" = "both" ]]; then
  echo "[xc32-builder] Building pic32m variant..."
  time bash ./build-xc32-v4.35m_relative_paths_WORKED_ON_WINDOWS.sh
  echo "[xc32-builder] Building pic32c variant..."
  time bash ./build-xc32-v4.35c_relative_paths_WORKED_ON_WINDOWS.sh
else
  echo "[xc32-builder] Building single variant via ${SCRIPT_TO_RUN}..."
  time bash "${SCRIPT_TO_RUN}"
fi

echo "[xc32-builder] Build complete. Preparing artifacts..."

FINAL_BIN_DIR="/workspace/xc32-v4.35-src/installed/opt/bin/bin"
if [[ ! -d "${FINAL_BIN_DIR}" ]]; then
  echo "[xc32-builder] ERROR: Expected output directory not found: ${FINAL_BIN_DIR}" >&2
  exit 1
fi

mkdir -p /out

for path in /out/*; do
  base="$(basename "$path")"
  if [[ "$base" != "bin" ]]; then
    rm -rf "$path"
  fi
done

rsync -a --delete "${FINAL_BIN_DIR}/" /out/bin/

echo "[xc32-builder] Artifacts available in /out: /out/bin/"

echo "[xc32-builder] Done."
