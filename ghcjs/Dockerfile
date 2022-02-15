FROM ubuntu:20.04

RUN apt-get update \
 && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
 build-essential \
 ca-certificates \
 cmake \
 curl \
 git \
 libffi-dev \
 libgmp10 \
 libgmp-dev \
 libncurses-dev \
 libtinfo-dev \
 ninja-build \
 pkg-config \
 python \
 sudo \
 xz-utils \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /work
RUN useradd \
 --create-home \
 --gid users \
 --groups sudo \
 --uid 1001 \
 builder \
 && chown builder:users /work \
 && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER builder

RUN ["git", "clone", "--depth=1", "https://github.com/emscripten-core/emsdk", "/home/builder/emsdk"]
WORKDIR /home/builder/emsdk
RUN ./emsdk install latest \
 && ./emsdk activate latest

ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

RUN ["git", "clone", "--depth=1", "--recurse-submodules", "--shallow-submodules", "https://github.com/ghcjs/ghcjs.git", "/work/ghcjs"]
WORKDIR /work/ghcjs
ENV PATH=$PATH:/home/builder/.local/bin:/home/builder/.ghcup/bin
RUN grep ghc/utils/unlit/fs.h *
RUN cabal v2-install --overwrite-policy=always --install-method=copy --installdir=inplace/bin

RUN source ~/emsdk/emsdk_env.sh
