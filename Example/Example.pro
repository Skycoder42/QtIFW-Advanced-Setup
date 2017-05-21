TEMPLATE = app

TARGET = example

QTIFW_TARGET = Example Installer
QTIFW_CONFIG = config.xml
QTIFW_MODE = online_all

sample.pkg = de.skycoder42.qtifwsample
sample.meta = meta
!mac: sample.data = data "$$OUT_PWD/deploy"
else: sample.data = data "$$OUT_PWD/deploy/$${TARGET}.app"

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
	data/SampleProgram

deploy_target.target = deploy
linux: deploy_target.commands = mkdir $${OUT_PWD}/deploy && $$QMAKE_COPY_FILE $${OUT_PWD}/$${TARGET} $${OUT_PWD}/deploy/
else:win32: deploy_target.commands = mkdir $$shell_path($${OUT_PWD}/deploy) && $$QMAKE_COPY_FILE $$shell_path($${OUT_PWD}/release/$${TARGET}.exe) $$shell_path($${OUT_PWD}/deploy/)
else:mac: deploy_target.commands = mkdir $${OUT_PWD}/deploy && $$QMAKE_COPY_DIR $${OUT_PWD}/$${TARGET}.app $${OUT_PWD}/deploy/

QMAKE_EXTRA_TARGETS += deploy_target
