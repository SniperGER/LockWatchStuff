include $(THEOS)/makefiles/common.mk
export GO_EASY_ON_ME = 1

TWEAK_NAME = LockWatch
LockWatch_FILES = Tweak.xm
LockWatch_FILES += LWScrollView.m
LockWatch_FILES += LWWatchFaceContainer.m
LockWatch_FILES += LWWatchFaceSimple.m
LockWatch_FILES += LWWatchFaceColor.m
LockWatch_FILES += LWWatchFaceXLarge.m
LockWatch_FILES += WatchButton.m
LockWatch_FRAMEWORKS = UIKit
LockWatch_FRAMEWORKS += CoreGraphics
LockWatch_FRAMEWORKS += QuartzCore
LockWatch_FRAMEWORKS += CoreFoundation



include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
