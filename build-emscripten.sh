#!/bin/bash

set -e

# export OPENSSL_VERSION="openssl-1.0.2o"
curl -O "https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz"
tar xfz "${OPENSSL_VERSION}.tar.gz"

OPENSSL_CONFIG_OPTIONS=$(cat config-params-emscripten.txt)

OUTPUT_DIR="libs/wasm"
export CC=emcc
export CXX=emcc
export LINK=${CXX}
export ARCH_FLAGS=""
export ARCH_LINK=""
export CPPFLAGS=" ${ARCH_FLAGS} "
export CXXFLAGS=" ${ARCH_FLAGS} "
export CFLAGS=" ${ARCH_FLAGS} "
export LDFLAGS=" ${ARCH_LINK} "

# Clean output:
rm -rf $OUTPUT_DIR
mkdir $OUTPUT_DIR

build_webassembly() {
  echo "Building libcrypto.a & libssl.so for WebAssembly"

  cd "${OPENSSL_VERSION}"

  # Config:
  ./Configure dist

  ./config ${OPENSSL_CONFIG_OPTIONS} -fPIC shared no-threads no-asm no-sse2

  # Remove test
  rm -rf test

  # Make depend:
  make depend -j8

  # Make libcrypto:
  make build_libs -j8

  # Copy libcrypto.a to temp output directory:
  file libcrypto.a
  file libcrypto.so
  file libcrypto.so
  file libssl.so

  #mkdir ../${OUTPUT_DIR}

  cp libcrypto.a ../${OUTPUT_DIR}/libcrypto.a
  cp libssl.a ../${OUTPUT_DIR}/libssl.a
  cp libcrypto.so ../${OUTPUT_DIR}/libcrypto.so
  cp libssl.so ../${OUTPUT_DIR}/libssl.so

  # Cleanup:
  make clean
  cd ..
}

build_webassembly
