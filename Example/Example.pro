TEMPLATE = app

TARGET = example

QTIFW_CONFIG = config.xml

sample.pkg = de.skycoder42.qtifw-sample
sample.meta = meta
sample.data = data
sample.deploys += $$TARGET
sample.autopath = true

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
