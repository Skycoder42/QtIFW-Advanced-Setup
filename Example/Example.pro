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

# enable the "qtifw" target to automatically make lrelease, install, deploy, installer and qtifw-compress
CONFIG += qtifw_target qtifw_auto_ts

# make install build products
target.path = /packages/de.skycoder42.qtifw-sample/data
qpmx_ts_target.path = /packages/de.skycoder42.qtifw-sample/data/translations
INSTALLS += target qpmx_ts_target

# deployment is prepared automatically because target.path is defined:
# qtifw_deploy_target.path = $${target.path}

# make install installer stuff
# CONFIG += qtifw_install_targets  ## is set automatically because of CONFIG += qtifw_target
install_pkg.files += data meta
install_pkg.path = /packages/de.skycoder42.qtifw-sample
install_cfg.files = config.xml
install_cfg.path = /config
INSTALLS += install_pkg install_cfg
# QTIFW_MODE = online_all

include(../qtifw-advanced-setup.pri)

!ReleaseBuild:!DebugBuild:!system(qpmx -d $$shell_quote($$_PRO_FILE_PWD_) --qmake-run init $$QPMX_EXTRA_OPTIONS $$shell_quote($$QMAKE_QMAKE) $$shell_quote($$OUT_PWD)): error(qpmx initialization failed. Check the compilation log for details.)
else: include($$OUT_PWD/qpmx_generated.pri)
