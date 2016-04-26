GO_EASY_ON_ME=1
PACKAGE_VERSION=0.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockWatch
LockWatch_FILES = Tweak.xm
LockWatch_FILES += CAKeyframeAnimation+AHEasing.m WatchButton.m LWScrollViewContainer.m LWScrollView.m easing.c ViewController.m

include $(THEOS_MAKE_PATH)/tweak.mk
after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += lockwatch_prefs
include $(THEOS_MAKE_PATH)/aggregate.mk