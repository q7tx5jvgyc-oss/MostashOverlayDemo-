TARGET := iphone:clang:latest:14.0
ARCHS := arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MostashOverlayDemo

MostashOverlayDemo_FILES = main.mm
MostashOverlayDemo_CFLAGS = -fobjc-arc
MostashOverlayDemo_FRAMEWORKS = UIKit Foundation QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
