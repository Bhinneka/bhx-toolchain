#/bin/env bash

set -e 

export CONFIG_FILE="ics_linux_x86_64.defconfig"

UNAME="$(uname -s)"
case ${UNAME} in 
    Linux*) HOST_OS="linux";;
    Darwin*) HOST_OS="osx";;
    *) HOST_OS="linux";;
esac

if [ "${TARGET_DEVICE}" -eq "ics" ]; then
	if [ "${HOST_OS}" -eq "linux" ]; then
		CONFIG_FILE="ics_linux.defconfig"
    elif [ "${HOST_OS}" seq "osx" ]; then
        CONFIG_FILE="ics_macos.defconfig"
    fi
fi

if [ "${HOST_OS}" -eq "osx" ]; then
    hdiutil create -size 40g -type SPARSEBUNDLE -nospotlight -volname "SDKBUILD" -fs JHFSX -imagekey sparse-band-size=262144 -verbose sdkbuild.sparsebundle
    hdiutil create -size 20g -type SPARSEBUNDLE -nospotlight -volname "SDK" -fs JHFSX -imagekey sparse-band-size=262144 -verbose sdk.sparsebundle
    hdiutil attach sdkbuild.sparsebundle
    hdiutil attach sdk.sparsebundle

    mkdir -p /Volumes/SDKBUILD/ct-build
    mkdir -p /Volumes/SDKBUILD/src

    cp ${CONFIG_FILE} /Volumes/SDKBUILD/ct-build/.config 

    pushd /Volumes/SDKBUILD

    git clone https://github.com/crosstool-ng/crosstool-ng
    pushd crosstool-ng && ./bootstrap && ./configure --enable-local && make && popd
    pushd ct-build && ../crosstool-ng/ct-ng build && popd

    popd 

elif ["${HOST_OS}" -eq "linux"]; then
    git clone https://github.com/crosstool-ng/crosstool-ng
    pushd crosstool-ng && ./bootstrap && ./configure --enable-local && make && popd
    mkdir -p ct-build && mkdir -p ${HOME}/src
    cp ics_linux.defconfig ct-build/.config 
    pushd ct-build && ../crosstool-ng/ct-ng build && popd 
fi