#!/usr/bin/env bash

set -o errexit  # Exit script on any error
set -o nounset  # Treat unset variables as errors
set -o xtrace   # Trace what gets executed (for debugging)

# Define default versions
gcc_version=${GCC_VERSION:-11}
clang_version=${CLANG_VERSION:-14}
doxygen_version=${DOXYGEN_VERSION:-1.9.5}
conan_version=${CONAN_VERSION:-1.60.0}
gcovr_version=${GCOVR_VERSION:-6.0}
cmake_version=${CMAKE_VERSION:-3.25.1}
cmake_hash="3a5008b613eeb0724edeb3c15bf91d6ce518eb8eebc6ee758f89a0f4ff5d1fd6"

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
    gcc-${gcc_version} g++-${gcc_version}  # GCC compilers
    flex bison graphviz plantuml  # Documentation tools
)

# Install dependencies
apt install --yes "${dependencies[@]}"

# Set up GCC versioning aliases
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${gcc_version} 100 \
  --slave /usr/bin/g++ g++ /usr/bin/g++-${gcc_version}
update-alternatives --auto gcc

# Update cpp alternative separately
update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-${gcc_version} 100
update-alternatives --auto cpp

# Get Ubuntu codename (e.g., focal, bionic)
ubuntu_codename=$(lsb_release --short --codename)

# Add Clang repository and GPG key
curl -s https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
echo "deb https://apt.llvm.org/${ubuntu_codename}/ llvm-toolchain-${ubuntu_codename}-${clang_version} main" \
  > /etc/apt/sources.list.d/llvm.list

# Update package list and install Clang and related tools
apt update
apt install --yes clang-${clang_version} clang-tidy-${clang_version} clang-format-${clang_version} \
  libclang-${clang_version}-dev

# Clean up package cache
apt clean

# Set up Clang versioning aliases
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${clang_version} 100 \
  --slave /usr/bin/clang++ clang++ /usr/bin/clang++-${clang_version}
update-alternatives --auto clang

# Install CMake
curl -sL -o cmake-${cmake_version}-linux-x86_64.tar.gz \
  "https://github.com/Kitware/CMake/releases/download/v${cmake_version}/cmake-${cmake_version}-linux-x86_64.tar.gz"
downloaded_cmake_hash=$(sha256sum cmake-${cmake_version}-linux-x86_64.tar.gz | awk '{print $1}')

if [ "$downloaded_cmake_hash" = "$cmake_hash" ]; then
  tar -xzvf cmake-${cmake_version}-linux-x86_64.tar.gz -C /opt
else
  exit 1
fi
rm -rf cmake-${cmake_version}-linux-x86_64.tar.gz
export PATH="/opt/cmake-${cmake_version}-linux-x86_64/bin:$PATH"

# Install Conan and configure
pip3 --no-cache-dir install conan==${conan_version}
conan profile new default --detect
conan profile update settings.compiler.cppstd=20 default
conan config set general.revisions_enabled=1
conan profile update settings.compiler.libcxx=libstdc++11 default
conan profile update 'conf.tools.build:cxxflags+=["-DBOOST_BEAST_USE_STD_STRING_VIEW"]' default
conan profile update 'env.CXXFLAGS="-DBOOST_BEAST_USE_STD_STRING_VIEW"' default

# Install Gcovr
pip3 --no-cache-dir install gcovr==${gcovr_version}