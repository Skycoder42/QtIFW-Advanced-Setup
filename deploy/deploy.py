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
depfiles = sys.argv[6:]

addts = True

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


def run_deptool(dependency):
	preparams = []
	postparams = []
	postcmds = []
	if platform == "linux":
		preparams = [os.path.join(bindir, "linuxdeployqt")]
		postparams = []
		if not addts:
			postparams.append("-no-translations")
		nop = lambda *a, **k: None
		postcmds = [
			lambda: rmsilent(os.path.join(deppath, "AppRun")),
			lambda: shutil.copytree(os.path.join(plugindir, "platformthemes"), os.path.join(deppath, "plugins", "platformthemes"))
				if not os.path.isdir(os.path.join(deppath, "plugins", "platformthemes"))
				else nop(),
			lambda: shutil.copytree(os.path.join(plugindir, "xcbglintegrations"), os.path.join(deppath, "plugins", "xcbglintegrations"))
				if not os.path.isdir(os.path.join(deppath, "plugins", "xcbglintegrations"))
				else nop()
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
	else:
		raise Exception("Unknown platform type: " + platform)

	subprocess.run(preparams + [os.path.join(deppath, dependency)] + postparams, check=True)
	for cmd in postcmds:
		cmd()


# creates joined qm files by combining them
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


def patch_qtconf():
	if platform == "linux":
		return
	elif platform[0:3] == "win":
		file = open(os.path.join(deppath, "qt.conf"), "w")
		file.write("[Paths]\nPrefix=.\n")
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
patch_qtconf()

if addts and platform == "mac":
	create_mac_ts()
