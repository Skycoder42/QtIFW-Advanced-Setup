DISTFILES += \
	$$PWD/deploy_mac.command \
	$$PWD/deploy_x11.sh \
	$$PWD/deploy_win.bat

!isEmpty(QTIFW_DEPLOY_SRC) {
	isEmpty(QTIFW_DEPLOY_OUT): QTIFW_DEPLOY_OUT = $$OUT_PWD/deployed

	#prepare common args
	linux {
		QTIFW_DEPLOY_ARGS += $$shell_quote($$[QT_INSTALL_BINS])
		QTIFW_DEPLOY_ARGS += $$shell_quote($$[QT_INSTALL_PLUGINS])
		QTIFW_DEPLOY_ARGS += $$shell_quote($$[QT_INSTALL_TRANSLATIONS])
	}

	QTIFW_DEPLOY_ARGS += $$shell_quote($$QTIFW_DEPLOY_SRC)
	QTIFW_DEPLOY_ARGS += $$shell_quote($$QTIFW_DEPLOY_OUT)
	!isEmpty(QTIFW_DEPLOY_TSPRO): QTIFW_DEPLOY_ARGS += $$shell_quote($$QTIFW_DEPLOY_TSPRO)

	qtifw_deploy.target = deploy
	linux: qtifw_deploy.commands = $$shell_quote($$shell_path($$PWD/deploy_x11.sh)) $$QTIFW_DEPLOY_ARGS
	else:win32: qtifw_deploy.commands = $$shell_quote($$shell_path($$PWD/deploy_win.bat)) $$QTIFW_DEPLOY_ARGS
	else:mac: qtifw_deploy.commands = $$shell_quote($$shell_path($$PWD/deploy_mac.command)) $$QTIFW_DEPLOY_ARGS

	QMAKE_EXTRA_TARGETS += qtifw_deploy
}
