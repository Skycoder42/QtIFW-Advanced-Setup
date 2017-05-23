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

rm -rf $outpwd
set -e

mkdir $outpwd
cd $outpwd
cp $deploy ./

mkdir lib
cd lib
for l in $(ldd $binary | grep -oh "libQt[^\.]*" | uniq); do
	cp -P $lib/$l.so* ./
done

exit 0

mkdir plugins
cd plugins

mkdir platforms
cp $plugin/platforms/libqxcb.so ./platforms/

cp -r $plugin/bearer ./
cp -r $plugin/imageformats ./
cp -r $plugin/iconengines ./
cp -r $plugin/platforminputcontexts ./
cp -r $plugin/platformthemes ./
cp -r $plugin/xcbglintegrations ./

mkdir sqldrivers
cp $plugin/sqldrivers/libqsqlite.so ./sqldrivers/

cd ..

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


