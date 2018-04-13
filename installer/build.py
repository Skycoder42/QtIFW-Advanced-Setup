#!/usr/bin/env python3

import sys
import os
import shutil
import subprocess
import re
import glob
from distutils.dir_util import copy_tree
from enum import Enum

# constants
outdir = sys.argv[1]
qtifwdir = sys.argv[2]
target = sys.argv[3]

mode = sys.argv[4]
platform = sys.argv[5]
arch = sys.argv[6]

cfgdir = os.path.join(outdir, "config")
pkgdir = os.path.join(outdir, "packages")

subTDir = ""

def prepend_file_data(filename, data):
	with open(filename, "r+") as file:
		orig = file.read()
		file.seek(0)
		file.write(data)
		file.write(orig)

def config_arch():
	#adjust install js
	data = ""
	if arch == "x64":
		data = "function testArch() {\n"
		data += "\tif(systemInfo.currentCpuArchitecture.search(\"64\") < 0) {\n"
		data += "\t\tQMessageBox.critical(\"de.skycoder42.advanced-setup.not64\", qsTr(\"Error\"), qsTr(\"This Program is a 64bit Program. You can't install it on a 32bit machine\"));\n"
		data += "\t\tgui.rejectWithoutPrompt();\n"
		data += "\t\treturn false;\n"
		data += "\t} else\n"
		data += "\t\treturn true;\n"
		data += "}\n\n"
	else:
		data = "function testArch() {\n"
		data += "\treturn true;\n"
		data += "}\n\n"
	prepend_file_data(os.path.join(pkgdir, "de.skycoder42.advancedsetup", "meta", "install.js"), data)

	#adjust vcredist (if existing)
	msvc_dir = os.path.join(pkgdir, "com.microsoft.vcredist." + arch)
	msvc_data_dir = os.path.join(msvc_dir, "data")
	if os.path.isdir(msvc_data_dir):
		files = os.listdir(msvc_data_dir)
		regex = re.compile(".*vcredist.*" + arch + ".*")
		vcfile = ""
		for file in files:
			if regex.match(file):
				vcfile = file
			else:
				os.remove(os.path.join(msvc_data_dir, file))
		data = "function vcname() {\n"
		data += "\t return \"" + vcfile + "\";\n"
		data += "}\n\n"
		prepend_file_data(os.path.join(msvc_dir, "meta", "install.js"), data)

def create_offline():
	subprocess.run([
		os.path.join(qtifwdir, "binarycreator"),
		"-f",
		"-c",
		os.path.join(cfgdir, "config.xml"),
		"-p",
		pkgdir,
		os.path.join(outdir, target)
	], check=True)

def create_online():
	subprocess.run([
		os.path.join(qtifwdir, "binarycreator"),
		"-n",
		"-c",
		os.path.join(cfgdir, "config.xml"),
		"-p",
		pkgdir,
		os.path.join(outdir, target)
	], check=True)

def create_repo():
	subprocess.run([
		os.path.join(qtifwdir, "repogen"),
		"-p",
		pkgdir,
		os.path.join(outdir, "repository", platform + "_" + arch)
	], check=True)

# prepare & copy files
config_arch()
# generate installer
if mode == "offline":
	create_offline()
elif mode == "online":
	create_online()
elif mode == "repository":
	create_repo()
elif mode == "online_all":
	create_repo()
	create_online()
else:
	raise Exception("Invalid mode specified: " + mode)
