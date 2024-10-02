#!/usr/bin/env bash

set -o errexit  # Exit script on any error
set -o nounset  # Treat unset variables as errors
set -o xtrace   # Trace what gets executed (for debugging)

export PATH="/opt/cmake-${CMAKE_VERSION}-linux-x86_64/bin:$PATH"

# Download Rippled sources
curl -sL -o rippled-${RIPPLED_VERSION}.tar.gz \
  "https://github.com/XRPLF/rippled/archive/refs/tags/${RIPPLED_VERSION}.tar.gz"
downloaded_rippled_hash=$(sha256sum rippled-${RIPPLED_VERSION}.tar.gz | awk '{print $1}')

if [ "$downloaded_rippled_hash" = "$RIPPLED_HASH" ]; then
  mkdir -p /build
  tar -xzvf rippled-${RIPPLED_VERSION}.tar.gz -C /build
else
  exit 1
fi
rm -rf rippled-${RIPPLED_VERSION}.tar.gz

cd /build/rippled-${RIPPLED_VERSION}
mkdir .build
cd .build
conan install .. --output-folder . --build missing --settings build_type=Release
cmake -DCMAKE_TOOLCHAIN_FILE:FILEPATH=build/generators/conan_toolchain.cmake -Dxrpld=ON -Dtests=ON  ..
cmake --build . --config Release -j$(nproc)