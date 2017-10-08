TEMPLATE = app
QT += widgets

TARGET = Example

SOURCES += \
	main.cpp

DISTFILES += \
	config.xml \
	meta/package.xml \
	data/main.png \
	example_de.ts

TRANSLATIONS += example_de.ts
QTIFW_TS_TARGET = lrelease

# installer
QTIFW_CONFIG = config.xml
# QTIFW_MODE = online_all

sample.pkg = de.skycoder42.qtifwsample
sample.meta = meta
sample.dirs = data
sample.files = ../LICENSE

QTIFW_PACKAGES += sample

# deployment
CONFIG += qtifw_auto_deploy
QTIFW_DEPLOY_TSPRO = $$_PRO_FILE_
QTIFW_AUTO_INSTALL_PKG = sample

# enable the "install" make target
CONFIG += qtifw_install_target

include(../de_skycoder42_qtifw-advanced-setup.pri)

!ReleaseBuild:!DebugBuild:!system(qpmx -d $$shell_quote($$_PRO_FILE_PWD_) --qmake-run init $$QPMX_EXTRA_OPTIONS $$shell_quote($$QMAKE_QMAKE) $$shell_quote($$OUT_PWD)): error(qpmx initialization failed. Check the compilation log for details.)
else: include($$OUT_PWD/qpmx_generated.pri)
