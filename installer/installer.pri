DISTFILES += \
	$$PWD/config/* \
	$$PWD/packages/de.skycoder42.advancedsetup/meta/* \
	$$PWD/packages/de.skycoder42.advancedsetup/data/* \
	$$PWD/packages/com.microsoft.vcredist/meta/* \
	$$PWD/translations/*.ts \
	$$PWD/build.py

#variable defaults
isEmpty(QTIFW_BIN): QTIFW_BIN = "$$[QT_INSTALL_BINS]/../../../Tools/QtInstallerFramework/3.0/bin/"
isEmpty(QTIFW_DIR): QTIFW_DIR = qtifw-installer
isEmpty(QTIFW_MODE): QTIFW_MODE = offline #can be: offline, online, repository, online_all
isEmpty(QTIFW_TARGET): QTIFW_TARGET = "$$TARGET Installer"
win32:isEmpty(QTIFW_TARGET_x): QTIFW_TARGET_x = .exe
else:mac:isEmpty(QTIFW_TARGET_x): QTIFW_TARGET_x = .app
else:isEmpty(QTIFW_TARGET_x): QTIFW_TARGET_x = .run
isEmpty(QTIFW_CONFIG): error(QTIFW_CONFIG must not be empty!)

# standard installer values
QTIFW_CONFIG += "$$PWD/config/controller.js"

aspkg.pkg = de.skycoder42.advancedsetup
aspkg.meta = "$$PWD/packages/de.skycoder42.advancedsetup/meta"
win32: aspkg.dirs = "$$PWD/packages/de.skycoder42.advancedsetup/data"
QTIFW_PACKAGES += aspkg

win32:msvc { #TODO use files instead
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
		contains(QT_ARCH, x86_64): redistpkg.pkg = com.microsoft.vcredist.x64
		else: redistpkg.pkg = com.microsoft.vcredist.x86
		redistpkg.meta = "$$PWD/packages/com.microsoft.vcredist/meta"
		redistpkg.files = "$$QTIFW_VCPATH"
		QTIFW_PACKAGES += redistpkg
	}
}

# installer target generation
QTIFW_ARGS = $$shell_quote($$shell_path($$_PRO_FILE_PWD_))
QTIFW_ARGS += $$shell_quote($$shell_path($$QTIFW_DIR))
QTIFW_ARGS += $$shell_quote($$shell_path($$[QT_INSTALL_BINS]))
QTIFW_ARGS += $$shell_quote($$shell_path($$QTIFW_BIN))
QTIFW_ARGS += $$shell_quote($${QTIFW_TARGET}$${QTIFW_TARGET_x})
QTIFW_ARGS += $$shell_quote($$QTIFW_MODE)
win32: QTIFW_ARGS += win
else:mac: QTIFW_ARGS += mac
else: QTIFW_ARGS += linux
contains(QT_ARCH, x86_64): QTIFW_ARGS += x64
else: QTIFW_ARGS += x86
for(cfg, QTIFW_CONFIG): QTIFW_ARGS += $$shell_quote($$shell_path($$cfg))
for(pkg, QTIFW_PACKAGES) {
	QTIFW_ARGS += p $$shell_quote($$first($${pkg}.pkg))
	for(meta, $${pkg}.meta): QTIFW_ARGS += m $$shell_quote($$shell_path($$meta))
	for(data, $${pkg}.dirs): QTIFW_ARGS += d $$shell_quote($$shell_path($$data))
	for(data, $${pkg}.files): QTIFW_ARGS += f $$shell_quote($$shell_path($$data))
	for(subdir, $${pkg}.subdirs) {
		QTIFW_ARGS += t $$shell_quote($$shell_path($$first($${subdir}.name)))
		for(data, $${subdir}.dirs): QTIFW_ARGS += d $$shell_quote($$shell_path($$data))
		for(data, $${subdir}.files): QTIFW_ARGS += f $$shell_quote($$shell_path($$data))
	}
}

qtifw_inst.target = installer
linux: qtifw_inst.commands = $$shell_quote($$shell_path($$PWD/build.py)) $$QTIFW_ARGS
else:win32: qtifw_inst.commands = python $$shell_quote($$shell_path($$PWD/build.py)) $$QTIFW_ARGS
else:mac: qtifw_inst.commands = /usr/local/bin/python3 $$shell_quote($$shell_path($$PWD/build.py)) $$QTIFW_ARGS

qtifw_inst_clean.target = installer-clean
win32: qtifw_inst_clean.commands = $$QMAKE_DEL_FILE /S /Q $$shell_quote($$shell_path($$QTIFW_DIR))
else: qtifw_inst_clean.commands = $$QMAKE_DEL_FILE -r $$shell_quote($$shell_path($$QTIFW_DIR))
clean.depends += qtifw_inst_clean

QMAKE_EXTRA_TARGETS += qtifw_inst clean qtifw_inst_clean
