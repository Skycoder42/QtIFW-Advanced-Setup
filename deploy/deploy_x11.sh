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

function copyplgdir { #(pluginDirectory)
	cp -rPn $plugin/$1 plugins/
}

#rm -rf $outpwd
set -e

mkdir -p $outpwd
cd $outpwd
cp $deploy ./

LD_LIBRARY_PATH="$lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH
PATH="$bin:$PATH"
export PATH
linuxdeployqt $binary
rm AppRun

if [ -f plugins/platforms/libqxcb.so ]; then
	copyplgdir platforminputcontexts
	copyplgdir platformthemes
	copyplgdir xcbglintegrations
fi

echo "[Paths]" > qt.conf
echo "Prefix=." >> qt.conf

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


