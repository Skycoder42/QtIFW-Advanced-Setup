!qpmx_static {
	include($$PWD/deploy/deploy.pri)
	include($$PWD/installer/installer.pri)

	qtifw_install_target {
		# update installer target deps
		contains(QMAKE_EXTRA_TARGETS, qtifw_deploy) {
			!isEmpty(QTIFW_TS_TARGET): qtifw_deploy.depends += $$first(QTIFW_TS_TARGET)
			qtifw_inst.depends += deploy
		}

		target_r.target = install
		target_r.commands = echo install done
		target_r.depends = installer

		equals(QTIFW_MODE, repository)|equals(QTIFW_MODE, online_all) { #deploy repository
			target_p.target = target_p
			target_p.depends = installer

			win32: QTIFW_REPO_NAME = ../repository_win.zip
			else:mac: QTIFW_REPO_NAME = ../repository_mac.tar.xz
			else: QTIFW_REPO_NAME = ../repository_linux.tar.xz

			qtifw_no_compress: target_p.commands = $$QMAKE_INSTALL_DIR $$shell_quote($$shell_path($$QTIFW_DIR/repository)) $$shell_path($(INSTALL_ROOT)/)
			else:win32: target_p.commands = cd $$shell_quote($$shell_path($$QTIFW_DIR/repository)) && \
				7z a $$shell_path($$QTIFW_REPO_NAME) .\* && \
				$$QMAKE_INSTALL_FILE $$shell_path($$QTIFW_REPO_NAME) $$shell_path($(INSTALL_ROOT)/)
			else: target_p.commands = cd $$shell_quote($$QTIFW_DIR/repository) && \
				tar cJf $$QTIFW_REPO_NAME ./* && \
				$$QMAKE_INSTALL_FILE $$QTIFW_REPO_NAME $(INSTALL_ROOT)/

			target_d.target = target_d
			win32: target_d.commands = $$QMAKE_MKDIR $$shell_path($(INSTALL_ROOT)/) || (exit 0)
			else: target_d.commands = $$QMAKE_MKDIR $$shell_path($(INSTALL_ROOT)/) || true
			target_p.depends += target_d

			target_r.depends += target_p
			QMAKE_EXTRA_TARGETS += target_d target_p
		}

		!equals(QTIFW_MODE, repository) { #deploy installer binary
			target_b.target = target_b
			!mac: target_b.commands = $$QMAKE_INSTALL_PROGRAM $$shell_quote($$shell_path($$QTIFW_DIR/$${QTIFW_TARGET}$${QTIFW_TARGET_x})) $$shell_path($(INSTALL_ROOT)/)
			else:qtifw_no_compress: target_b.commands = $$QMAKE_INSTALL_DIR $$shell_quote($$shell_path($$QTIFW_DIR/$${QTIFW_TARGET}$${QTIFW_TARGET_x})) $$shell_path($(INSTALL_ROOT)/)
			else: target_b.commands = cd $$shell_quote($${QTIFW_DIR}) && \
				zip -r -9 $$shell_quote($${QTIFW_TARGET}$${QTIFW_TARGET_x}.zip) $$shell_quote($${QTIFW_TARGET}$${QTIFW_TARGET_x}) && \
				$$QMAKE_INSTALL_FILE $$shell_quote($${QTIFW_TARGET}$${QTIFW_TARGET_x}.zip) $$shell_path($(INSTALL_ROOT)/)
			target_b.depends = installer

			target_r.depends += target_b
			QMAKE_EXTRA_TARGETS += target_b
		}

		!ReleaseBuild:!DebugBuild: QMAKE_EXTRA_TARGETS += target_r
	}
}
