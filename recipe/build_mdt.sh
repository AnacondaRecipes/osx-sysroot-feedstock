#!/usr/bin/env bash

find "${RECIPE_DIR}" -name "activate-mdt.sh" -exec cp {} . \;
find "${RECIPE_DIR}" -name "deactivate-mdt.sh" -exec cp {} . \;

find . -name "activate-mdt.sh" -exec sed -i.bak "s|@MACOSX_DEPLOYMENT_TARGET@|${_MACOSX_DEPLOYMENT_TARGET_}|g" "{}" \;
find . -name "activate-mdt.sh" -exec sed -i.bak "s|@PLATFORM@|${target_platform//-/_}|g" "{}" \;
find . -name "activate-mdt.sh.bak" -exec rm "{}" \;

find . -name "deactivate-mdt.sh" -exec sed -i.bak "s|@PLATFORM@|${target_platform//-/_}|g" "{}" \;
find . -name "deactivate-mdt.sh.bak" -exec rm "{}" \;

# Prefix scripts with 01 to ensure they run before the compiler scripts. This avoids duplicates in some vars.
mkdir -p "${PREFIX}"/etc/conda/{de,}activate.d/
cp ./activate-mdt.sh "${PREFIX}/etc/conda/activate.d/activate_01_${PKG_NAME}.sh"
cp ./deactivate-mdt.sh "${PREFIX}/etc/conda/deactivate.d/deactivate_01_${PKG_NAME}.sh"
