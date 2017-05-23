TEMPLATE = app

TARGET = Example

QTIFW_CONFIG = config.xml
QTIFW_MODE = online_all

sample.pkg = de.skycoder42.qtifwsample
sample.meta = meta
sample.dirs = data
linux: sample.files = "$$OUT_PWD/$${TARGET}"
else:win32: sample.files = "$$OUT_PWD/$${TARGET}.exe"
else:mac: sample.dirs = "$$OUT_PWD/$${TARGET}.app"

QTIFW_PACKAGES += sample

include(../de_skycoder42_qtifw-advanced-setup.pri)

SOURCES += \
	main.cpp

DISTFILES += \
	config.xml \
	meta/package.xml \
	data/main.png \
	data/LICENSE
