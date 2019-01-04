#!/bin/bash

set -e

# export OPENSSL_VERSION="openssl-1.0.2o"
curl -O "https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz"
tar xfz "${OPENSSL_VERSION}.tar.gz"

OPENSSL_CONFIG_OPTIONS=$(cat config-params.txt)

OUTPUT_DIR="libs/linux"

# Clean output:
rm -rf $OUTPUT_DIR
mkdir $OUTPUT_DIR

build_linux() {
  ARCH=$1
  echo "Building linux libcrypto.a & libssl.so for ${ARCH}"

	cd "${OPENSSL_VERSION}"

  # Config:
  ./Configure dist

  if [[ $ARCH == "x86_64" || $ARCH == "amd64" ]]; then
    ./config ${OPENSSL_CONFIG_OPTIONS} -fPIC shared threads no-asm no-sse2
  else
    setarch i386 ./config ${OPENSSL_CONFIG_OPTIONS} -m32 -fPIC
  fi

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

  mkdir ../${OUTPUT_DIR}/${ARCH}

  cp libcrypto.a ../${OUTPUT_DIR}/${ARCH}/libcrypto.a
  cp libssl.a ../${OUTPUT_DIR}/${ARCH}/libssl.a
  cp libcrypto.so ../${OUTPUT_DIR}/${ARCH}/libcrypto.so
  cp libssl.so ../${OUTPUT_DIR}/${ARCH}/libssl.so


  # Cleanup:
  make clean
  cd ..
}

build_linux "x86"
build_linux "x86_64"
build_linux "amd64"

