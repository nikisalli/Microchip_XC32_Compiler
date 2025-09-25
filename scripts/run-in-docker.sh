#!/usr/bin/env bash
set -euo pipefail

# Simple wrapper to build the image and run the build, mounting ./out for artifacts

IMAGE_TAG=${IMAGE_TAG:-xc32-builder:latest}

SCRIPT_TO_RUN=${SCRIPT_TO_RUN:-both}
BUILD_BOTH=${BUILD_BOTH:-1}
OUT_DIR=${OUT_DIR:-"$(pwd)/out"}

mkdir -p "${OUT_DIR}"

if [ "${SKIP_BUILD:-0}" != "1" ]; then
  echo "[run-in-docker] Building image ${IMAGE_TAG}..."
  docker build -t "${IMAGE_TAG}" -f Dockerfile .
else
  echo "[run-in-docker] Skipping docker build (SKIP_BUILD=1). Using existing image ${IMAGE_TAG}."
fi

echo "[run-in-docker] Running build inside container (SCRIPT_TO_RUN=${SCRIPT_TO_RUN}, BUILD_BOTH=${BUILD_BOTH})..."
docker run --rm \
  -e SCRIPT_TO_RUN="${SCRIPT_TO_RUN}" \
  -e BUILD_BOTH="${BUILD_BOTH}" \
  -e STATIC_LINK=${STATIC_LINK:-1} \
  -e WINE_BIN=${WINE_BIN:-wine} \
  -v "${OUT_DIR}:/out" \
  "${IMAGE_TAG}"

echo "[run-in-docker] Done. Artifacts in: ${OUT_DIR}"
