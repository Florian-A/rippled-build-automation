#!/usr/bin/env bash

set -o errexit  # Exit script on any error
set -o nounset  # Treat unset variables as errors
set -o xtrace   # Trace what gets executed (for debugging)

# Define default versions

rippled_version=${RIPPLED_VERSION:-2.2.3}
rippled_hash="d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed"

# Download Rippled sources
curl -sL -o rippled-${rippled_hash}.tar.gz \
  "https://github.com/XRPLF/rippled/archive/refs/tags/${rippled_hash}.tar.gz"
downloaded_rippled_hash=$(sha256sum rippled-${rippled_hash}.tar.gz | awk '{print $1}')

if [ "$downloaded_rippled_hash" = "$rippled_hash" ]; then
  tar -xzvf rippled-${rippled_hash}.tar.gz -C /build
else
  exit 1
fi
rm -rf rippled-${rippled_hash}.tar.gz

cd /build/rippled-${rippled_hash}
mkdir .build
cd .build
conan install .. --output-folder . --build missing --settings build_type=Release
cmake -DCMAKE_TOOLCHAIN_FILE:FILEPATH=build/generators/conan_toolchain.cmake -Dxrpld=ON -Dtests=ON  ..
cmake --build . --config Release -j$(nproc)