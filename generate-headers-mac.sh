#!/bin/bash

set -e

# export OPENSSL_VERSION="openssl-1.0.2o"
curl -O "https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz"
tar xfz "${OPENSSL_VERSION}.tar.gz"

rm -rf libs/include

cd "${OPENSSL_VERSION}"

# Clean:
make clean

# Generate headers:
./Configure dist

# Copy headers resolving symbolic links to files' content:
cp -r include ../libs

# Clean:
make clean

cd ../

exit 0
