include $(THEOS)/makefiles/common.mk

TWEAK_NAME = forceForward
forceForward_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk
forceForward_FRAMEWORKS=AudioToolbox

after-install::
	install.exec "killall -9 SpringBoard"


BUNDLE_NAME = imageBundle
imageBundle_INSTALL_PATH = /Library/Application Support/forceForward
include $(THEOS)/makefiles/bundle.mk
