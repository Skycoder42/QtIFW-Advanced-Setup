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

# constants
platform = sys.argv[1]
bindir = sys.argv[2]
plugindir = sys.argv[3]
translationdir = sys.argv[4]
depsrc = sys.argv[5]
outdir = sys.argv[6]
outpwd = sys.argv[7]
lcombine = sys.argv[8]
tsfiles = sys.argv[9:]

addts = (tsfiles != "")
binname = os.path.join(outdir, os.path.basename(depsrc))
transdir = ""
if platform == "mac":
	transdir = os.path.join(binname , "Contents", "Resources", "translations")
else:
	transdir = os.path.join(outdir, "translations")

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
		postparams = []
		if not addts:
			postparams.append("-no-translations")
		postcmds = [
			["rm", os.path.join(outdir, "AppRun")],
			["cp", "-rPn", os.path.join(plugindir, "platforminputcontexts"), os.path.join(outdir, "plugins/")],
			["cp", "-rPn", os.path.join(plugindir, "platformthemes"), os.path.join(outdir, "plugins/")],
			["cp", "-rPn", os.path.join(plugindir, "xcbglintegrations"), os.path.join(outdir, "plugins/")]
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
		pathbase = os.path.sep.join(outdir.split("/"))
		postcmds = [
			["cmd", "/c", "del " + os.path.join(pathbase, "vcredist_x86.exe") + " > nul 2> nul"],
			["cmd", "/c", "del " + os.path.join(pathbase, "vcredist_x64.exe") + " > nul 2> nul"]
		]
	elif platform == "mac":
		preparams = [os.path.join(bindir, "macdeployqt")]
		postparams = []
	else:
		raise Exception("Unknown platform type: " + platform)

	subprocess.run(preparams + [binname] + postparams, check=True)
	for cmd in postcmds:
		subprocess.run(cmd, check=True)

def create_mac_ts():
	os.makedirs(transdir, exist_ok=True)
	trpatterns = [
		"qt_??.qm",
		"qt_??_??.qm"
	]

	combine_args = []
	for pattern in trpatterns:
		for file in glob.glob(os.path.join(translationdir, pattern)):
			combine_args.append(file)

	combine_args = [
		"/usr/local/bin/python3",
		lcombine,
		os.path.join(bindir, "lconvert"),
		translationdir
	] + combine_args
	subprocess.run(combine_args, cwd=transdir, check=True)

def cp_trans():
	for tsfile in tsfiles:
		fname = os.path.splitext(os.path.split(tsfile)[1])[0] + ".qm"
		dfile = os.path.join(transdir, fname)
		ofile = os.path.join(outpwd, fname)
		shutil.copy2(ofile, dfile)

def patch_qtconf(translationsPresent):
	if platform == "linux":
		return
	elif platform[0:3] == "win":
		file = open(os.path.join(outdir, "qt.conf"), "w")
		file.write("[Paths]\nPrefix=.\n")
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
if addts:
	if platform == "mac":
		create_mac_ts()
	cp_trans()
	patch_qtconf(True)
else:
	patch_qtconf(False)
