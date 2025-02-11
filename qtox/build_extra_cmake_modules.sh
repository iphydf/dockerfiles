#!/usr/bin/env bash

# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright © 2024-2025 The TokTok team

set -euxo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "$0")")"

source "$SCRIPT_DIR/build_utils.sh"

parse_arch --dep "extra-cmake-modules" --supported "linux-x86_64 win32 win64 macos-x86_64 macos-arm64 wasm" "$@"

"$SCRIPT_DIR/download/download_extra_cmake_modules.sh"

"${EMCMAKE[@]}" cmake -DCMAKE_INSTALL_PREFIX="$DEP_PREFIX" \
  -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -DBUILD_TESTING=OFF \
  -GNinja \
  -B_build \
  .
cmake --build _build
cmake --install _build
