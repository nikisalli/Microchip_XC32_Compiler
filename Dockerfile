FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Base dependencies and toolchain for cross-compiling to Windows (x86_64-w64-mingw32)
# + build-time libs for GCC (gmp/mpfr/mpc), and tools used by the build scripts.
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      build-essential \
      git \
      curl \
      wget \
      xz-utils \
      unzip \
      dos2unix \
      patch \
      zstd \
      pkg-config \
      texinfo \
      bison \
      flex \
      gawk \
      gperf \
      perl \
      python3 \
      file \
      libgmp-dev \
      libmpfr-dev \
      libmpc-dev \
      zlib1g-dev \
      rsync \
      # MinGW-w64 cross toolchain and pkg-config
      mingw-w64 \
      binutils-mingw-w64-x86-64 \
      gcc-mingw-w64-x86-64 \
      g++-mingw-w64-x86-64 \
      mingw-w64-tools \
      # Wine (both 64-bit and 32-bit userspace) for running Windows-built drivers
      wine \
      wine64 \
      wine32:i386 && \
    rm -rf /var/lib/apt/lists/*

# Reduce Wine noise in logs and default to wine64 for 64-bit tools
ENV WINEDEBUG=-all \
    WINE_BIN=wine64

# Provide 'wine' shims for tools/scripts that call 'wine' explicitly.
# Some build steps ignore WINE_BIN and use 'wine'; ensure it resolves via PATHs
# that commonly include only /usr/bin and /bin.
RUN ln -sf /usr/bin/wine64 /usr/bin/wine && \
    ln -sf /usr/bin/wine64 /usr/local/bin/wine || true && \
    ln -sf /usr/bin/wine64 /bin/wine || true

# Set up a build workspace inside the container
WORKDIR /workspace

# Provision prebuilt libiconv for the Windows (mingw-w64) host from MSYS2.
# This is much faster than building from source and is cached before copying
# the repo contents.
ARG MSYS2_BASE_URL=https://mirror.msys2.org/mingw/x86_64
ARG MINGW_LIBICONV_PKG=mingw-w64-x86_64-libiconv-1.17-3-any.pkg.tar.zst
RUN set -eux; \
    tmp="$(mktemp -d)"; \
    cd "$tmp"; \
    for base in "$MSYS2_BASE_URL" \
                https://repo.msys2.org/mingw/x86_64 \
                https://mirror.yandex.ru/mirrors/msys2/mingw/x86_64; do \
      if curl -LfsS -O "$base/$MINGW_LIBICONV_PKG"; then echo "Fetched: $base/$MINGW_LIBICONV_PKG"; break; fi; \
    done; \
    [ -s "$MINGW_LIBICONV_PKG" ]; \
    mkdir -p extract; \
    tar --zstd -xf "$MINGW_LIBICONV_PKG" -C extract; \
    # Copy into the mingw-w64 sysroot used by cross tools
    mkdir -p /usr/x86_64-w64-mingw32/{bin,include,lib,share}; \
    if [ -d extract/mingw64/bin ]; then cp -a extract/mingw64/bin/. /usr/x86_64-w64-mingw32/bin/; fi; \
    if [ -d extract/mingw64/include ]; then cp -a extract/mingw64/include/. /usr/x86_64-w64-mingw32/include/; fi; \
    if [ -d extract/mingw64/lib ]; then cp -a extract/mingw64/lib/. /usr/x86_64-w64-mingw32/lib/; fi; \
    if [ -d extract/mingw64/share ]; then cp -a extract/mingw64/share/. /usr/x86_64-w64-mingw32/share/; fi; \
    # Show what was installed (debugging aid)
    ls -l /usr/x86_64-w64-mingw32/bin || true; \
    ls -l /usr/x86_64-w64-mingw32/lib | head -n 50 || true; \
    rm -rf "$tmp"

# Copy repository contents (including sources under xc32-v4.35-src)
COPY . /workspace

# Provide a default output directory inside the container. At runtime,
# mount a host directory to /out to retrieve artifacts.
RUN mkdir -p /out

# Entrypoint runs the provided build script and exports the final bin folder
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
