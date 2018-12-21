# openssl-android-build #

Working build scripts for OpenSSL `libcrypto` and `libssl` static and dynamic libraries primarily for using on Android, Mac, Linux OSs. Windows version removed from current repo, look to original one for the instructions.

This repo took best workable ideas from [ekke/android-openssl-qt](https://github.com/ekke/android-openssl-qt) and [couchbaselabs/couchbase-lite-libcrypto](https://github.com/couchbaselabs/couchbase-lite-libcrypto) repos - many thanks to their authors! More ideas about these scripts creation could be found there. Resulting scripts _successfully_ do all for you from downloading and extracting openssl and generating libs for `x86`, `armeabi-v7a`, `arm64-v8a` architectures.

Default OpenSSL version is [1.0.2o](https://www.openssl.org/source/old/1.0.2/openssl-1.0.2o.tar.gz) as currently used in Qt Creator.

# How to rebuild the binaries

## 1. Setup the project
```
$ git clone https://github.com/akontsevich/openssl-android-build.git
$ export OPENSSL_VERSION="openssl-1.0.2o"
```
## 2. Generate include headers

Run the following command on a Mac or Linux machine. The headers will be output at `libs/include`.
```
$ ./generate-headers.sh
```

## 3. Build the binaries for each platform

### 3.1 Android

### Requirements
1. Download [Android NDK](https://developer.android.com/ndk/downloads/)
> **Note.** You need to download FULL NDK version as Android Studio ships reduced version which may cause build failure.
2. Mac OSX or Linux Machine

#### Common Build Steps
1. Make sure that you have the `ANDROID_NDK_HOME` variable defined. For example,
 ```
 #.bashrc:
 export ANDROID_NDK_HOME=~/Android/android-ndk-r10e
 ```
or
```
 #.bashrc:
 export ANDROID_NDK_HOME=~/Android/android-ndk-r18b
```

#### Build Steps with GCC
1. Run the build script. The binaries will be output at `libs/android`

 ```
 $ ./build-android.sh
 ```

#### Build Steps with clang
1. Run the build script. The binaries will be output at `libs/android/clang`
> **Note.** More modern NDK version recommended to use there:
 ```
 export ANDROID_NDK_HOME=~/Android/android-ndk-r18b
 $ ./build-android-clang.sh
 ```

### 3.2 OSX ~~and iOS~~

#### Requirements
1. XCode
2. makedepend (if you don't have one)

 ```
 $ homebrew install makedepend
 ```

#### Build Steps
Run the build script. The binaries will be output at `libs/osx` and `libs/ios`. The osx and ios binaries are universal libraries.
 ```
 $ ./build-osx-ios.sh
 ```

### 3.3 Linux

#### Requirements
1. GCC
2. makedepend (if you don't have one)
On Ubuntu:
 ```
 $ sudo apt-get install xutils-dev
 ```
In openSUSE:
 ```
 $ sudo zypper in makedepend
 ```

#### Build Steps
Run the build script. The binaries will be output at `libs/linux`.
 ```
 $ ./build-linux.sh
 ```
## 4. Qt project file modifications

Modify `.pro` file in a Qt project: insert this line into your `.pro`:
```
include(android-build.pri)
```
Assume build libraries and headers copied to `./3rdparty` dir or your source tree. Following structure considers we build `clang` library version:
```
$$PWD/3rdparty
    └── include
        └── openssl
            └── *.h
    └── libs/llvm
            ├── arm64-v8a
            │   ├── libcrypto.a
            │   ├── libcrypto.so
            │   ├── libssl.a
            │   └── libssl.so
            ├── arch-armeabi-v7a
            │   ├── libcrypto.a
            │   ├── libcrypto.so
            │   ├── libssl.a
            │   └── libssl.so
            └── arch-x86
                ├── libcrypto.a
                ├── libcrypto.so
                ├── libssl.a
                └── libssl.so
```

### .pri file content
```
android {
INCLUDEPATH += $$absolute_path($$PWD/3rdparty/include)

equals(ANDROID_TARGET_ARCH, arm64-v8a) {
    LIBPATH = $$absolute_path($$PWD/3rdparty/libs/llvm/arm64-v8a)
}

equals(ANDROID_TARGET_ARCH, armeabi-v7a) {
    LIBPATH = $$absolute_path($$PWD/3rdparty/libs/llvm/armeabi-v7a)
}

LIBS += \
    -L$$LIBPATH \
    -lssl -lcrypto

ANDROID_EXTRA_LIBS += \
    $$LIBPATH/libssl.so \
    $$LIBPATH/libcrypto.so
}
```
