TEMPLATE = app
QT += widgets

TARGET = Example

QTIFW_CONFIG = config.xml
# QTIFW_MODE = online_all

QTIFW_DEPLOY_SRC = $$shadowed($$TARGET)
QTIFW_DEPLOY_TSPRO = $$_PRO_FILE_

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
	data/main.png \
	example_de.ts

TRANSLATIONS += example_de.ts
