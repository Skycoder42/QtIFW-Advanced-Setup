#!/bin/sh
# $1 Qt bin dir
# $2 Qt plugin dir
# $3 Qt translations dir
# $4 deploy file
# $5 deploy dir
# $6 translation pro files

bin=$1
plugin=$2
translation=$3
deploy=$4
outpwd=$5
profiles=$6

binary=$outpwd/$(basename $deploy)

function copyplgdir { #(pluginDirectory)
	cp -rPn $plugin/$1 plugins/
}

#rm -rf $outpwd
set -e

mkdir -p $outpwd
cd $outpwd
cp $deploy ./

$bin/linuxdeployqt "$binary"
rm AppRun

if [ -f plugins/platforms/libqxcb.so ]; then
	copyplgdir platforminputcontexts
	copyplgdir platformthemes
	copyplgdir xcbglintegrations
fi

#echo "[Paths]" > qt.conf
#echo "Prefix=." >> qt.conf

if [ ! -z "$profiles" ]; then
	mkdir -p translations
	cp -Pn "$translation"/qt_??.qm translations/
	cp -Pn "$translation"/qt_??_??.qm translations/
	cp -Pn "$translation"/qtbase_*.qm translations/
	cp -Pn "$translation"/qtconnectivity_*.qm translations/
	cp -Pn "$translation"/qtdeclarative_*.qm translations/
	cp -Pn "$translation"/qtlocation_*.qm translations/
	cp -Pn "$translation"/qtmultimedia_*.qm translations/
	cp -Pn "$translation"/qtquick1_*.qm translations/
	cp -Pn "$translation"/qtquickcontrols_*.qm translations/
	cp -Pn "$translation"/qtscript_*.qm translations/
	cp -Pn "$translation"/qtserialport_*.qm translations/
	cp -Pn "$translation"/qtwebengine_*.qm translations/
	cp -Pn "$translation"/qtwebsockets_*.qm translations/
	cp -Pn "$translation"/qtxmlpatterns_*.qm translations/
fi

for profile in $profiles; do
	$bin/lrelease -compress -nounfinished $profile
	find "$(dirname $profile)" -type f -name "*.qm" -exec cp -Pn {} translations \;
done

