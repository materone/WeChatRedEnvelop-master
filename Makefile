THEOS_DEVICE_IP = 192.168.199.219
THEOS_DEVICE_PORT = 22
#THEOS_DEVICE_IP = localhost
#THEOS_DEVICE_PORT = 2000
ARCHS = arm64
#ARCHS = armv7 arm64
TARGET = iphone:latest:7.0

include theos/makefiles/common.mk

TWEAK_NAME = WeChatRedEnvelop
WeChatRedEnvelop_FILES = Tweak.xm
WeChatRedEnvelop_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
SUBPROJECTS += wxprefr
include $(THEOS_MAKE_PATH)/aggregate.mk
