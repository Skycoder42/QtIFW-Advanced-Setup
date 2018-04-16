# QtIFW-Advanced-Setup
Create "Qt Installer Framework" installers from your project via qmake

**Important:** With Version 2.0.0 the api has completly changed. Now the `make install` step is used to prepare all files, so that deployment/installer generation operate on the installed files. Read the documentation carefully to pick up how to change your pro files! (The old code is still existant as the `old` branch or as qpm packages before version 2.0.0)

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
- uses make install for simple file preperations
- Provides the `qtifw` and `qtifw-build` targets to automatically (translate, install, ) deploy, create the installer and compress it

## Installation
The package is providet as qpm  package, [`de.skycoder42.qtifw-advanced-setup`](https://www.qpm.io/packages/de.skycoder42.qtifw-advanced-setup/index.html). You can install it either via qpmx (preferred) or directly via qpm.

### Via qpmx
[qpmx](https://github.com/Skycoder42/qpmx) is a frontend for qpm (and other tools) with additional features, and is the preferred way to install packages. To use it:

1. Install qpmx (See [GitHub - Installation](https://github.com/Skycoder42/qpmx#installation))
2. Install qpm (See [GitHub - Installing](https://github.com/Cutehacks/qpm/blob/master/README.md#installing), for **windows** see below)
3. In your projects root directory, run `qpmx install de.skycoder42.qtifw-advanced-setup`

### Via qpm

1. Install qpm (See [GitHub - Installing](https://github.com/Cutehacks/qpm/blob/master/README.md#installing), for **windows** see below)
2. In your projects root directory, run `qpm install de.skycoder42.qtifw-advanced-setup`
3. Include qpm to your project by adding `include(vendor/vendor.pri)` to your `.pro` file

Check their [GitHub - Usage for App Developers](https://github.com/Cutehacks/qpm/blob/master/README.md#usage-for-app-developers) to learn more about qpm.

**Important for Windows users:** QPM Version *0.10.0* (the one you can download on the website) is currently broken on windows! It's already fixed in master, but not released yet. Until a newer versions gets released, you can download the latest dev build from here:
- https://storage.googleapis.com/www.qpm.io/download/latest/windows_amd64/qpm.exe
- https://storage.googleapis.com/www.qpm.io/download/latest/windows_386/qpm.exe

## Requirements
In order to use QtIFW-Advanced-Setup, you need the following installed:

- **QtIFW:** ideally as part of your Qt Installation. Use the online installer and find it under `Qt > Tools`
- **Python 3:** A pyhton script is used to generate the installer from the input. Thus, you need to have *Python 3* installed!
- **linuxdeployqt:** If you want to use the deployment feature on linux, you need linuxdeployqt (See following chapter)

### Linuxdeployqt
Since Qt does not provide it's own deployment tool for linux, I am using [linuxdeployqt](https://github.com/probonopd/linuxdeployqt) in this package. This tool needs to be placed in the Qt install directory. To simplify this step, you can run the [get_linuxdeployqt_compat.sh](./get_linuxdeployqt_compat.sh) script. The script builds and installs linuxdeployqt into your Qt installation directory.

This is only a workaround, and while the script will stay, the install method for linuxdeployqt may change over time.

## Usage
The idea is: You specify files and directories via your pro-file and run `make <target>` to deploy, create the installer, or both.

When using all of the qtifw features, the amount of work you need to do shrinks down to the following:

1. Use make install targets to copy all the files you need for your installer to installer build directory
2. configure the installer generation via qmake variables and configurations
3. Run the make targets you want to generate the installer and use `INSTALL_ROOT` to specify where to do so

Generating an installer consists 5 targets that depend on each other. This means you have to run those 5 make targets in order to generate an installer. However, for simplicity, you can enable a single "master target" called
`qtifw` to do all 5 steps via one command. In addition, there is the `qtifw-build` target that automatically sets a subfolder in your build directory as the `INSTALL_ROOT`. The steps as follwos, and are explained in more detail below:

1. `lrelease` (optional, disabled by default)
2. `install`
3. `deploy`
4. `installer`
5. `qtifw-compress` (optional, enabled by default)

In short: Simply set up your pro file correctly and then run `make qtifw-build` to do all those steps as needed. The [Example project](Example/Example.pro) shows a full example of how to use QtIFW-Advanced-Setup.

### Translations (`make lrelease`)
The `lrelease` step is an optional step provided by qpmx that will generate qm files for all the translations specified via the `TRANSLATIONS` qmake variable. See [qpmx - Translations](https://github.com/Skycoder42/qpmx#translations) for more details.

When using the `qtifw` target, translations are not generated by default. You can enable them by adding `CONFIG += qtifw_auto_ts` to your pro file.

The example code for the pro file would look like this: 
```pro
TRANSLATIONS += myapp.ts
```

#### Variables
 Variable Name		| Default value	| Description
--------------------|----------------|-------------
 TRANSLATIONS		| *empty*		| The translations to be generated
 EXTRA_TRANSLATIONS	| *empty*		| Additional translations to be generated

#### Install targets (with target.files automatically filled)
- `qpmx_ts_target`: Install target for `TRANSLATIONS`
- `extra_ts_target`: Install target for `EXTRA_TRANSLATIONS`

### Installation (`make install`)
The install targets should be used to prepare the application for deployment/installer creation by placing all
files where they need to be for the installer. The install should look like this:
```
/config
	/config.xml
	/...
/packages
	/com.example.my-package
		/meta
			/package.xml
			/install.js
			/...
		/data
			/example.exe
			/...
	/com.example.another-package
		/...
```

The config directory should contain all installer configuration files. The package directory should consist of multiple subdirectories named after the installer package the contain. The internal structure of those package directories is the one QtIFW needs.

To stay with this example, the following qmake code could be used to create such a setup:
```pro
# install the config.xml
install_cfg.files = config.xml
install_cfg.path = /config
INSTALLS += install_cfg

# install the package meta folder
install_pkg.files += meta
install_pkg.path = /packages/com.example.my-package
INSTALLS += install_pkg

# install the executable
target.path = /packages/com.example.my-package/data
INSTALLS += target

# optional: install the generated translations
qpmx_ts_target.path = /packages/com.example.my-package/data/translations
INSTALLS += qpmx_ts_target
```

Simply running `make INSTALL_ROOT=... install` will copy all the specified files, plus all the additional stuff that is needed to create an installer.

**Important:** For this to work you *always* have to specify an install root as parameter to make. All installations as stated above will be put into that directory - meaning forgetting it would install that stuff into your root filesystem! When using the `qtifw-build` target however, you don't have to care about this.

### Deployment (`make deploy`)
Deployment is performed on the already install binary, so that all the deployed files are automatcially placed in the installer directories. The deployment target is automatically determined by using the `target.path` to find out where to find the project binary. However, you can also specify the deployment target yourself by setting the `qtifw_deploy_target`. So unless you need to specify additional deploy targets, you typically don't have to setup
anything at all in your pro file for this step!

#### The `qtifw_deploy_target` target
 Target Property	| Default value				| Description
----------------|----------------------------|-------------
 path			| `$${target.path}`			| The path to find the binaries to be deployed at
 files			| `$${TARGET}$${TARGET_EXT}`	| The binaries to be deployed. By default this is the main target of your project that you are building.

### Installer generation (`make installer`)
This step create the actual QtIFW-Installer and/or repositories out of youre previously installed and deployed files. Just like the previous steps, it uses the `INSTALL_ROOT` to find the `config` and `packages` directories and uses their contents to create the installer. They are created in the very same directory. You can configure how the generation is performed by using the following qmake variables.

**Important:** When *not* using the `qtifw` or `qtifw-build` mode, you have to explicitly enable the installtion of the additional installer files that are required to create the installer. This is done by adding `CONFIG += qtifw_install_targets` to your pro file. This is not needed if you already have the `CONFIG += qtifw_target` line in your pro file.

#### Variables
 Variable Name		| Default value								| Description
---------------------|--------------------------------------------|-------------
 QTIFW_BIN			| `...`										| The directory containing the QtIFW Tools (repogen, binarycreator, etc.). The default value assumes you installed Qt and QtIFW via the online installer and that QtIFW is of version 3.0. Adjust the path if your tools are located elsewhere
 QTIFW_MODE			| `offline`									| The type of installer to create. Can be:<br>`offline`: Offline installer<br>`online`: Online installer<br>`repository`: The remote repository for an online installer<br>`online_all`: Both, the online installer and remote repository
 QTIFW_TARGET		| `$$TARGET Installer`						| The base name of the installer binary
 QTIFW_TARGET_EXT	| win:`.exe`<br>linux:`.run`<br>mac:`.app`	| The extension of the installer binary
 QTIFW_VCPATH		| _default path to vcredist*.exe_			| Windows only: The path to the vcredist installer to added to the installer. The vcredists are needed if you build with the msvc-compiler

**Note for Windows Users:** With msvc2015 or older, the vcredist files are somewhat strange and prevent you from delete their copies via anything but the explorer. This means only the first time you create the installer it works fine. After that, you have to delete the build folder yourself via the explorer before you can build the installer again. This issue seems to have disappeared with msvc2017.

### Repository compression (`make qtifw-compress`)
The final optional step is to compress the repositories and the installer app bundle for mac. This target does not need any configuration. It will simply create a compressed archive of the repositories and the app bundle on mac for easier deployment. You will need the `tar` and `xz` tools on linux and mac, the `zip` tool on mac and the `7z` tool on windows.

You can disable this step for the `qtifw` target by adding `CONFIG += qtifw_no_compress` to your pro file.

### The high level qtifw targets (`make qtifw` and `make qtifw-build`)
As stated at the beginning of this document, the `qtifw` target is basically a shortcut to run all the above steps via one command. In order to enable this target, you must add `CONFIG += qtifw_target` to your pro file. You can configure how this target behaves via the following configurations.

The `qtifw-build` is an additional helper that will cann `qtifw` with an automatically determined install root. So instead of running `make INSTALL_ROOT=/path/to/build/qtifw-build qtifw` you can simply use `make qtifw-build`. The path `/path/to/build` is replaced by `$$OUT_PWD` from qmake.

**Important:** For the classic `qtifw` to work you *always* have to specify an install root as parameter to make. All operations as stated above will be run inside that directory - meaning forgetting it would install that stuff into your root filesystem! When using the `qtifw-build` target however, you don't have to care about this.

#### CONFIG options
 Option						| Description
-----------------------------|-------------
 `qtifw_target`				| Enables the `qtifw` and `qtifw-build` targets and creates the automatic dependencies between the lrelease, install, deploy, installer and qtifw-compress targets. Also, it automatically adds `qtifw_install_targets` to the `CONFIG` as well.
 `qtifw_install_targets`		| Enables the automatic installation of all internal installer related extra files. This must be defined to create an installer.
 `qtifw_auto_ts`				| Enables an automatic dependency between `lrelease` and `install`, i.e. `make install` will now automatically call `make lrelease` first
 `qtifw_deploy_no_install`	| Disables the dependency between `install` and `deploy`. I.e. now the `qtifw` target will *not* automatically run `make install` anymore. This can be useful when integrating with build systems to seperate the install and installer generation steps.
 `qtifw_no_compress`			| Disables the automatic `qtifw-compress` step, i.e. prevents the compressed archives from beeing generated.