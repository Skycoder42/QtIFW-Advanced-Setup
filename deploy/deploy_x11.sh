#!/bin/sh
# $1 Qt bin dir
# $2 Qt lib dir
# $3 Qt plugin dir
# $4 Qt translations dir
# $5 deploy file
# $6 deploy dir

bin=$1
lib=$2
plugin=$3
translation=$4
deploy=$5
outpwd=$6

binary=$outpwd/$(basename $deploy)

function copylib { #(libpath)
	cp -Pn "$1"* "$outpwd/lib/"
}

function copyplgdir { #(pluginDirectory)
	cp -rPn $plugin/$1 plugins/
	scanallfiles plugins/$1
}

function copyplugins { #(libname)
	if [ "$1" == libQt5Gui ] && [ ! -f mrk/libQt5Gui ]; then
		touch mrk/libQt5Gui

		mkdir -p plugins/platforms
		cp -Pn "$plugin/platforms/libqxcb.so" plugins/platforms/
		scanfile "plugins/platforms/libqxcb.so"

		copyplgdir imageformats
		copyplgdir iconengines
		copyplgdir platforminputcontexts
		copyplgdir platformthemes
		copyplgdir xcbglintegrations
	fi
	if [ "$1" == libQt5Sql ] && [ ! -f mrk/libQt5Sql ]; then
		touch mrk/libQt5Sql
		copyplgdir sqldrivers
	fi
}

function scanfile { #(binary)
	for l in $(ldd "$1" | grep -oh "libQt[^\.]*" | uniq); do
		file="$lib/$l.so"
		copylib $file
		copyplugins $l
		scanfile $file
	done
	for l in $(ldd "$1" | grep -oh "libicu[^\.]*" | uniq); do
		file="$lib/$l.so"
		copylib $file
	done
}

function scanallfiles { #(directory to scan)
	for entry in $1/*; do
		scanfile $entry
	done
}

rm -rf $outpwd
set -e

mkdir $outpwd
cd $outpwd
cp $deploy ./

mkdir lib
mkdir plugins
mkdir mrk

scanfile $binary

rm -rf mrk

exit 0

$bin/lrelease -compress -nounfinished $pro/Core/Core.pro
$bin/lrelease -compress -nounfinished $pro/Desktop/Desktop.pro

mkdir translations
cd translations
cp $translation/qtbase_*.qm ./
cp $translation/qtwebsockets_*.qm ./
cp $pro/Core/*.qm ./
cp $pro/Desktop/*.qm ./
cd ..

echo "[Paths]" > qt.conf
echo "Prefix=." >> qt.conf

chrpath -r "\$ORIGIN/lib" SeasonProxer


