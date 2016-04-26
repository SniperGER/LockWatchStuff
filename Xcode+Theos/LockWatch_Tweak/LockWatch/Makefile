GO_EASY_ON_ME=1
PACKAGE_VERSION=1.1

THEOS=/opt/theos/
THEOS_MAKE_PATH=$(THEOS)/makefiles/
THEOS_DEVICE_IP=localhost
THEOS_DEVICE_PORT=2222

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockWatch
LockWatch_FILES = Tweak.xm
LockWath_FRAMEWORKS += UIKit CoreGraphics CoreLocation Weather
LockWatch_FILES += CAKeyframeAnimation+AHEasing.m WatchButton.m LWScrollViewContainer.m LWScrollView.m easing.c LWInterface.m TouchDownGestureRecognizer.m LWWeatherDataController.xm

include $(THEOS_MAKE_PATH)/tweak.mk
after-install::
		install.exec "killall -9 SpringBoard"
SUBPROJECTS += lockwatch_prefs
include $(THEOS_MAKE_PATH)/aggregate.mk