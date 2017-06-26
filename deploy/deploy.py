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
lcombine = sys.argv[7]
profiles = ""
if len(sys.argv) > 8:
	profiles = sys.argv[8]

addts = (profiles != "")

binname = os.path.join(outdir, os.path.basename(depsrc))

def copyany(src, dst):
	print(src, dst)
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
			["cmd", "/c", "del " + os.path.join(pathbase, "vcredist_x86.exe")],
			["cmd", "/c", "del " + os.path.join(pathbase, "vcredist_x64.exe")]
		]
	elif platform == "mac":
		preparams = [os.path.join(bindir, "macdeployqt")]
		postparams = ["-appstore-compliant"]
	else:
		raise Exception("Unknown platform type: " + platform)

	subprocess.run(preparams + [binname] + postparams, check=True)
	for cmd in postcmds:
		subprocess.run(cmd, check=True)

def create_mac_ts():
	transdir = os.path.join(binname , "Contents", "Resources", "translations")
	os.makedirs(transdir, exist_ok=True)

	trpatterns = [
		"qt_??.qm",
		"qt_??_??.qm"
	]

	combine_args = []
	for pattern in trpatterns:
		for file in glob.glob(os.path.join(translationdir, pattern)):
			allfiles.append(file)

	combine_args = [
		lcombine,
		os.path.join(bindir, "lconvert"),
		translationdir
	] + combine_args
	subprocess.run(combine_args, cwd=transdir, check=True)

def cp_trans():
	transdir = ""
	if platform == "mac":
		transdir = os.path.join(binname , "Contents", "Resources", "translations")
	else:
		transdir = os.path.join(outdir, "translations")

	data = profiles.split(" ")
	for prof in data:
		subprocess.run([
			os.path.join(bindir, "lrelease"),
			"-compress",
			"-nounfinished",
			prof
		], check=True)
		for root, dirs, files in os.walk(os.path.dirname(prof)):
			for f in files:
				if os.path.splitext(f)[1] == ".qm":
					dfile = os.path.join(transdir, f)
					ofile = os.path.join(root, f)
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
