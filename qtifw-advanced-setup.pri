!qpmx_static {
	qtifw_target: CONFIG *= qtifw_install_targets

	include($$PWD/deploy/deploy.pri)
	include($$PWD/installer/installer.pri)

	qtifw_install_compress.target = qtifw-compress
	QMAKE_EXTRA_TARGETS += qtifw_install_compress
	equals(QTIFW_MODE, repository)|equals(QTIFW_MODE, online_all) { #deploy repository
		target_c_rep.target = target_c_rep
		target_c_rep.depends = installer
		QMAKE_EXTRA_TARGETS += target_c_rep
		qtifw_install_compress.depends += target_c_rep

		win32: QTIFW_REPO_NAME = ../repository_win.zip
		else:mac: QTIFW_REPO_NAME = ../repository_mac.tar.xz
		else: QTIFW_REPO_NAME = ../repository_linux.tar.xz

		target_c_rep.commands = cd $$shell_path($(INSTALL_ROOT)/repository) &&
		win32: target_c_rep.commands += 7z a $$shell_path($$QTIFW_REPO_NAME) .\*
		else: target_c_rep.commands += tar cJf $$QTIFW_REPO_NAME ./*
	}

	!equals(QTIFW_MODE, repository):mac { #deploy installer binary
		target_c_mac.target = target_c_mac
		target_c_mac.depends = installer
		QMAKE_EXTRA_TARGETS += target_c_mac
		qtifw_install_compress.depends += target_c_mac

		target_c_mac.commands = cd $(INSTALL_ROOT) && \
			zip -r -9 $$shell_quote($${QTIFW_TARGET}$${QTIFW_TARGET_x}.zip) $$shell_quote($${QTIFW_TARGET}$${QTIFW_TARGET_x})
	}

	qtifw_target {
		!qtifw_deploy_no_install: qtifw_deploy.depends += install
		qtifw_inst.depends += deploy
		qtifw_install_compress.depends += installer

		qtifwtarget.target = qtifw
		qtifwtarget.depends += qtifw-compress

		QMAKE_EXTRA_TARGETS += qtifwtarget
	}
}
