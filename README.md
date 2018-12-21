# openssl-android-build #

Working build scripts for OpenSSL `libcrypto` and `libssl` static and dynamic libraries primarily for using on Android and other OSs. This repo took best workable ideas from [ekke/android-openssl-qt](https://github.com/ekke/android-openssl-qt) and [couchbaselabs/couchbase-lite-libcrypto](https://github.com/couchbaselabs/couchbase-lite-libcrypto) repos - many thanks to their authors! More ideas about these scripts creation could be found there. Resulting scripts _successfully_ do all for you from downloading and extracting openssl and generating libs for `x86`, `armeabi-v7a`, `arm64-v8a` architectures.

Default OpenSSL version is [1.0.2o](https://www.openssl.org/source/old/1.0.2/openssl-1.0.2o.tar.gz) as currently used in Qt Creator. However You may build with any desired version (instructions below), except for the Windows Store builds which are not modified from original repo version and does not function for now.

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
### 3.4 Windows
> #### The script was not fixed from original repo, so instructions for Windows does not work for now

#### Requirements
1. [Visual Studio 2015](https://www.visualstudio.com/en-us/downloads/download-visual-studio-vs.aspx)
2. [Windows SDK](https://msdn.microsoft.com/en-us/windows/desktop/bg162891.aspx).
3. [Active Perl](http://www.activestate.com/activeperl) or [Strawberry Perl](http://strawberryperl.com)

Note that the build-windows.cmd script is configured with Visual Studio 2013.

#### Build Steps
1. Make sure that the path to the `nmake` tool is included into the PATH Environment.
 ```
 Visual 2015: C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin
 ```

2. Run the build script. The binaries will be output at `libs/windows`.

 ```
 C:\couchbase-lite-libcrypto>build-windows.cmd
 ```
### 3.5 Windows Store

Follow the instructions at [Microsoft's fork](https://github.com/Microsoft/openssl/tree/OpenSSL_1_0_2k_WinRT)

## Qt project file modifications

Modify `.pro` file in a Qt project: insert this line into your `.pro`:
```
include(android-build.pri)
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
