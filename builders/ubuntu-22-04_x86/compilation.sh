#!/usr/bin/env bash

set -o errexit  # Exit script on any error
set -o nounset  # Treat unset variables as errors
set -o xtrace   # Trace what gets executed (for debugging)

# Define default versions

rippled_version=${RIPPLED_VERSION:-2.2.3}
rippled_hash="34f8a703765caba0cd21b3e703c2c225a2634c5cfde5239c74921721f1d02cf3"

# Download Rippled sources
curl -sL -o rippled-${rippled_version}.tar.gz \
  "https://github.com/XRPLF/rippled/archive/refs/tags/${rippled_version}.tar.gz"
downloaded_rippled_hash=$(sha256sum rippled-${rippled_version}.tar.gz | awk '{print $1}')

if [ "$downloaded_rippled_hash" = "$rippled_hash" ]; then
  mkdir -p /build
  tar -xzvf rippled-${rippled_version}.tar.gz -C /build
else
  exit 1
fi
rm -rf rippled-${rippled_version}.tar.gz

cd /build/rippled-${rippled_version}
mkdir .build
cd .build
conan install .. --output-folder . --build missing --settings build_type=Release
cmake -DCMAKE_TOOLCHAIN_FILE:FILEPATH=build/generators/conan_toolchain.cmake -Dxrpld=ON -Dtests=ON  ..
cmake --build . --config Release -j$(nproc)