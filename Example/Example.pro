TEMPLATE = app

TARGET = example

QTIFW_TARGET = Example Installer
QTIFW_CONFIG = config.xml
#QTIFW_MODE = online_all

sample.pkg = de.skycoder42.qtifwsample
sample.meta = meta
sample.data = data "$$OUT_PWD/deploy"

QTIFW_PACKAGES += sample

include(../de_skycoder42_qtifw-advanced-setup.pri)

SOURCES += \
	main.cpp

DISTFILES += \
	config.xml \
	data/SampleProgram.exe \
	meta/package.xml \
	data/main.png \
	data/Contents/MacOS/SampleProgram \
	data/SampleProgram \
	meta/LICENSE.txt \
	meta/LICENSE_de.txt
