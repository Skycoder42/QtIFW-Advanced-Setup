DISTFILES += \
	$$PWD/config/* \
	$$PWD/packages/de.skycoder42.advancedsetup/meta/* \
	$$PWD/packages/de.skycoder42.advancedsetup/data/* \
	$$PWD/packages/com.microsoft.vcredist/meta/* \
	$$PWD/translations/*.ts \
	$$PWD/build.py

#variable defaults
isEmpty(QTIFW_BIN): QTIFW_BIN = "$$[QT_INSTALL_BINS]/../../../Tools/QtInstallerFramework/3.0/bin/"
isEmpty(QTIFW_MODE): QTIFW_MODE = offline #can be: offline, online, repository, online_all
isEmpty(QTIFW_TARGET): QTIFW_TARGET = "$$TARGET Installer"
isEmpty(QTIFW_TARGET_EXT) {
	win32: QTIFW_TARGET_EXT = .exe
	else:mac: QTIFW_TARGET_EXT = .app
	else: QTIFW_TARGET_EXT = .run
}

# standard installer script
qtifw_advanced_config.path = /config
qtifw_advanced_config.files += "$$PWD/config/controller.js"
qtifw_install_targets: INSTALLS += qtifw_advanced_config

# copy setup stuff
qtifw_advanced_pkg.path = /packages
qtifw_advanced_pkg.files += "$$PWD/packages/de.skycoder42.advancedsetup"
qtifw_install_targets: INSTALLS += qtifw_advanced_pkg

# translations
isEmpty(LRELEASE): qtPrepareTool(LRELEASE, lrelease)
QTIFW_TRANSLATIONS = $$files($$PWD/translations/*.ts)
qtifw_translate.name = $$LRELEASE translate ${QMAKE_FILE_IN}
qtifw_translate.input = QTIFW_TRANSLATIONS
qtifw_translate.variable_out = QTIFW_TRANSLATIONS_QM
qtifw_translate.commands = $$LRELEASE ${QMAKE_FILE_IN} -qm ${QMAKE_FILE_OUT}
qtifw_translate.output = $$OUT_PWD/qtifw-ts/${QMAKE_FILE_BASE}.qm
qtifw_translate.CONFIG += no_link
QMAKE_EXTRA_COMPILERS += qtifw_translate
# and install them
qtifw_advanced_ts_pkg.path = /packages/de.skycoder42.advancedsetup/meta
qtifw_advanced_ts_pkg.depends += compiler_qtifw_translate_make_all
qtifw_advanced_ts_pkg.CONFIG += no_check_exist
for(tsfile, QTIFW_TRANSLATIONS) {
	tsBase = $$basename(tsfile)
	qtifw_advanced_ts_pkg.files += "$$OUT_PWD/qtifw-ts/$$replace(tsBase, \.ts, .qm)"
}
qtifw_install_targets: INSTALLS += qtifw_advanced_ts_pkg

# copy windows vcredist
win32:msvc {
	isEmpty(QTIFW_VCPATH) {
		VCTMP = $$getenv(VCINSTALLDIR)
		VCTMP = $$split(VCTMP, ;)
		VCTMP = $$first(VCTMP)
		isEmpty(VCTMP): warning(Please set the VCINSTALLDIR variable to your vistual studio installation to deploy the vc redistributables!)
		else {
			VC_KNOWN_PATHS += "Redist/MSVC/*" "redist/*"
			contains(QT_ARCH, x86_64): VC_NAME = vcredist_x64.exe
			else: VC_NAME = vcredist_x86.exe
			for(path, VC_KNOWN_PATHS) {
				GFILES = $$files($${VCTMP}/$${path})
				for(gpath, GFILES) {
					X_PATH = $${gpath}/$$VC_NAME
					isEmpty(QTIFW_VCPATH):exists($$X_PATH): QTIFW_VCPATH = $$X_PATH
				}
			}
			message(Detected QTIFW_VCPATH as $$QTIFW_VCPATH)
		}
	}

	# only add if vcpath was actually found
	!isEmpty(QTIFW_VCPATH) {
		contains(QT_ARCH, x86_64): qtifw_redist_pkg_meta.path = /packages/com.microsoft.vcredist.x64
		else: qtifw_redist_pkg_meta.path = /packages/com.microsoft.vcredist.x86
		qtifw_redist_pkg_meta.files += $$PWD/packages/com.microsoft.vcredist/meta

		qtifw_redist_pkg_data.path = $${qtifw_redist_pkg_meta.path}/data
		qtifw_redist_pkg_data.files += $$QTIFW_VCPATH

		qtifw_install_targets: INSTALLS += qtifw_redist_pkg_meta qtifw_redist_pkg_data
	}
}

## installer target generation
QTIFW_ARGS += $(INSTALL_ROOT)
QTIFW_ARGS += $$shell_quote($$shell_path($$QTIFW_BIN))
QTIFW_ARGS += $$shell_quote($${QTIFW_TARGET}$${QTIFW_TARGET_EXT})
QTIFW_ARGS += $$shell_quote($$QTIFW_MODE)
win32: QTIFW_ARGS += win
else:mac: QTIFW_ARGS += mac
else: QTIFW_ARGS += linux
contains(QT_ARCH, x86_64): QTIFW_ARGS += x64
else: QTIFW_ARGS += x86

qtifw_inst.target = installer
win32: qtifw_inst.commands = python
qtifw_inst.commands += $$shell_quote($$shell_path($$PWD/build.py)) $$QTIFW_ARGS

QMAKE_EXTRA_TARGETS += qtifw_inst
