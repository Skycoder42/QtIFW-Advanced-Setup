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
	$$PWD/build_mac.command \
	$$PWD/build_x11.sh \
	$$PWD/build_win.bat


isEmpty(QTIFW_DIR): QTIFW_DIR = $$OUT_PWD/installer
isEmpty(QTIFW_CONFIG): warning(QTIFW_CONFIG must not be empty!)

qtifw_cfg_c.name = "Qt-IFW config ${QMAKE_FILE_IN}"
qtifw_cfg_c.input = QTIFW_CONFIG
qtifw_cfg_c.commands = $$QMAKE_COPY_FILE ${QMAKE_FILE_IN} ${QMAKE_FILE_OUT}
qtifw_cfg_c.output = $$QTIFW_DIR/config/${QMAKE_FILE_BASE}${QMAKE_FILE_EXT}
qtifw_cfg_c.variable_out = DUMMY
qtifw_cfg_c.CONFIG += target_predeps

qtifw_pkg_c.name = "Qt-IFW packages ${QMAKE_FILE_IN}"
qtifw_pkg_c.input = QTIFW_PACKAGES
qtifw_pkg_c.commands = $$QMAKE_COPY_DIR $$first(${QMAKE_FILE_IN_BASE}.meta) ${QMAKE_FILE_OUT}/meta && $$QMAKE_COPY_DIR $$first(${QMAKE_FILE_BASE}.data) ${QMAKE_FILE_OUT}/data
qtifw_pkg_c.output = $$QTIFW_DIR/packages/$$first(${QMAKE_FILE_IN_BASE}.pkg)
qtifw_pkg_c.variable_out = DUMMY2
qtifw_pkg_c.CONFIG += target_predeps

QMAKE_EXTRA_COMPILERS += qtifw_cfg_c qtifw_pkg_c

for(pkg, QTIFW_PACKAGES) {
	QTIFW_PKG_CPY += $${pkg}.meta
}

#isEmpty(QTIFW_CMD) {
#	win32: QTIFW_CMD = $$PWD/build_win.bat
#	else:mac: QTIFW_CMD = $$PWD/build_mac.command
#	else: QTIFW_CMD = $$PWD/build_x11.sh
#}

#QTIFW_ARGS = $$shell_quote($$shell_path($$_PRO_FILE_PWD_))
#QTIFW_ARGS += $$shell_quote($$shell_path($$QTIFW_DIR))
#QTIFW_ARGS += $$shell_quote($$QTIFW_CONFIG)
#for(pkg, QTIFW_PACKAGES) {
#	QTIFW_ARGS += $$shell_quote($$first($${pkg}.pkg))
#	QTIFW_ARGS += $$shell_quote($$shell_path($$first($${pkg}.meta)))
#	QTIFW_ARGS += $$shell_quote($$shell_path($$first($${pkg}.data)))
#	QTIFW_ARGS += $$first($${pkg}.autopath)
#	!isEmpty($${pkg}.autopath):if($$first($${pkg}.autopath)) {
#		for(dep, $${pkg}.deploys) {

#		}
#	} else:for(dep, $${pkg}.deploys): QTIFW_ARGS += deploy $$shell_quote($$shell_path($$dep))
#}

#qtifw_inst.target = installer
#qtifw_inst.commands = $$shell_quote($$shell_path($$QTIFW_CMD)) $$QTIFW_ARGS
#message($$qtifw_inst.commands)

#QMAKE_EXTRA_TARGETS += qtifw_inst
