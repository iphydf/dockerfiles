#!/bin/bash

#    Copyright © 2021 by The qTox Project Contributors
#
#    This program is libre software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -euo pipefail

readonly SCRIPT_DIR="$(dirname "$(realpath "$0")")"

SUDO=("$@")

build_toxcore() {
  mkdir -p toxcore
  pushd toxcore >/dev/null || exit 1

  "$SCRIPT_DIR/download/download_toxcore.sh"

  cmake . \
    -DBOOTSTRAP_DAEMON=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    .

  cmake --build . -- -j"$(nproc)"
  "${SUDO[@]}" cmake --build . --target install

  popd >/dev/null
}

build_toxcore
