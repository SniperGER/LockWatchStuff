GO_EASY_ON_ME = 1
TARGET = iphone:9.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockWatchBeta
LockWatchBeta_FILES = Tweak.xm
LockWatchBeta_FRAMEWORKS = QuartzCore UIKit CoreGraphics Foundation
LockWatchBeta_FILES += LWScrollView.m LWScrollViewContainer.m WatchButton.m CAKeyframeAnimation+AHEasing.m easing.c
LockWatchBeta_CODESIGN_FLAGS = -Sentitlements.xml
SHARED_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

include $(THEOS_MAKE_PATH)/aggregate.mk
