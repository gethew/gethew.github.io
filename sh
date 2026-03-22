#!/usr/bin/env sh
set -eu

existing=$(command -v hew 2>/dev/null || true)
if [ -n "$existing" ]; then
    printf 'hew: already installed at "%s"\n' "$existing"
    exit 0
fi

os=$(uname -s)
case "$os" in
    Linux)  os_name="linux" ;;
    Darwin) os_name="macos" ;;
    *)      printf 'error: unsupported OS "%s"\n' "$os" >&2; exit 1 ;;
esac

machine=$(uname -m)
case "$machine" in
    x86_64|amd64)   arch="x86_64" ;;
    aarch64|arm64)   arch="aarch64" ;;
    armv7l)          arch="arm" ;;
    ppc64le)         arch="powerpc64le" ;;
    riscv64)         arch="riscv64" ;;
    s390x)           arch="s390x" ;;
    i686|i386)       arch="x86" ;;
    *)               printf 'error: unsupported architecture "%s"\n' "$machine" >&2; exit 1 ;;
esac

asset="hew-${arch}-${os_name}.tar.gz"
url="https://github.com/marler8997/hew/releases/latest/download/$asset"

tmpdir=$(mktemp -d)

printf 'hew: downloading %s...\n' "$url"
if command -v curl >/dev/null 2>&1; then
    curl -fL "$url" -o "$tmpdir/$asset"
elif command -v wget >/dev/null 2>&1; then
    wget -q "$url" -O "$tmpdir/$asset"
else
    printf 'error: neither curl nor wget found\n' >&2
    exit 1
fi

printf 'hew: extracting...\n'
tar -xzf "$tmpdir/$asset" -C "$tmpdir"

hew_exe="$tmpdir/hew"
if [ ! -f "$hew_exe" ]; then
    printf 'error: hew not found in archive\n' >&2
    exit 1
fi
chmod +x "$hew_exe"

printf 'hew: installing...\n'
"$hew_exe" install github:marler8997/hew
rm -rf "$tmpdir"
