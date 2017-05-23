#!/bin/sh
# $1 Qt plugin dir
# $2 Qt translations dir
# $3 deploy file
# $4 deploy dir
# $5 translation pro files

plugin=$1
translation=$2
deploy=$3
outpwd=$4
trfiles=$5

binary=$outpwd/$(basename $deploy)

function copyplgdir { #(pluginDirectory)
	cp -rPn $plugin/$1 plugins/
}

#rm -rf $outpwd
set -e

mkdir -p $outpwd
cd $outpwd
cp $deploy ./

linuxdeployqt "$binary"
rm AppRun

if [ -f plugins/platforms/libqxcb.so ]; then
	copyplgdir platforminputcontexts
	copyplgdir platformthemes
	copyplgdir xcbglintegrations
fi

echo "[Paths]" > qt.conf
echo "Prefix=." >> qt.conf

if [ ! -z "$trfiles" ]; then
	mkdir -p translations
	cp -Pn $translation/*.qm translations/

	#TODO here
fi

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


