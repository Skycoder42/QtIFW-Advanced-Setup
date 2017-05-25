DISTFILES += \
	$$PWD/deploy.py

!isEmpty(QTIFW_DEPLOY_SRC) {
	isEmpty(QTIFW_DEPLOY_OUT): QTIFW_DEPLOY_OUT = $$OUT_PWD/deployed

	linux: QTIFW_DEPLOY_ARGS = linux
	else:win32:CONFIG(release, debug|release): QTIFW_DEPLOY_ARGS = win_release
	else:win32:CONFIG(debug, debug|release): QTIFW_DEPLOY_ARGS = win_debug
	else:mac: QTIFW_DEPLOY_ARGS = mac
	else: QTIFW_DEPLOY_ARGS = unknown

	QTIFW_DEPLOY_ARGS += $$shell_quote($$[QT_INSTALL_BINS])
	QTIFW_DEPLOY_ARGS += $$shell_quote($$[QT_INSTALL_PLUGINS])
	QTIFW_DEPLOY_ARGS += $$shell_quote($$[QT_INSTALL_TRANSLATIONS])
	QTIFW_DEPLOY_ARGS += $$shell_quote($$QTIFW_DEPLOY_SRC)
	QTIFW_DEPLOY_ARGS += $$shell_quote($$QTIFW_DEPLOY_OUT)
	!isEmpty(QTIFW_DEPLOY_TSPRO): QTIFW_DEPLOY_ARGS += $$shell_quote($$QTIFW_DEPLOY_TSPRO)

	qtifw_deploy.target = deploy
	linux: qtifw_deploy.commands = $$shell_quote($$shell_path($$PWD/deploy.py)) $$QTIFW_DEPLOY_ARGS
	else:win32: qtifw_deploy.commands = python $$shell_quote($$shell_path($$PWD/deploy.py)) $$QTIFW_DEPLOY_ARGS
	else:mac: qtifw_deploy.commands = /usr/local/bin/python3 $$shell_quote($$shell_path($$PWD/deploy.py)) $$QTIFW_DEPLOY_ARGS

	QMAKE_EXTRA_TARGETS += qtifw_deploy
}
