TEMPLATE = app
QT += widgets

TARGET = Example

QTIFW_CONFIG = config.xml
# QTIFW_MODE = online_all

deploy.file = $$shadowed($$TARGET)
deploy.out = $$OUT_PWD/deployed
deploy.ts = $$_PRO_FILE_

sample.pkg = de.skycoder42.qtifwsample
sample.meta = meta
sample.dirs = data $$OUT_PWD/deployed
sample.files = ../LICENSE

QTIFW_PACKAGES += sample

include(../de_skycoder42_qtifw-advanced-setup.pri)

SOURCES += \
	main.cpp

DISTFILES += \
	config.xml \
	meta/package.xml \
	data/main.png
