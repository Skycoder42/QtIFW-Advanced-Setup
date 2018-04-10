#!/bin/sh
lrelease -compress -nounfinished ./*.ts
mv *.qm ../packages/de.skycoder42.advancedsetup/meta/
