#!/bin/sh
#!/bin/sh

# Modify this to your device's IP address or .local address.
IP="localhost"
ROOT_ENABLED="1"

# Verify that the build is not for a Simulator.
if [ "$NATIVE_ARCH" != "i386" ] && [ "$NATIVE_ARCH" != "x86_64" ]; then

# Kill running instance and remove the app folder.
ssh -p 2222 root@$IP "killall '${TARGETNAME}'; rm -rf '/Applications/${WRAPPER_NAME}'"

# Self sign the build.
/opt/theos/bin/ldid -S "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/${TARGETNAME}"

# Copy app to device.
scp -P 2222 -r "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}" root@$IP:/Applications/

# Clear UI cache to show app on homescreen.
ssh -p 2222 root@$IP su -c uicache mobile

# Unlock device.
#ssh -p 2222 root@$IP activator send com.bd452.bypass

# Open app.
#ssh -p 2222 root@$IP open `defaults read "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}" CFBundleIdentifier`

# This part creates an OS X notification to let you know that the process is done.
# You can get terminal-notifier from https://github.com/alloy/terminal-notifier.
#/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "Build Complete" -message "${PROJECT_NAME} installed on ${IP}."

fi
