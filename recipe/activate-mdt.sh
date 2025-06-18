#!/usr/bin/env bash

if [ -n "$MACOSX_DEPLOYMENT_TARGET" ]; then
    export CONDA_SYSROOT_@PLATFORM@_BACKUP_MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET}"
fi
export MACOSX_DEPLOYMENT_TARGET="@MACOSX_DEPLOYMENT_TARGET@"

# Priority order for SDK setup:
# 1. If OSX_SDK_DIR is set, use it to set both CONDA_BUILD_SYSROOT and SDKROOT
# 2. Else if CONDA_BUILD_SYSROOT is set, use it and set SDKROOT to match
# 3. Else if SDKROOT is set, use it and set CONDA_BUILD_SYSROOT to match
# 4. Else warn that none are set

if [ -n "${OSX_SDK_DIR}" ]; then
    # OSX_SDK_DIR is set, back up the others if we have them and set them both to the new path.
    if [ -n "${CONDA_BUILD_SYSROOT}" ]; then
        export CONDA_SYSROOT_@PLATFORM@_BACKUP_CONDA_BUILD_SYSROOT="${CONDA_BUILD_SYSROOT}"
    fi
    if [ -n "${SDKROOT}" ]; then
        export CONDA_SYSROOT_@PLATFORM@_BACKUP_SDKROOT="${SDKROOT}"
    fi
    export CONDA_BUILD_SYSROOT="${OSX_SDK_DIR}/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk"
    export SDKROOT="${CONDA_BUILD_SYSROOT}"
elif [ -n "${CONDA_BUILD_SYSROOT}" ]; then
    # Use existing CONDA_BUILD_SYSROOT
    if [ -n "${SDKROOT}" ]; then
        export CONDA_SYSROOT_@PLATFORM@_BACKUP_SDKROOT="${SDKROOT}"
    fi
    export SDKROOT="${CONDA_BUILD_SYSROOT}"
elif [ -n "${SDKROOT}" ]; then
    # We have a SDKROOT and no SYSROOT, use the SDKROOT to set the SYSROOT.
    export CONDA_BUILD_SYSROOT="${SDKROOT}"
else
    echo "
WARNING: One of OSX_SDK_DIR, CONDA_BUILD_SYSROOT, or SDKROOT should be set to ensure proper SDK pathing
"
fi

# Validate that the CONDA_BUILD_SYSROOT ended up as some path to a SDK matching this package's deployment target version.
if [[ -n "${CONDA_BUILD_SYSROOT}" && ! -e "${CONDA_BUILD_SYSROOT}" ]]; then
    echo "
WARNING: The CONDA_BUILD_SYSROOT or SDKROOT that has been set does not contain a valid OSX
${MACOSX_DEPLOYMENT_TARGET} SDK. This is likely to result in build failures.
"
fi

# CMAKE_OSX_SYSROOT already gets set to the SDKROOT env var if not set explicitly but just for clarity let's set it
# explicitly.
if [ -n "${CMAKE_ARGS}" ]; then
    export CONDA_SYSROOT_@PLATFORM@_BACKUP_CMAKE_ARGS="${CMAKE_ARGS}"
fi
export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} -DCMAKE_OSX_SYSROOT=${SDKROOT}"

if [ -n "${CPPFLAGS}" ]; then
    export CONDA_SYSROOT_@PLATFORM@_BACKUP_CPPFLAGS="${CPPFLAGS}"
fi
export CPPFLAGS="${CPPFLAGS} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
