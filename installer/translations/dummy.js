function testArch() {
	if(systemInfo.currentCpuArchitecture.search("64") < 0) {
		QMessageBox.critical("de.skycoder42.advanced-setup.not64", qsTr("Error"), qsTr("This Program is a 64bit Program. You can't install it on a 32bit machine"));
		gui.rejectWithoutPrompt();
		return false;
	} else
		return true;
}
