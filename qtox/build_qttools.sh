#!/usr/bin/env bash

# SPDX-License-Identifier: GPL-3.0-or-later AND MIT
# Copyright © 2017-2021 Maxim Biro <nurupo.contributions@gmail.com>
# Copyright © 2021 by The qTox Project Contributors
# Copyright © 2024-2025 The TokTok team

set -euxo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "$0")")"

source "$SCRIPT_DIR/build_utils.sh"

parse_arch --dep "qttools" --supported "linux-x86_64 macos-arm64 macos-x86_64 win32 win64 wasm" "$@"

"$SCRIPT_DIR/download/download_qttools.sh"

mkdir _build && pushd _build
"$QT_PREFIX/bin/qt-configure-module" .. \
  -no-feature-assistant \
  -no-feature-designer \
  -no-feature-kmap2qmap \
  -no-feature-pixeltool \
  -no-feature-qdbus \
  -no-feature-qdoc \
  -no-feature-qev \
  -no-feature-qtattributionsscanner \
  -no-feature-qtdiag \
  -no-feature-qtplugininfo \
  -- \
  -DCMAKE_FIND_ROOT_PATH="$DEP_PREFIX" \
  -DCMAKE_CXX_FLAGS="-DQT_MESSAGELOGCONTEXT" \
  -Wno-dev
cmake --build .
cmake --install .
popd
