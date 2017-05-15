DISTFILES += \
	$$PWD/config/*y \
	$$PWD/packages/de.skycoder42.advanced-setup/meta/* \
	$$PWD/packages/de.skycoder42.advanced-setup/data/* \
	$$PWD/packages/com.microsoft.vcredist.x64/meta/* \
	$$PWD/translations/*.ts \
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

#lupdate -locations relative ./config/controller.js ./packages/de.skycoder42.advanced-setup/meta/install.js ./packages/de.skycoder42.advanced-setup/meta/ShortcutPage.ui ./packages/de.skycoder42.advanced-setup/meta/UserPage.ui -ts ./translations/template.ts ./translations/de.ts
#lrelease -compress -nounfinished ./translations/de.ts -qm ./packages/de.skycoder42.advanced-setup/meta/de.qm
