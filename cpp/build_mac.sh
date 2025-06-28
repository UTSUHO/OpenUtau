#!/bin/bash

build() {
    echo "Building $1"
    
    mkdir -p ../output/$1/native
    bazel build //worldline:worldline -c opt --cpu=$2
    chmod +w bazel-bin/worldline/libworldline.dylib
    cp bazel-bin/worldline/libworldline.dylib ../output/$1/native
}

build osx-x64 darwin_x86_64
build osx-arm64 darwin_arm64

lipo -create ../output/osx-x64/native/libworldline.dylib ../output/osx-arm64/native/libworldline.dylib -output ../output/osx/native/libworldline.dylib
rm ../output/osx-x64/native/libworldline.dylib ../output/osx-arm64/native/libworldline.dylib
