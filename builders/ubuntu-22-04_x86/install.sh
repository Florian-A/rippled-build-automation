#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

# Parameters
gcc_version=${GCC_VERSION:-11}
clang_version=${CLANG_VERSION:-14}
cmake_version=${CMAKE_VERSION:-3.25.1}
doxygen_version=${DOXYGEN_VERSION:-1.9.5}
conan_version=${CONAN_VERSION:-1.60.0}
gcovr_version=${GCOVR_VERSION:-6.0}

# Do not add a stanza to this script without explaining why it is here.
apt update

# Non-interactively install tzdata.
# https://stackoverflow.com/a/44333806/618906
DEBIAN_FRONTEND=noninteractive apt install --yes --no-install-recommends tzdata
# Iteratively build the list of packages to install so that we can interleave
# the lines with comments explaining their inclusion.
dependencies=''
# - to identify the Ubuntu version
dependencies+=' lsb-release'
# - to download CMake
dependencies+=' curl'
# - to build CMake
dependencies+=' libssl-dev'
# - Python headers for Boost.Python
dependencies+=' python3.10-dev'
# - to install Conan
dependencies+=' python3-pip'
# - to download rippled
dependencies+=' git'
# - CMake generators (but not CMake itself)
dependencies+=' make ninja-build'
# - compilers
dependencies+=" gcc-${gcc_version} g++-${gcc_version}"
# - documentation dependencies
dependencies+=' flex bison graphviz plantuml'
apt install --yes ${dependencies}

# Give us nice unversioned aliases for gcc and company.
update-alternatives --install \
  /usr/bin/gcc gcc /usr/bin/gcc-${gcc_version} 100 \
  --slave /usr/bin/g++ g++ /usr/bin/g++-${gcc_version} \
  --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-${gcc_version} \
  --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-${gcc_version} \
  --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-${gcc_version} \
  --slave /usr/bin/gcov gcov /usr/bin/gcov-${gcc_version} \
  --slave /usr/bin/gcov-tool gcov-tool /usr/bin/gcov-dump-${gcc_version} \
  --slave /usr/bin/gcov-dump gcov-dump /usr/bin/gcov-tool-${gcc_version}
update-alternatives --auto gcc

# The package `gcc` depends on the package `cpp`, but the alternative
# `cpp` is a master alternative already, so it must be updated separately.
update-alternatives --install \
  /usr/bin/cpp cpp /usr/bin/cpp-${gcc_version} 100
update-alternatives --auto cpp

ubuntu_codename=$(lsb_release --short --codename)

# Add sources for Clang.
curl --location https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/llvm.list
deb https://apt.llvm.org/${ubuntu_codename}/ llvm-toolchain-${ubuntu_codename}-${clang_version} main
deb-src https://apt.llvm.org/${ubuntu_codename}/ llvm-toolchain-${ubuntu_codename}-${clang_version} main
EOF
# Enumerate dependencies.
dependencies=''
# - clang, clang++, clang-tidy, clang-format
dependencies+=" clang-${clang_version} clang-tidy-${clang_version} clang-format-${clang_version}"
# - libclang for Doxygen
dependencies+=" libclang-${clang_version}-dev"
apt update
apt install --yes ${dependencies}

# Give us nice unversioned aliases for clang and company.
update-alternatives --install \
  /usr/bin/clang clang /usr/bin/clang-${clang_version} 100 \
  --slave /usr/bin/clang++ clang++ /usr/bin/clang++-${clang_version} \
  --slave /usr/bin/llvm-cov llvm-cov /usr/bin/llvm-cov-${clang_version}
update-alternatives --auto clang
update-alternatives --install \
  /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-${clang_version} 100
update-alternatives --auto clang-tidy
update-alternatives --install \
  /usr/bin/clang-format clang-format /usr/bin/clang-format-${clang_version} 100
update-alternatives --auto clang-format

# Download and install CMake.
curl --location --remote-name "https://github.com/Kitware/CMake/releases/download/v3.30.3/cmake-3.30.3-linux-x86_64.tar.gz"
tar -xzvf cmake-3.30.3-linux-x86_64.tar.gz -C /opt
echo 'export PATH=/opt/cmake-3.30.3-linux-x86_64/bin:$PATH' >> ~/.bashrc
export PATH=/opt/cmake-3.30.3-linux-x86_64/bin:$PATH

# Install Conan.
pip3 --no-cache-dir install conan==${conan_version}

# Configure Conan.
conan profile new default --detect
conan profile update settings.compiler.cppstd=20 default
conan config set general.revisions_enabled=1
conan profile update settings.compiler.libcxx=libstdc++11 default
conan profile update 'conf.tools.build:cxxflags+=["-DBOOST_BEAST_USE_STD_STRING_VIEW"]' default
conan profile update 'env.CXXFLAGS="-DBOOST_BEAST_USE_STD_STRING_VIEW"' default

# Install Gcocr.
pip3 --no-cache-dir install gcovr==${gcovr_version}

# Clean up.
apt clean