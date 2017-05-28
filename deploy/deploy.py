#!/usr/bin/env python3

import sys
import os
import shutil
import glob
import subprocess
import re
from distutils.dir_util import copy_tree
from enum import Enum

# constants
platform = sys.argv[1]
bindir = sys.argv[2]
plugindir = sys.argv[3]
translationdir = sys.argv[4]
depsrc = sys.argv[5]
outdir = sys.argv[6]
profiles = ""
if len(sys.argv) > 7:
	profiles = sys.argv[7]

binname = os.path.join(outdir, os.path.basename(depsrc))

def copyany(src, dst):
	try:
		shutil.copytree(src, dst)
	except OSError as e:
		if e.errno == errno.ENOTDIR:
			shutil.copy2(src, dst)
		else:
			raise

def run_deptool():
	preparams = []
	postparams = []
	postcmds = []
	if platform == "linux":
		preparams = [os.path.join(bindir, "linuxdeployqt")]
		postcmds = [
			["rm", os.path.join(outdir, "AppRun")],
			["cp", "-rPn", os.path.join(plugindir, "platforminputcontexts"), os.path.join(outdir, "plugins/")],
			["cp", "-rPn", os.path.join(plugindir, "platformthemes"), os.path.join(outdir, "plugins/")],
			["cp", "-rPn", os.path.join(plugindir, "xcbglintegrations"), os.path.join(outdir, "plugins/")]
		]
	elif platform == "win_debug":
		preparams = [os.path.join(bindir, "windeployqt.exe"), "-debug", "-no-translations"]
		postcmds = [
			["cmd", "-c", "del", os.path.join(outdir, "vcredist_x86.exe")],
			["cmd", "-c", "del", os.path.join(outdir, "vcredist_x64.exe")]
		]
	elif platform == "win_release":
		preparams = [os.path.join(bindir, "windeployqt.exe"), "-release", "-no-translations"]
		pathbase = os.path.sep.join(outdir.split("/"))
		postcmds = [
			["cmd", "/c", "del " + os.path.join(pathbase, "vcredist_x86.exe")],
			["cmd", "/c", "del " + os.path.join(pathbase, "vcredist_x64.exe")]
		]
	elif platform == "mac":
		preparams = [os.path.join(bindir, "macdeployqt")]
		postparams = ["-appstore-compliant"]
	else:
		raise Exception("Unknown platform type: " + platform)

	subprocess.run(preparams + [binname] + postparams)
	for cmd in postcmds:
		subprocess.run(cmd)

def cp_translations():
	transdir = ""
	if platform == "mac":
		transdir = os.path.join(binname , "Contents", "Resources", "translations")
	else:
		transdir = os.path.join(outdir, "translations")
	os.makedirs(transdir, exist_ok=True)

	trpatterns = [ #TODO complete list
		"qt_??.qm",
		"qt_??_??.qm",
		"qtbase_*.qm",
		"qtconnectivity_*.qm",
		"qtdeclarative_*.qm",
		"qtlocation_*.qm",
		"qtmultimedia_*.qm",
		"qtquick1_*.qm",
		"qtquickcontrols_*.qm",
		"qtscript_*.qm",
		"qtserialport_*.qm",
		"qtwebengine_*.qm",
		"qtwebsockets_*.qm",
		"qtxmlpatterns_*.qm"
	]

	for pattern in trpatterns:
		for file in glob.glob(os.path.join(translationdir, pattern)):
			dfile = os.path.join(transdir, os.path.basename(file))
			shutil.copy2(file, dfile)

	data = profiles.split(" ")
	for prof in data:
		subprocess.run([
			os.path.join(bindir, "lrelease"),
			"-compress",
			"-nounfinished",
			prof
		])
		for root, dirs, files in os.walk(os.path.dirname(prof)):
			for f in files:
				if os.path.splitext(f)[1] == ".qm":
					dfile = os.path.join(transdir, f)
					ofile = os.path.join(root, f)
					shutil.copy2(ofile, dfile)

def patch_qtconf(translationsPresent):
	if platform == "linux":
		return
	elif platform == "win_debug" or platform == "win_release":
		file = open(os.path.join(outdir, "qt.conf"), "w")
		file.write("[Paths]\nPrefix=.")
		file.close()
	elif platform == "mac":
		file = open(os.path.join(binname , "Contents", "Resources", "qt.conf"), "a")
		file.write("Translations=Resources/translations\n")
		file.close()
	else:
		raise Exception("Unknown platform type: " + platform)

# prepare & copy files
shutil.rmtree(outdir, ignore_errors=True)
os.makedirs(outdir, exist_ok=True)
copyany(depsrc, binname)

# run the deployment tools
run_deptool()
if profiles != "":
	cp_translations()
	patch_qtconf(True)
else:
	patch_qtconf(False)
