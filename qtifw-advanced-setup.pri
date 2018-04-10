!qpmx_static {
	include($$PWD/deploy/deploy.pri)

	qtifw_target {
		qtifwtarget.target = qtifw
		qtifwtarget.depends += deploy

		QMAKE_EXTRA_TARGETS += qtifwtarget
	}
}
