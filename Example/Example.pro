TEMPLATE = app
QT += widgets

TARGET = Example

QTIFW_CONFIG = config.xml
# QTIFW_MODE = online_all

win32:CONFIG(debug, debug|release): QTIFW_DEPLOY_SRC = $$shadowed(debug/$${TARGET}.exe)
else:win32:CONFIG(release, debug|release): QTIFW_DEPLOY_SRC = $$shadowed(release/$${TARGET}.exe)
else:mac: QTIFW_DEPLOY_SRC = $$shadowed($${TARGET}.app)
else: QTIFW_DEPLOY_SRC = $$shadowed($$TARGET)
QTIFW_DEPLOY_TSPRO = $$_PRO_FILE_

sample.pkg = de.skycoder42.qtifwsample
sample.meta = meta
mac: sample.dirs = data $$OUT_PWD/deployed/$${TARGET}.app
else: sample.dirs = data $$OUT_PWD/deployed
sample.files = ../LICENSE

QTIFW_PACKAGES += sample

include(../de_skycoder42_qtifw-advanced-setup.pri)

SOURCES += \
	main.cpp

DISTFILES += \
	config.xml \
	meta/package.xml \
	data/main.png \
	example_de.ts

TRANSLATIONS += example_de.ts
