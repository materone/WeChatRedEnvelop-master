include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = wxprefr
wxprefr_FILES = wxprefrRootListController.m
wxprefr_INSTALL_PATH = /Library/PreferenceBundles
wxprefr_FRAMEWORKS = UIKit
wxprefr_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/wxprefr.plist$(ECHO_END)
