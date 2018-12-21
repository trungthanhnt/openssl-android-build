#!/bin/bash
#
# http://wiki.openssl.org/index.php/Android
#
set -e

# export OPENSSL_VERSION="openssl-1.0.2o"
curl -O "https://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz"
tar xfz "${OPENSSL_VERSION}.tar.gz"

output_dir="libs/android"

# Clean output:
rm -rf $output_dir
mkdir $output_dir

archs=(armeabi armeabi-v7a arm64-v8a mips mips64 x86 x86_64)

openssl_config_options=$(cat config-params.txt)

for arch in ${archs[@]}; do
    xLIB="/lib"
    case ${arch} in
        "armeabi")
            _ANDROID_API="android-19"
            _ANDROID_TARGET_SELECT=arch-arm
            _ANDROID_ARCH=arch-arm
            _ANDROID_EABI=arm-linux-androideabi-4.9
            configure_platform="android" ;;
        "armeabi-v7a")
            _ANDROID_API="android-19"
            _ANDROID_TARGET_SELECT=arch-arm
            _ANDROID_ARCH=arch-arm
            _ANDROID_EABI=arm-linux-androideabi-4.9
            configure_platform="android-armv7" ;;
        "arm64-v8a")
            _ANDROID_API="android-21"
            _ANDROID_TARGET_SELECT=arch-arm64-v8a
            _ANDROID_ARCH=arch-arm64
            _ANDROID_EABI=aarch64-linux-android-4.9
            #no xLIB="/lib64"
            configure_platform="linux-generic64 -DB_ENDIAN" ;;
        "mips")
            _ANDROID_API="android-19"
            _ANDROID_TARGET_SELECT=arch-mips
            _ANDROID_ARCH=arch-mips
            _ANDROID_EABI=mipsel-linux-android-4.9
            configure_platform="android -DB_ENDIAN" ;;
        "mips64")
            _ANDROID_API="android-21"
            _ANDROID_TARGET_SELECT=arch-mips64
            _ANDROID_ARCH=arch-mips64
            _ANDROID_EABI=mips64el-linux-android-4.9
            xLIB="/lib64"
            configure_platform="linux-generic64 -DB_ENDIAN" ;;
        "x86")
            _ANDROID_API="android-19"
            _ANDROID_TARGET_SELECT=arch-x86
            _ANDROID_ARCH=arch-x86
            _ANDROID_EABI=x86-4.9
            configure_platform="android-x86" ;;
        "x86_64")
            _ANDROID_API="android-21"
            _ANDROID_TARGET_SELECT=arch-x86_64
            _ANDROID_ARCH=arch-x86_64
            _ANDROID_EABI=x86_64-4.9
            xLIB="/lib64"
            configure_platform="linux-generic64" ;;
        *)
            configure_platform="linux-elf" ;;
    esac

    mkdir "$output_dir/${arch}"

    . ./build-android-setenv.sh

    echo "CROSS COMPILE ENV : $CROSS_COMPILE"

    # Clean openssl:
	cd "${OPENSSL_VERSION}"
	make clean

    xCFLAGS="-fPIC -I$ANDROID_DEV/include -B$ANDROID_DEV/$xLIB"

    # We do not need this as we are not going to install anything (Pasin):
    #perl -pi -e 's/install: all install_docs install_sw/install: install_docs install_sw/g' Makefile.org

    ./Configure dist
    ./Configure shared threads no-asm no-sse2 --openssldir=/tmp/openssl_android/ $configure_platform $xCFLAGS

    # We need to patch this as we are building both static and dynamic libraries:
    # patch .SO NAME
    perl -pi -e 's/SHLIB_EXT=\.so\.\$\(SHLIB_MAJOR\)\.\$\(SHLIB_MINOR\)/SHLIB_EXT=\.so/g' Makefile
    perl -pi -e 's/SHARED_LIBS_LINK_EXTS=\.so\.\$\(SHLIB_MAJOR\) \.so//g' Makefile
    # quote injection for proper .SO NAME
    perl -pi -e 's/SHLIB_MAJOR=1/SHLIB_MAJOR=`/g' Makefile
    perl -pi -e 's/SHLIB_MINOR=0.0/SHLIB_MINOR=`/g' Makefile

    # After disabling some feature, those features are still referenced in test.
    # As a result, make depend (which also make depend on test files) has errors.
    # Couldn't find a right way to disable building test so deleting the test folder
    # as a workaround for now (Pasin):
    rm -rf test

    make clean
    make depend -j8
    make build_libs -j8

    file libcrypto.so
    file libssl.so

    cp libcrypto.a ../$output_dir/${arch}/libcrypto.a
	cp libssl.a ../$output_dir/${arch}/libssl.a
	cp libcrypto.so ../$output_dir/${arch}/libcrypto.so
	cp libssl.so ../$output_dir/${arch}/libssl.so

    # Cleanup:
	make clean

    cd ..
done
exit 0
