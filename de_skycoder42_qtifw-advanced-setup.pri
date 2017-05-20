DISTFILES += \
	$$PWD/config/* \
	$$PWD/packages/de.skycoder42.advancedsetup/meta/* \
	$$PWD/packages/de.skycoder42.advancedsetup/data/* \
	$$PWD/packages/com.microsoft.vcredist.x64/meta/* \
	$$PWD/translations/*.ts \
	$$PWD/build.py

#variable defaults
isEmpty(QTIFW_BIN): QTIFW_BIN = $$[QT_INSTALL_BINS]/../../../Tools/QtInstallerFramework/2.0/bin/
isEmpty(QTIFW_DIR): QTIFW_DIR = qtifw-installer
isEmpty(QTIFW_MODE): QTIFW_MODE = offline #can be: offline, online, repository, online_all
isEmpty(QTIFW_TARGET): QTIFW_TARGET = "$$TARGET Installer"
win32:isEmpty(QTIFW_TARGET_x): QTIFW_TARGET_x = .exe
else:mac:isEmpty(QTIFW_TARGET_x): QTIFW_TARGET_x = .app
else:isEmpty(QTIFW_TARGET_x): QTIFW_TARGET_x = .run
isEmpty(QTIFW_CONFIG): warning(QTIFW_CONFIG must not be empty!)

# standard installer values
QTIFW_CONFIG += $$PWD/config/controller.js

aspkg.pkg = de.skycoder42.advancedsetup
aspkg.meta = $$PWD/packages/de.skycoder42.advancedsetup/meta
win32: aspkg.data = $$PWD/packages/de.skycoder42.advancedsetup/data
QTIFW_PACKAGES += aspkg

win32:msvc {
	isEmpty(QTIFW_VCDIR) {
		VCTMP = $(VCINSTALLDIR)
		isEmpty(VCTMP): QTIFW_VCDIR = $$[QT_INSTALL_BINS]/../../../vcredist/
		else: QTIFW_VCDIR = $$VCTMP\redist\1033
	}

	redistpkg.pkg = com.microsoft.vcredist.x64
	redistpkg.meta = $$PWD/packages/com.microsoft.vcredist.x64/meta
	redistpkg.data = $$QTIFW_VCDIR
	QTIFW_PACKAGES += redistpkg
}

# installer target generation
QTIFW_ARGS = $$shell_quote($$shell_path($$_PRO_FILE_PWD_))
QTIFW_ARGS += $$shell_quote($$shell_path($$QTIFW_DIR))
QTIFW_ARGS += $$shell_quote($$shell_path($$QTIFW_BIN))
QTIFW_ARGS += $$shell_quote($${QTIFW_TARGET}$${QTIFW_TARGET_x})
QTIFW_ARGS += $$shell_quote($$QTIFW_MODE)
contains(QT_ARCH, x86_64): QTIFW_ARGS += x64
else: QTIFW_ARGS += x86
for(cfg, QTIFW_CONFIG): QTIFW_ARGS += $$shell_quote($$shell_path($$cfg))
for(pkg, QTIFW_PACKAGES) {
	QTIFW_ARGS += p $$shell_quote($$first($${pkg}.pkg))
	for(meta, $${pkg}.meta): QTIFW_ARGS += m $$shell_quote($$shell_path($$meta))
	for(data, $${pkg}.data): QTIFW_ARGS += d $$shell_quote($$shell_path($$data))
}

qtifw_inst.target = installer
win32: qtifw_inst.commands = python $$shell_quote($$shell_path($$PWD/build.py)) $$QTIFW_ARGS
else: qtifw_inst.commands = $$shell_quote($$shell_path($$PWD/build.py)) $$QTIFW_ARGS

QMAKE_EXTRA_TARGETS += qtifw_inst

# The following commands allow you to create custom translation files
#lupdate -locations relative ./config/controller.js ./packages/de.skycoder42.advancedsetup/meta/install.js ./packages/de.skycoder42.advancedsetup/meta/ShortcutPage.ui ./packages/de.skycoder42.advancedsetup/meta/UserPage.ui -ts ./translations/template.ts ./translations/de.ts
#lrelease -compress -nounfinished ./translations/de.ts -qm ./packages/de.skycoder42.advancedsetup/meta/de.qm
