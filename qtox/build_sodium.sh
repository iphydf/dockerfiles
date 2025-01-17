#!/usr/bin/env bash

# SPDX-License-Identifier: GPL-3.0-or-later AND MIT
# Copyright © 2017-2021 Maxim Biro <nurupo.contributions@gmail.com>
# Copyright © 2021 by The qTox Project Contributors
# Copyright © 2024-2025 The TokTok team

set -euxo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "$0")")"

source "$SCRIPT_DIR/build_utils.sh"

parse_arch --dep "sodium" --supported "linux-x86_64 win32 win64 macos-x86_64 macos-arm64" "$@"

if [ "$LIB_TYPE" = "shared" ]; then
  ENABLE_STATIC=--disable-static
  ENABLE_SHARED=--enable-shared
else
  ENABLE_STATIC=--enable-static
  ENABLE_SHARED=--disable-shared
fi

"$SCRIPT_DIR/download/download_sodium.sh"

RENAME_CFLAGS=""
for sym in blake2b blake2b_final blake2b_init blake2b_init_key blake2b_init_param blake2b_update; do
  RENAME_CFLAGS="$RENAME_CFLAGS -D$sym=sodium_$sym"
done

CFLAGS="-O3 $CROSS_CFLAG $RENAME_CFLAGS" \
  LDFLAGS="$CROSS_LDFLAG -fstack-protector" \
  ./configure "$HOST_OPTION" \
  --prefix="$DEP_PREFIX" \
  "$ENABLE_STATIC" \
  "$ENABLE_SHARED"

make -j "$MAKE_JOBS"
make install
