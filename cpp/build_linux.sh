#!/bin/bash

setup()
{
    sudo apt-get install gcc-arm-linux-gnueabi g++-arm-linux-gnueabi binutils-arm-linux-gnueabi
    sudo apt-get install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu binutils-aarch64-linux-gnu
}

build()
{
    echo "Building $1"
    
    mkdir -p ../output/$1/native
    bazel build //worldline:worldline -c opt --config=$2
    chmod +w bazel-bin/worldline/libworldline.so
    cp bazel-bin/worldline/libworldline.so ../output/$1/native
}

build linux-x64 linux
build linux-arm64 ubuntu-aarch64
