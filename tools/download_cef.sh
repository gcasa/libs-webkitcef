#!/usr/bin/env bash
set -e

# Ensure necessary tools
command -v git >/dev/null 2>&1 || { echo >&2 "git is required."; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo >&2 "python3 is required."; exit 1; }
command -v cmake >/dev/null 2>&1 || { echo >&2 "cmake is required."; exit 1; }

# Configuration
WORKDIR="$PWD/cef_build"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "Cloning cef-project..."
git clone https://bitbucket.org/chromiumembedded/cef-project.git
cd cef-project

# Configure CMake to fetch the latest CEF binary and build sample
mkdir -p build && cd build
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release ..
make -j4 cefsimple

echo "Downloaded and unpacked latest CEF binaries."
echo "Build output in: $(pwd)"

exit 0
