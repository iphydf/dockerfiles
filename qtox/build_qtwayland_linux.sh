#!/usr/bin/env bash

# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright © 2024 The TokTok team

set -euxo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "$0")")"

source "$SCRIPT_DIR/build_utils.sh"

parse_arch --dep "qtwayland" --supported "linux" "$@"

"$SCRIPT_DIR/download/download_qtwayland.sh"

export CXXFLAGS="-DQT_MESSAGELOGCONTEXT"
export OBJCXXFLAGS="$CXXFLAGS"

mkdir qtwayland/_build && pushd qtwayland/_build
"$DEP_PREFIX/qt/bin/qt-configure-module" .. \
  -- \
  -Wno-dev
cmake --build .
cmake --install .
popd
