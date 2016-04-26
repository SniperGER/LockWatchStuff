#!/bin/sh
cd ${BUILT_PRODUCTS_DIR}"/"${EXECUTABLE_FOLDER_PATH}
/opt/iOSOpenDev/bin/ldid -Sentitlements.xml ${EXECUTABLE_NAME}
