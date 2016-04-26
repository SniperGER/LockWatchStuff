export GO_EASY_ON_ME=1

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LockWatch_Prefs
LockWatch_Prefs_FILES = LockWatchRootListController.m LockWatchWatchFaceListController.m LockWatchPrivacyListController.m LockWatchGraphicsListController.m
LockWatch_Prefs_INSTALL_PATH = /Library/PreferenceBundles/
LockWatch_Prefs_FRAMEWORKS = UIKit
LockWatch_Prefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/LockWatch_Prefs$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/LockWatch_Prefs/LockWatch_Prefs.plist$(ECHO_END)
after-install::
	install.exec "killall -9 Preferences"
