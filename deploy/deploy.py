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
if platform[0:3] == "mac":
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
			[True, "rm", os.path.join(outdir, "AppRun")],
			[False, "cp", "-rPnT", os.path.join(plugindir, "platforminputcontexts"), os.path.join(outdir, "plugins", "platforminputcontexts")],
			[False, "cp", "-rPnT", os.path.join(plugindir, "platformthemes"), os.path.join(outdir, "plugins", "platformthemes")],
			[False, "cp", "-rPnT", os.path.join(plugindir, "xcbglintegrations"), os.path.join(outdir, "plugins", "xcbglintegrations")]
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
			[True, "cmd", "/c", "del " + os.path.join(pathbase, "vcredist_x86.exe") + " > nul 2> nul"],
			[True, "cmd", "/c", "del " + os.path.join(pathbase, "vcredist_x64.exe") + " > nul 2> nul"]
		]
	elif platform == "mac":
		preparams = [os.path.join(bindir, "macdeployqt")]
		postparams = []
	elif platform == "mac_no_bundle":
		global binname
		basename = os.path.splitext(os.path.basename(depsrc))[0]

		bundledir = os.path.join(outdir, basename + ".app", "Contents", "MacOS")
		os.makedirs(bundledir)
		shutil.move(binname, os.path.join(bundledir, basename))
		binname = binname + ".app"

		preparams = [os.path.join(bindir, "macdeployqt")]
		postparams = []
		postcmds = [
			[True, "rm", "-rf", os.path.join(binname, "Contents", "Frameworks", "QtGui.framework")],
			[True, "rm", "-rf", os.path.join(binname, "Contents", "Frameworks", "QtWidgets.framework")],
			[True, "rm", "-rf", os.path.join(binname, "Contents", "Frameworks", "QtPrintSupport.framework")],
			[True, "rm", "-rf", os.path.join(binname, "Contents", "Frameworks", "QtSvg.framework")],
			[True, "rm", "-rf", os.path.join(binname, "Contents", "PlugIns", "iconengines")],
			[True, "rm", "-rf", os.path.join(binname, "Contents", "PlugIns", "imageformats")],
			[True, "rm", "-rf", os.path.join(binname, "Contents", "PlugIns", "platforms")],
			[True, "rm", "-rf", os.path.join(binname, "Contents", "PlugIns", "printsupport")],
			[True, "rm", "-rf", os.path.join(binname, "Contents", "Resources", "empty.lproj")],
			[True, "rm", "-rf", os.path.join(binname, "Contents", "Info.plist")],
			[True, "rm", "-rf", os.path.join(binname, "Contents", "PkgInfo")],
			[True, "ln", "-s" , os.path.join("MacOS", basename), os.path.join(binname, "Contents", basename)]
		]
	else:
		raise Exception("Unknown platform type: " + platform)

	subprocess.run(preparams + [binname] + postparams, check=True)
	for cmd in postcmds:
		subprocess.run(cmd[1:], check=cmd[0])

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
	elif platform[0:3] == "mac":
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
	if platform[0:3] == "mac":
		create_mac_ts()
	cp_trans()
	patch_qtconf(True)
else:
	patch_qtconf(False)

if platform == "mac_no_bundle":
	# no bundle -> renamings
	bkpName = outdir + ".bkp"
	oldName = os.path.join(bkpName, os.path.basename(depsrc), "Contents")
	shutil.move(outdir, bkpName)
	shutil.move(oldName, outdir)
	shutil.rmtree(bkpName)
