#!/usr/bin/env bash

set -o errexit  # Exit script on any error
set -o nounset  # Treat unset variables as errors
set -o xtrace   # Trace what gets executed (for debugging)

# Update package list
apt update

# Install timezone data non-interactively
DEBIAN_FRONTEND=noninteractive apt install --yes --no-install-recommends tzdata

# Define common dependencies
dependencies=(
    lsb-release         # Identify Ubuntu version
    curl                # Download tools (e.g. CMake)
    libssl-dev          # Required for building CMake
    python3.10-dev      # Python headers for Boost.Python
    python3-pip         # Install Conan and Python tools
    git                 # For downloading repositories
    make ninja-build    # CMake generators
    gcc-${GCC_VERSION} g++-${GCC_VERSION}  # GCC compilers
    flex bison graphviz plantuml  # Documentation tools
)

# Install dependencies
apt install --yes "${dependencies[@]}"

# Set up GCC versioning aliases
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VERSION} 100 \
  --slave /usr/bin/g++ g++ /usr/bin/g++-${GCC_VERSION}
update-alternatives --auto gcc

# Update cpp alternative separately
update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-${GCC_VERSION} 100
update-alternatives --auto cpp

# Get Ubuntu codename (e.g., focal, bionic)
ubuntu_codename=$(lsb_release --short --codename)

# Add Clang repository and GPG key
curl -s https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
echo "deb https://apt.llvm.org/${ubuntu_codename}/ llvm-toolchain-${ubuntu_codename}-${CLANG_VERSION} main" \
  > /etc/apt/sources.list.d/llvm.list

# Update package list and install Clang and related tools
apt update
apt install --yes clang-${CLANG_VERSION} clang-tidy-${CLANG_VERSION} clang-format-${CLANG_VERSION} \
  libclang-${CLANG_VERSION}-dev

# Clean up package cache
apt clean

# Set up Clang versioning aliases
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${CLANG_VERSION} 100 \
  --slave /usr/bin/clang++ clang++ /usr/bin/clang++-${CLANG_VERSION}
update-alternatives --auto clang

# Install CMake
curl -sL -o cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz \
  "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz"
downloaded_cmake_hash=$(sha256sum cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz | awk '{print $1}')

if [ "$downloaded_cmake_hash" = "$CMAKE_HASH" ]; then
  tar -xzvf cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz -C /opt
else
  exit 1
fi
rm -rf cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz

# Install Conan and configure
pip3 --no-cache-dir install conan==${CONAN_VERSION}
conan profile new default --detect
conan profile update settings.compiler.cppstd=20 default
conan config set general.revisions_enabled=1
conan profile update settings.compiler.libcxx=libstdc++11 default
conan profile update 'conf.tools.build:cxxflags+=["-DBOOST_BEAST_USE_STD_STRING_VIEW"]' default
conan profile update 'env.CXXFLAGS="-DBOOST_BEAST_USE_STD_STRING_VIEW"' default

# Install Gcovr
pip3 --no-cache-dir install gcovr==${GCOVR_VERSION}