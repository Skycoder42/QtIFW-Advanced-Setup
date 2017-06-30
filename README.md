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
- simple deployment as additional step before creating the installer
	- uses the qt deployment tools to deploy your application
	- option to include custom and Qt translations
	- auto-deploy flag to automate deployment even further
- automatic install target generation

## Installation
The package is providet as qpm package, [`de.skycoder42.qtifw-advanced-setup`](https://www.qpm.io/packages/de.skycoder42.qtifw-advanced-setup/index.html). To install:

1. Install qpm (See [GitHub - Installing](https://github.com/Cutehacks/qpm/blob/master/README.md#installing), for **windows** see below)
2. In your projects root directory, run `qpm install de.skycoder42.qtifw-advanced-setup`
3. Include qpm to your project by adding `include(vendor/vendor.pri)` to your `.pro` file

Check their [GitHub - Usage for App Developers](https://github.com/Cutehacks/qpm/blob/master/README.md#usage-for-app-developers) to learn more about qpm.

**Important for Windows users:** QPM Version *0.10.0* (the one you can download on the website) is currently broken on windows! It's already fixed in master, but not released yet. Until a newer versions gets released, you can download the latest dev build from here:
- https://storage.googleapis.com/www.qpm.io/download/latest/windows_amd64/qpm.exe
- https://storage.googleapis.com/www.qpm.io/download/latest/windows_386/qpm.exe

## Requirements
In order to use QtIFW-Advanced-Setup, you need the following installed:
- QtIFW: ideally as part of your Qt Installation. Use the online installer and find it under `Qt > Tools`
- Python3: A pyhton script is used to generate the installer from the input. Thus, you need to have **Python 3** installed!
- If you want to use the deployment feature on linux, you need linuxdeployqt (See following chapter)

### Linuxdeployqt
Since Qt does not provide it's own deployment tool for linux, I am using [linuxdeployqt](https://github.com/probonopd/linuxdeployqt) in this package. However, the default binary from the project makes integration problematic. Until the changes to make it possible are done, I created a fork that applies those changes. In order to get linuxdeployqt installed in proper Qt-Tool way, simply run the [get_linuxdeployqt_compat.sh](./get_linuxdeployqt_compat.sh) script. The script builds and installs linuxdeployqt into your Qt installation directory.

This is only a workaround, and while the script will stay, the install method for linuxdeployqt may change over time.

## Usage
The idea is: You specify files and directories via your pro-file and run `make <target>` to deploy, create the installer, or both.

When using all of the qtifw features, the amount of work you need to do shrinks down to the following:

1. Add installation stuff to your `pro` file. Check the [Installer](#installer) chapter for details.
2. Enable automatic deployment and the install target by adding `CONFIG += qtifw_auto_deploy qtifw_install_target` to your pro file
3. Run `make install` after the compilation to create the installer and copy the binaries to `/`
	- use `make INSTALL_ROOT=<path_to_install_to> install` to specify the directory to copy files to.

The [Example project](Example/Example.pro) shows a full example of how to use QtIFW-Advanced-Setup.

### Installer
This example shows the "minimal" input to create an installer:
```.pro
QTIFW_CONFIG = config.xml	#Configuration file, and other files for the config dir
QTIFW_MODE = online_all		#select the kind of installer to create

#define one package of your installer
sample.pkg = de.skycoder42.qtifwsample            #the package name
sample.meta = meta                                #directories with metadata (i.e. the "meta" directory of the package)
sample.dirs = data                                #directories with installation data (i.e. the "data" directory of the package)
win32: sample.files = "$$OUT_PWD/$${TARGET}.exe"  #files to be copied to the data directory
else: ...

QTIFW_PACKAGES += sample #add all packages

# IMPORTANT! Setup the variables BEFORE including the pri file
include(vendor/vendor.pri)
```

To create the installer, simply run `make installer`.

#### Variable documentation
 Variable Name	| Default value								| Description
----------------|-------------------------------------------|-------------
 QTIFW_BIN		| `...`										| The directory containing the QtIFW Tools (repogen, binarycreator, etc.). The default value assumes you installed Qt and QtIFW via the online installer and that QtIFW is of version 2.0. Adjust the path if your tools are located elsewhere
 QTIFW_DIR		| `qtifw-installer`							| The directory (relative to the build directory) to place the installer files in
 QTIFW_MODE		| `offline`									| The type of installer to create. Can be:<br>`offline`: Offline installer<br>`online`: Online installer<br>`repository`: The remote repository for an online installer<br>`online_all`: Both, the online installer and remote repository
 QTIFW_TARGET	| `$$TARGET Installer`						| The base name of the installer binary
 QTIFW_TARGET_x	| win:`.exe`<br>linux:`.run`<br>mac:`.app`	| The extension of the installer binary
 QTIFW_CONFIG	| _must not be empty_						| Files for the configuration directory. **Must** contain a file named `config.xml` with the installer configuration
 QTIFW_PACKAGES	| _empty_									| A list of all packages to install. Must be of type `package`
 QTIFW_VCPATH	| _default path to vcredist*.exe_			| Windows only: The path to the vcredist installer to added to the installer. The vcredists are needed if you build with the msvc-compiler

**Note for Windows Users:** With msvc2015 or older, the vcredist files are somewhat strange and prevent you from delete their copies via anything by the explorer. This means only the first time you create the installer it works fine. After that, you have to delete the build folder yourself via the explorer before you can build the installer again. This issue seems to have disappeared with msvc2017.

##### The `package` type
 All entries of the QTIFW_PACKAGES variable must be such entries. They are defined as "objects" with the following variables:

 Member Name	| Description
----------------|-------------
 pkg			| The unique name (identifier) of the package
 meta			| A list of directories to copy their contents into the packages "meta" directory
 dirs			| A list of directories to copy their contents into the packages "data" directory
 files			| A list of files to be copied into the packages "data" directory

### Deployment
As additional feature, you can generate a deployment target as well. This can be used by running `make deploy`. To use the feature, add the following to your pro file:
```pro
# automatically creates a default deployment target
CONFIG += qtifw_auto_deploy

# if you have translations, specify the pro-file to be scanned for them
QTIFW_DEPLOY_TSPRO = $$_PRO_FILE_

# to include the deployed files into your installer either add the folder to <package>.dirs or do it automatically
sample.pkg = de.skycoder42.qtifwsample
sample.meta = meta
QTIFW_AUTO_INSTALL_PKG = sample

QTIFW_PACKAGES += sample
```

#### Variable documentation
 Variable Name			| Default value	| Description
------------------------|---------------|-------------
 QTIFW_DEPLOY_SRC		| _empty_		| The source file/directory to be deployed. Only one element, type defined by platform
 QTIFW_DEPLOY_OUT		| `deployed`	| The directory (relative to the build directory) to place the deployed files in
 QTIFW_AUTO_INSTALL_PKG	| _empty_		| The name of a package to add the files generated by `qtifw_auto_deploy` to
 QTIFW_DEPLOY_LCOMBINE	| _qpm-path_	| The path to the lcombine.py script (part of `de.skycoder42.qpm-translate). Needed for MacOs translation generation only.

#### The `qtifw_auto_deploy` configuration flag
If set (by adding `CONFIG += qtifw_auto_deploy` to your pro file), the deployment files are detected automatically. It's basically a shortcut for the code below:

```pro
win32:CONFIG(debug, debug|release): QTIFW_DEPLOY_SRC = $$shadowed(debug/$${TARGET}.exe)
else:win32:CONFIG(release, debug|release): QTIFW_DEPLOY_SRC = $$shadowed(release/$${TARGET}.exe)
else:mac: QTIFW_DEPLOY_SRC = $$shadowed($${TARGET}.app)
else: QTIFW_DEPLOY_SRC = $$shadowed($$TARGET)

!isEmpty(QTIFW_AUTO_INSTALL_PKG) { #NOTE: pseudo code, won't work like that
	mac: $$first(QTIFW_AUTO_INSTALL_PKG).dirs += $$OUT_PWD/deployed/$${TARGET}.app
	else: $$first(QTIFW_AUTO_INSTALL_PKG).dirs += $$OUT_PWD/deployed
}
```

### `install` target
If set (by adding `CONFIG += qtifw_install_target` to your pro file), you can, instead of using `make deploy` and `make installer`, simply use the standard `make install` command to automatically deploy (if deployment is used), create the installer, and copy the relevant binaries and directories to the install directory.
