#!/bin/sh
cd ${BUILT_PRODUCTS_DIR}"/"${EXECUTABLE_FOLDER_PATH}
/opt/theos/bin/ldid -Sentitlements.xml ${EXECUTABLE_NAME}
