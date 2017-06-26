include $(THEOS)/makefiles/common.mk

TWEAK_NAME = 3dflip
3dflip_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk
3dflip_FRAMEWORKS=AudioToolbox

after-install::
	install.exec "killall -9 SpringBoard"
