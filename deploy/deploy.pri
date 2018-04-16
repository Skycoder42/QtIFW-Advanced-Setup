DISTFILES += \
	$$PWD/deploy.py

isEmpty(qtifw_deploy_target.files) {
	!isEmpty(TARGET_EXT): qtifw_deploy_target.files = "$${TARGET}$${TARGET_EXT}"
	else:win32: qtifw_deploy_target.files = "$${TARGET}.exe"
	else:mac:app_bundle: qtifw_deploy_target.files = "$${TARGET}.app"
	else: qtifw_deploy_target.files = "$$TARGET"
}
isEmpty(qtifw_deploy_target.path): qtifw_deploy_target.path = $${target.path}

!isEmpty(qtifw_deploy_target.path) {
	DEPLOY_PATH = $(INSTALL_ROOT)$${qtifw_deploy_target.path}

	linux: QTIFW_DEPLOY_ARGS = linux
	else:win32:CONFIG(release, debug|release): QTIFW_DEPLOY_ARGS = win_release
	else:win32:CONFIG(debug, debug|release): QTIFW_DEPLOY_ARGS = win_debug
	else:mac: QTIFW_DEPLOY_ARGS = mac
	else: QTIFW_DEPLOY_ARGS = unknown

	QTIFW_DEPLOY_ARGS += $$shell_quote($$[QT_INSTALL_BINS])
	QTIFW_DEPLOY_ARGS += $$shell_quote($$[QT_INSTALL_PLUGINS])
	QTIFW_DEPLOY_ARGS += $$shell_quote($$[QT_INSTALL_TRANSLATIONS])
	QTIFW_DEPLOY_ARGS += $$shell_quote($$DEPLOY_PATH)
	for(file, qtifw_deploy_target.files): QTIFW_DEPLOY_ARGS += $$shell_quote($$file)
	!isEmpty(QTIFW_QM_DEPS): QTIFW_DEPLOY_ARGS += "==" $$QTIFW_QM_DEPS

	qtifw_deploy.target = deploy
	win32: qtifw_deploy.commands = python
	qtifw_deploy.commands += $$shell_quote($$shell_path($$PWD/deploy.py)) $$QTIFW_DEPLOY_ARGS

	QMAKE_EXTRA_TARGETS += qtifw_deploy
}
