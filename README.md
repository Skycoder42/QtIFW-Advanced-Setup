# QtIFW-Advanced-Setup
Create "Qt Installer Framework" installers from your project via qmake

## Features
- Easily creation of installers via qmake
- Windows: Automatic inclusion of msvc libs as installation (if required)
- Extends default installer functionality:
	- provide uninstall only for offline installers
	- Hide uninstall/... by special command line switch
	- Adds local vs global installation
		- Global installation requires admin/root and chooses global location
		- Local installation uses user directories
		- Maintenancetool ensures it's privileged if installed globally
	- Windows: Allows to create a desktop shortcut
	- Windows: proper registration as "Installed Application"
	- Windows: Adds update/modify shortcuts to the windows startmenu directory
	- Linux: Automatic desktop file creation

## Installation
The package is providet as qpm package, [`de.skycoder42.qtifw-advanced-setup`](https://www.qpm.io/packages/de.skycoder42.qtifw-advanced-setup/index.html). To install:

1. Install qpm (See [GitHub - Installing](https://github.com/Cutehacks/qpm/blob/master/README.md#installing))
2. In your projects root directory, run `qpm install de.skycoder42.qtifw-advanced-setup`
3. Include qpm to your project by adding `include(vendor/vendor.pri)` to your `.pro` file

Check their [GitHub - Usage for App Developers](https://github.com/Cutehacks/qpm/blob/master/README.md#usage-for-app-developers) to learn more about qpm.

## Usage
Check the example application for a full demonstration. The idea is: You specify files and directories via your pro-file and run `make installer` to create the installer.

This example shows the "minimal" input to create an installer:
```.pro
QTIFW_CONFIG = config.xml	#Configuration file, and other files for the config dir
QTIFW_MODE = online_all		#select the kind of installer to create

#define one package of your installer
sample.pkg = de.skycoder42.qtifwsample	#the package name
sample.meta = meta 						#directories with metadata (i.e. the "meta" directory of the package)
sample.data = data "$$OUT_PWD/deploy"	#directories with installation data (i.e. the "data" directory of the package)

QTIFW_PACKAGES += sample #add all packages

# IMPORTANT! Setup the variables BEFORE including the pri file
include(vendor/vendor.pri)
```

To create the installer, simply run `make installer`.

### Variable documentation
 Variable Name	| Default value 														| Description
----------------|-----------------------------------------------------------------------|-------------
 QTIFW_BIN		| `$$[QT_INSTALL_BINS]/../../../Tools/QtInstallerFramework/2.0/bin/`	| The directory containing the QtIFW Tools (repogen, binarycreator, etc.). The default value assumes you installed Qt and QtIFW via the online installer and that QtIFW is of version 2.0. Adjust the path if your tools are located elsewhere
 QTIFW_DIR		| `qtifw-installer`														| The directory (relative to the build directory) to place the installer files in
 QTIFW_MODE		| `offline`																| The type of installer to create. Can be: `offline`: Offline installer, `online`: Online installer, `repository`: The remote repository for an online installer, `online_all`: Both, the online installer and remote repository
 QTIFW_TARGET	| `$$TARGET Installer`													| The base name of the installer binary
 QTIFW_TARGET_x	| win:`.exe`, linux:`.run`, mac:`.app`									| The extension of the installer binary
 QTIFW_CONFIG	| _must not be empty_													| Files for the configuration directory. **Must** contain a file named `config.xml` with the installer configuration
 QTIFW_PACKAGES	| _empty_																| A list of all packages to install. Must be of type `package`
 
 #### The `package` type
 All entries of the QTIFW_PACKAGES variable must be such entries. They are defined as "objects" with the following variables:
 
 Variable Name	| Description
----------------|-------------
 pkg			| The unique name (identifier) of the package
 meta			| A list of directories to be copied into the packages "meta" directory
 data			| A list of directories to be copied into the packages "data" directory