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
tsfiles = sys.argv[8:]

addts = (tsfiles != "")
binname = os.path.join(outdir, os.path.basename(depsrc))
transdir = ""
if platform == "mac":
	transdir = os.path.join(binname , "Contents", "Resources", "translations")
elif platform == "mac_no_bundle":
	transdir = os.path.join(binname + ".app", "Contents", "Resources", "translations")
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

def rmsilent(path):
	if os.path.exists(path):
		os.remove(path)

def rmtsilent(path):
	if os.path.exists(path):
		shutil.rmtree(path)

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
			lambda: rmsilent(os.path.join(outdir, "AppRun")),
			lambda: copyany(os.path.join(plugindir, "platforminputcontexts"), os.path.join(outdir, "plugins", "platforminputcontexts")),
			lambda: copyany(os.path.join(plugindir, "platformthemes"), os.path.join(outdir, "plugins", "platformthemes")),
			lambda: copyany(os.path.join(plugindir, "xcbglintegrations"), os.path.join(outdir, "plugins", "xcbglintegrations"))
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
			lambda: rmsilent(os.path.join(pathbase, "vcredist_x86.exe")),
			lambda: rmsilent(os.path.join(pathbase, "vcredist_x64.exe")),
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
			lambda: rmtsilent(os.path.join(binname, "Contents", "Frameworks", "QtGui.framework")),
			lambda: rmtsilent(os.path.join(binname, "Contents", "Frameworks", "QtWidgets.framework")),
			lambda: rmtsilent(os.path.join(binname, "Contents", "Frameworks", "QtPrintSupport.framework")),
			lambda: rmtsilent(os.path.join(binname, "Contents", "Frameworks", "QtSvg.framework")),
			lambda: rmtsilent(os.path.join(binname, "Contents", "PlugIns", "iconengines")),
			lambda: rmtsilent(os.path.join(binname, "Contents", "PlugIns", "imageformats")),
			lambda: rmtsilent(os.path.join(binname, "Contents", "PlugIns", "platforms")),
			lambda: rmtsilent(os.path.join(binname, "Contents", "PlugIns", "printsupport")),
			lambda: rmtsilent(os.path.join(binname, "Contents", "PlugIns", "iconengines")),
			lambda: rmsilent(os.path.join(binname, "Contents", "Resources", "empty.lproj")),
			lambda: rmsilent(os.path.join(binname, "Contents", "Info.plist")),
			lambda: rmsilent(os.path.join(binname, "Contents", "PkgInfo")),
			lambda: os.symlink(os.path.join("MacOS", basename), os.path.join(binname, "Contents", basename))
		]
	else:
		raise Exception("Unknown platform type: " + platform)

	subprocess.run(preparams + [binname] + postparams, check=True)
	for cmd in postcmds:
		cmd()

def lcombine(translations):
	tool = os.path.join(bindir, "lconvert")

	filesmap = {}
	namemap = {}

	for ts in translations:
		name = os.path.splitext(ts)[0]
		index = name.rindex("_")
		lang = name[index+1:]
		filesmap[lang] = []
		namemap[lang] = os.path.split(name)[1]

	for root, subdirs, files in os.walk(translationdir, followlinks=True):
		for file in files:
			if file[-3:] == ".qm":
				name = os.path.splitext(file)[0]
				index = name.rindex("_")
				lang = name[index+1:]
				if lang in filesmap:
					filesmap[lang].append(os.path.join(root, file))

	for lang in filesmap:
		command = [
			tool,
			"-i"
		]
		command += filesmap[lang]
		command.append("-o")
		command.append(namemap[lang] + ".qm")

		subprocess.run(command)

def create_mac_ts():
	tool = os.path.join(bindir, "lconvert")
	filesmap = {}
	namemap = {}

	for pattern in ["qt_??.qm",	"qt_??_??.qm"]:
		for ts in glob.glob(os.path.join(translationdir, pattern)):
			name = os.path.splitext(ts)[0]
			index = name.rindex("_")
			lang = name[index+1:]
			filesmap[lang] = []
			namemap[lang] = os.path.split(name)[1]

	for root, subdirs, files in os.walk(translationdir, followlinks=True):
		for file in files:
			if file[-3:] == ".qm":
				name = os.path.splitext(file)[0]
				index = name.rindex("_")
				lang = name[index+1:]
				if lang in filesmap:
					filesmap[lang].append(os.path.join(root, file))

	os.makedirs(transdir, exist_ok=True)
	for lang in filesmap:
		command = [
			tool,
			"-if", "qm",
			"-i"
		]
		command += filesmap[lang]
		command.append("-of")
		command.append("qm")
		command.append("-o")
		command.append(namemap[lang] + ".qm")

		subprocess.run(command)

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
rmtsilent(outdir)
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
	oldName = os.path.join(bkpName, os.path.basename(depsrc) + ".app", "Contents")
	shutil.move(outdir, bkpName)
	shutil.move(oldName, outdir)
	shutil.rmtree(bkpName)
