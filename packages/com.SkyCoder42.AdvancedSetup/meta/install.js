function Component()
{
    //save the binary name
    installer.setValue("BinaryName", installer.value("RunProgram"));

    //check if architecture is supported
    if(systemInfo.currentCpuArchitecture.search("64") < 0) {
        QMessageBox.critical("com.SkyCoder42.AdvancedSetup.not64", qsTr("Error"), qsTr("This Program is a 64bit Program. You can't install it on a 32bit machine"));
        gui.rejectWithoutPrompt();
    }

    //add custom pages (installer only)
    if(installer.isInstaller()) {
        installer.addWizardPage(component, "UserPage", QInstaller.TargetDirectory);
        if (installer.value("os") === "win")// only windows -> desktop shortcut
            installer.addWizardPage(component, "ShortcutPage", QInstaller.ReadyForInstallation);
    }
}

Component.prototype.createOperations = function()
{
    //update RunProgram, depending on the os
    if (installer.value("os") === "win") {
        installer.setValue("RunProgram", "@TargetDir@/@BinaryName@");
    } else if(installer.value("os") === "mac") {
        installer.setValue("RunProgram", "@TargetDir@/Contents/MacOS/@BinaryName@");
    } else if(installer.value("os") === "x11") {
        installer.setValue("RunProgram", "@TargetDir@/@BinaryName@");
    }

    try {
        component.createOperations();

        if (installer.value("os") === "win") {
            //win -> add startmenu shortcuts
            component.addOperation("CreateShortcut", "@RunProgram@.exe", "@StartMenuDir@/@Name@.lnk");
            if(installer.isOfflineOnly())
                component.addOperation("CreateShortcut", "@TargetDir@/@MaintenanceToolName@.exe", "@StartMenuDir@/Uninstall.lnk");
            else {
                component.addOperation("CreateShortcut", "@TargetDir@/@MaintenanceToolName@.exe", "@StartMenuDir@/@MaintenanceToolName@.lnk");
                component.addOperation("CreateShortcut", "@TargetDir@/@MaintenanceToolName@.exe", "@StartMenuDir@/ManagePackages.lnk", "--manage-packages");
                component.addOperation("CreateShortcut", "@TargetDir@/@MaintenanceToolName@.exe", "@StartMenuDir@/Update.lnk", "--updater");
                component.addOperation("CreateShortcut", "@TargetDir@/@MaintenanceToolName@.exe", "@StartMenuDir@/Uninstall.lnk", "uninstallOnly=1");
            }

            //... and desktop shortcut (if requested)
            var pageWidget = gui.pageWidgetByObjectName("DynamicShortcutPage");
            if (pageWidget !== null && pageWidget.shortcutCheckBox.checked)
                component.addOperation("CreateShortcut", "@RunProgram@.exe", "@DesktopDir@/@Name@.lnk");
        } else if (installer.value("os") === "x11") {
            //x11 -> create .desktop file
            component.addOperation("CreateDesktopEntry",
                                   "@BinaryName@.desktop",
                                   "Version=1.0\nType=Application\nTerminal=false\nExec=@RunProgram@\nName=@Name@\nIcon=@TargetDir@/main.png");
        }
    } catch (e) {
        print(e);
    }
}
