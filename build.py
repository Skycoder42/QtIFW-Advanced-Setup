#!/usr/bin/env python3

import sys
import os
import shutil
from distutils.dir_util import copy_tree
from enum import Enum

class State(Enum):
	Config = 0
	Package = 1,
	Meta = 2,
	Data = 3

srcdir = sys.argv[1]
outdir = sys.argv[2]
cfgdir = os.path.join(outdir, "config")
pkgdir = os.path.join(outdir, "packages")

def copy_cfg(src):
	cfgsrc = os.path.join(srcdir, src)
	cfgout = os.path.join(cfgdir, os.path.basename(src))
	shutil.copy2(cfgsrc, cfgout)

def copy_pkg(pkg, state, src):
	pkgsrc = os.path.join(srcdir, src)
	pkgout = os.path.join(pkgdir, pkg, state.name.lower())
	os.makedirs(pkgout, exist_ok=True)
	copy_tree(pkgsrc, pkgout, preserve_symlinks=True)

# prepare
shutil.rmtree(outdir, ignore_errors=True)
os.makedirs(cfgdir, exist_ok=True)

# parse args
state = State.Config
pkg = ""
for arg in sys.argv[3:]:
	if arg == "p":
		state = State.Package
	elif arg == "m":
		state = State.Meta
	elif arg == "d":
		state = State.Data
	else:
		if state == State.Config:
			copy_cfg(arg)
		elif state == State.Package:
			pkg = arg
		else:
			copy_pkg(pkg, state, arg)
			state = State.Package
