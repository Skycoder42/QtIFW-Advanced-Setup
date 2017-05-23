#!/bin/sh
# $1 Qt bin dir
# $2 Qt lib dir
# $3 Qt plugin dir
# $4 Qt translations dir
# $5 pro-dir

bin=$1
lib=$2
plugin=$3
translation=$4
pro=$5

rm -rf deployment
set -e

mkdir deployment
cd deployment
cp ../SeasonProxer ./
cp $pro/Desktop/main.png ./

mkdir lib
cd lib
cp -P $lib/libicudata.so* ./
cp -P $lib/libicui18n.so* ./
cp -P $lib/libicuuc.so* ./
cp -P $lib/libQt5Core.so* ./
cp -P $lib/libQt5DBus.so* ./
cp -P $lib/libQt5XcbQpa.so* ./
cp -P $lib/libQt5Gui.so* ./
cp -P $lib/libQt5Svg.so* ./
cp -P $lib/libQt5Widgets.so* ./
cp -P $lib/libQt5Network.so* ./
cp -P $lib/libQt5WebSockets.so* ./
cp -P $lib/libQt5Sql.so* ./
cp -P $lib/libQt5JsonSerializer.so* ./
cp -P $lib/libQt5RestClient.so* ./
cp -P $lib/libQt5DataSync.so* ./
cp -P $lib/libQt5AutoUpdaterCore.so* ./
cp -P $lib/libQt5AutoUpdaterGui.so* ./
cd ..

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


