include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = lockwatchprefs
lockwatchprefs_FILES = LWTRootListController.m
lockwatchprefs_INSTALL_PATH = /Library/PreferenceBundles
lockwatchprefs_FRAMEWORKS = UIKit
lockwatchprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/lockwatchprefs.plist$(ECHO_END)
