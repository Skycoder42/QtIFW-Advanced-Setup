#!/usr/bin/env python3

import sys
import errno
import os
import shutil
import glob
import subprocess
import re
from distutils.dir_util import copy_tree
from enum import Enum

# arguments
platform = sys.argv[1]
bindir = sys.argv[2]
plugindir = sys.argv[3]
translationdir = sys.argv[4]
deppath = sys.argv[5]
try:
	tsindex = sys.argv.index("==")
	depfiles = sys.argv[6:tsindex]
	qmfiles = sys.argv[tsindex+1:]
	addts = False
except ValueError:
	depfiles = sys.argv[6:]
	qmfiles = []
	addts = True
print(depfiles, qmfiles)

transdir = ""
if platform == "mac":
	transdir = os.path.join(deppath, depfiles[0], "Contents", "Resources", "translations")
else:
	transdir = os.path.join(deppath, "translations")


def rmsilent(path):
	if os.path.exists(path):
		os.remove(path)


def rmtsilent(path):
	if os.path.exists(path):
		shutil.rmtree(path)


def cpplugins(plg_type):
	if not os.path.isdir(os.path.join(deppath, "plugins", plg_type)):
		shutil.copytree(os.path.join(plugindir, plg_type), os.path.join(deppath, "plugins", plg_type))


def run_deptool(dependency):
	preparams = []
	postparams = []
	postcmds = []
	if platform == "linux":
		preparams = [os.path.join(bindir, "linuxdeployqt")]
		postparams = []
		if not addts:
			postparams.append("-no-translations")
			
		postcmds = [
			lambda: rmsilent(os.path.join(deppath, "AppRun")),
			lambda: cpplugins("platformthemes"),
			lambda: cpplugins("xcbglintegrations")
		]
	elif platform[0:3] == "win":
		preparams = [os.path.join(bindir, "windeployqt.exe")]
		if platform == "win_debug":
			preparams.append("-debug")
		elif platform == "win_release":
			preparams.append("-release")
		else:
			raise Exception("Unknown platform type: " + platform)

		if not addts:
			preparams.append("-no-translations")
		postcmds = [
			lambda: rmsilent(os.path.join(deppath, "vcredist_x86.exe")),
			lambda: rmsilent(os.path.join(deppath, "vcredist_x64.exe")),
			lambda: rmsilent(os.path.join(deppath, "vc_redist.x86.exe")),
			lambda: rmsilent(os.path.join(deppath, "vc_redist.x64.exe"))
		]
	elif platform == "mac":
		preparams = [os.path.join(bindir, "macdeployqt")]
		postparams = []
	else:
		raise Exception("Unknown platform type: " + platform)

	subprocess.run(preparams + [os.path.join(deppath, dependency)] + postparams, check=True)
	for cmd in postcmds:
		cmd()


def create_qm(qmbase):
	os.makedirs(transdir, exist_ok=True)
	for pattern in ["_??.qm",	"_??_??.qm"]:
		for qmfile in glob.glob(os.path.join(translationdir, qmbase + pattern)):
			shutil.copy2(qmfile, transdir)


def patch_qtconf():
	if platform == "linux":
		return
	elif platform[0:3] == "win":
		file = open(os.path.join(deppath, "qt.conf"), "w")
		file.write("[Paths]\n")
		file.write("Prefix=.\n")
		file.write("Plugins=.\n")
		file.write("Libraries=.\n")
		file.close()
	elif platform == "mac":
		file = open(os.path.join(deppath, depfiles[0], "Contents", "Resources", "qt.conf"), "a")
		file.write("Translations=Resources/translations\n")
		file.close()
	else:
		raise Exception("Unknown platform type: " + platform)


# run the deployment tools
for dep in depfiles:
	run_deptool(dep)
for qmbase in qmfiles:
	create_qm(qmbase)
patch_qtconf()

