DISTFILES += \
	$$PWD/config/config_template.xml \
	$$PWD/config/controller.js \
	$$PWD/packages/de.skycoder42.advanced-setup/meta/package.xml \
	$$PWD/packages/de.skycoder42.advanced-setup/meta/install.js \
	$$PWD/packages/de.skycoder42.advanced-setup/meta/ShortcutPage.ui \
	$$PWD/packages/de.skycoder42.advanced-setup/meta/UserPage.ui \
	$$PWD/packages/de.skycoder42.advanced-setup/data/regSetUninst.bat \
	$$PWD/packages/com.microsoft.vcredist.x64/meta/package.xml \
	$$PWD/packages/com.microsoft.vcredist.x64/meta/install.js \
	$$PWD/translations/de.ts \
	$$PWD/translations/template.ts \
	$$PWD/build.py

isEmpty(QTIFW_CMD): QTIFW_CMD = $$PWD/build.py
isEmpty(QTIFW_DIR): QTIFW_DIR = qtifw-installer
isEmpty(QTIFW_CONFIG): warning(QTIFW_CONFIG must not be empty!)

QTIFW_CONFIG += $$PWD/config/controller.js

aspkg.pkg = de.skycoder42.advanced-setup
aspkg.meta = $$PWD/packages/de.skycoder42.advanced-setup/meta
aspkg.data = $$PWD/packages/de.skycoder42.advanced-setup/data
QTIFW_PACKAGES += aspkg

win32 {
	redistpkg.pkg = com.microsoft.vcredist.x64
	redistpkg.meta = $$PWD/packages/com.microsoft.vcredist.x64/meta
	redistpkg.data = $$PWD/packages/com.microsoft.vcredist.x64/data
	QTIFW_PACKAGES += redistpkg
}

QTIFW_ARGS = $$shell_quote($$shell_path($$_PRO_FILE_PWD_))
QTIFW_ARGS += $$shell_quote($$shell_path($$QTIFW_DIR))
for(cfg, QTIFW_CONFIG): QTIFW_ARGS += $$shell_quote($$shell_path($$cfg))
for(pkg, QTIFW_PACKAGES) {
	QTIFW_ARGS += p $$shell_quote($$first($${pkg}.pkg))
	for(meta, $${pkg}.meta): QTIFW_ARGS += m $$shell_quote($$shell_path($$meta))
	for(data, $${pkg}.data): QTIFW_ARGS += d $$shell_quote($$shell_path($$data))
}

qtifw_inst.target = installer
qtifw_inst.commands = $$shell_quote($$shell_path($$QTIFW_CMD)) $$QTIFW_ARGS

QMAKE_EXTRA_TARGETS += qtifw_inst
