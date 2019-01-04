#!/bin/bash

#set -v

# export OPENSSL_VERSION="openssl-1.0.2o"
curl -O "https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz"
tar xfz "${OPENSSL_VERSION}.tar.gz"

PROJECT_HOME=`pwd`
PATH_ORG=$PATH
OUTPUT_DIR="libs/android/clang"

# Clean output:
rm -rf $OUTPUT_DIR
mkdir $OUTPUT_DIR

build_android_clang() {

	echo ""
	echo "----- Build libcrypto & libssl.so for "$1" -----"
	echo ""

	ARCHITECTURE=$1
	ARCH=$2
	PLATFORM=$3
	TOOLCHAIN=$4
	CONFIGURE_PLATFORM=$5
	TOOLCHAIN_DIR="./toolchain/"$ARCH
	stl="libc++"

	# Build toolchain
	$ANDROID_NDK_HOME/build/tools/make-standalone-toolchain.sh --verbose --stl=$stl --arch=$ARCH --install-dir=$TOOLCHAIN_DIR --platform=$PLATFORM --force

	# Set toolchain
	export TOOLCHAIN_ROOT=$PROJECT_HOME/$TOOLCHAIN_DIR
	export SYSROOT=$TOOLCHAIN_ROOT/sysroot
	export CC=$TOOLCHAIN-clang
	export CXX=$TOOLCHAIN-clang++
	export AR=$TOOLCHAIN-ar
	export AS=$TOOLCHAIN-as
	export LD=$TOOLCHAIN-ld
	export RANLIB=$TOOLCHAIN-ranlib
	export NM=$TOOLCHAIN-nm
	export STRIP=$TOOLCHAIN-strip
	export CHOST=$TOOLCHAIN
	export CXXFLAGS="-std=c++11 -fPIC"
	export CPPFLAGS="-DANDROID -fPIC"
	export PATH=$PATH_ORG:$TOOLCHAIN_ROOT/bin:$SYSROOT/usr/local/bin

	# Clean openssl:
	cd "${OPENSSL_VERSION}"
	make clean

	# Build openssl libraries
	perl -pi -w -e 's/\-mandroid//g;' ./Configure
	./Configure $CONFIGURE_PLATFORM shared threads no-asm no-sse2

    # patch SONAME
    perl -pi -e 's/SHLIB_EXT=\.so\.\$\(SHLIB_MAJOR\)\.\$\(SHLIB_MINOR\)/SHLIB_EXT=\.so/g' Makefile
    perl -pi -e 's/SHARED_LIBS_LINK_EXTS=\.so\.\$\(SHLIB_MAJOR\) \.so//g' Makefile
    # quote injection for proper SONAME
    perl -pi -e 's/SHLIB_MAJOR=1/SHLIB_MAJOR=`/g' Makefile
    perl -pi -e 's/SHLIB_MINOR=0.0/SHLIB_MINOR=`/g' Makefile

    make build_libs -j8
	mkdir -p ../$OUTPUT_DIR/${ARCHITECTURE}/

    file libcrypto.so
    file libssl.so

    cp libcrypto.a ../$OUTPUT_DIR/${ARCHITECTURE}/libcrypto.a
	cp libssl.a ../$OUTPUT_DIR/${ARCHITECTURE}/libssl.a
	cp libcrypto.so ../$OUTPUT_DIR/${ARCHITECTURE}/libcrypto.so
	cp libssl.so ../$OUTPUT_DIR/${ARCHITECTURE}/libssl.so
	cd ..
}

# Build libcrypto for armeabi-v7a, x86 and arm64-v8a.
build_android_clang "armeabi-v7a" "arm"   "android-16" "arm-linux-androideabi" "android-armv7"
build_android_clang "x86"         "x86"   "android-16" "i686-linux-android"    "android-x86"
build_android_clang "arm64-v8a"   "arm64" "android-21" "aarch64-linux-android" "linux-generic64 -DB_ENDIAN"

export PATH=$PATH_ORG

exit 0
