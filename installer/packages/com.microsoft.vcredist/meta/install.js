function Component(){}

Component.prototype.createOperations = function()
{
	try {
		component.createOperations();
		if (installer.value("os") === "win") {
			var vcpath = "@TargetDir@/" + vcname();
			//install visual studio redistributables and delete the file right after
			component.addElevatedOperation("Execute", vcpath, "/quiet", "/norestart");
			component.addOperation("Delete", vcpath);
		}
	} catch (e) {
		print(e);
	}
}
