#!/bin/sh
osascript -e 'tell application "Terminal" to close (every window whose name contains "Making LockWatch")'

echo -n -e "\033]0;Making LockWatch\007"

function return_to_xcode() {
	osascript -e 'tell application "Xcode" to activate'
	osascript -e 'tell application "Terminal" to close (every window whose name contains "Making LockWatch")' & exit
}

rm -rf .theos
cd "`dirname $0`"

/usr/bin/make package install && return_to_xcode