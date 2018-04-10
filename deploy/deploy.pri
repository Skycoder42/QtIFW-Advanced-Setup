DISTFILES += \
	$$PWD/deploy.py

isEmpty(qtifw_deploy_target.files) {
	win32: qtifw_deploy_target.files = "$${TARGET}.exe"
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

	qtifw_deploy.target = deploy
	qtifw_deploy.depends += install
	win32: qtifw_deploy.commands = python $$shell_quote($$shell_path($$PWD/deploy.py)) $$QTIFW_DEPLOY_ARGS
	else: qtifw_deploy.commands = $$shell_quote($$shell_path($$PWD/deploy.py)) $$QTIFW_DEPLOY_ARGS

	qtifw_deploy_clean.target = deploy-clean
	win32: qtifw_deploy_clean.commands = $$QMAKE_DEL_FILE /S /Q $$shell_quote($$shell_path($$DEPLOY_PATH))
	else: qtifw_deploy_clean.commands = $$QMAKE_DEL_FILE -r $$shell_quote($$shell_path($$DEPLOY_PATH))
	clean.depends += qtifw_deploy_clean

	QMAKE_EXTRA_TARGETS += qtifw_deploy clean qtifw_deploy_clean
}
