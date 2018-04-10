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
srcdir = sys.argv[1]
outdir = sys.argv[2]
bindir = sys.argv[3]
qtifwdir = sys.argv[4]
target = sys.argv[5]
mode = sys.argv[6]
platform = sys.argv[7]
arch = sys.argv[8]
inputs = sys.argv[9:]
cfgdir = os.path.join(outdir, "config")
pkgdir = os.path.join(outdir, "packages")

subTDir = ""

# definitions
class State(Enum):
	Config = 0
	Package = 1,
	Meta = 2,
	DataDir = 3,
	DataFile = 4,
	SubDir = 5

def copy_cfg(src):
	cfgsrc = os.path.join(srcdir, src)
	cfgout = os.path.join(cfgdir, os.path.basename(src))
	shutil.copy2(cfgsrc, cfgout)

def copy_pkg(pkg, state, src, subdir, isDir):
	pkgsrc = os.path.join(srcdir, src)
	pkgout = os.path.join(pkgdir, pkg, subdir, subTDir)
	os.makedirs(pkgout, exist_ok=True)
	if isDir:
		copy_tree(pkgsrc, pkgout, preserve_symlinks=True)
	else:
		resName = os.path.join(pkgout, os.path.basename(src))
		shutil.copy2(pkgsrc, resName)

def prepend_file_data(filename, data):
	with open(filename, "r+") as file:
		orig = file.read()
		file.seek(0)
		file.write(data)
		file.write(orig)

def create_install_dir():
	global subTDir
	state = State.Config
	pkg = ""
	for arg in inputs:
		if arg == "p":
			state = State.Package
		elif arg == "m":
			state = State.Meta
		elif arg == "d":
			state = State.DataDir
		elif arg == "f":
			state = State.DataFile
		elif arg == "t":
			state = State.SubDir
		else:
			if state == State.Config:
				copy_cfg(arg)
			elif state == State.Package:
				subTDir = ""
				pkg = arg
			elif state == State.Meta:
				copy_pkg(pkg, state, arg, "meta", True)
				state = State.Package
			elif state == State.DataDir:
				copy_pkg(pkg, state, arg, "data", True)
				state = State.Package
			elif state == State.DataFile:
				copy_pkg(pkg, state, arg, "data", False)
				state = State.Package
			elif state == State.SubDir:
				subTDir = arg
				state = State.Package
			else:
				raise Exception("Invalid state: " + state.name)

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

def add_translations():
	pattern_base = os.path.join(os.path.dirname(__file__), "translations")

	args = glob.glob(os.path.join(pattern_base, "*.ts"))
	args = [
		os.path.join(bindir, "lrelease"),
		"-nounfinished"
	] + args

	subprocess.run(args, check=True)

	metadir = os.path.join(pkgdir, "de.skycoder42.advancedsetup", "meta")
	for file in glob.glob(os.path.join(pattern_base, "*.qm")):
		dfile = os.path.join(metadir, os.path.basename(file))
		shutil.move(file, dfile)

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
shutil.rmtree(outdir, ignore_errors=True)
os.makedirs(cfgdir, exist_ok=True)
create_install_dir()
config_arch()
add_translations()

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
