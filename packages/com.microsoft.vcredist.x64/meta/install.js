function Component(){}

Component.prototype.createOperations = function()
{
	try {
		component.createOperations();
		if (installer.value("os") === "win") {
			//install visual studio redistributables and delete the file right after
			component.addElevatedOperation("Execute", "@TargetDir@/vcredist_x64.exe", "/quiet", "/norestart");
			component.addOperation("Delete", "@TargetDir@/vcredist_x64.exe");
			component.addOperation("Delete", "@TargetDir@/vcredist_x86.exe");
			component.addOperation("Delete", "@TargetDir@/vcredist_arm.exe");
		}
	} catch (e) {
		print(e);
	}
}
