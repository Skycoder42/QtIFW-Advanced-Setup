#!/bin/sh
# $1 Qt bin dir
# $2 Qt translations dir
# $3 pro-dir

bin=$1
translation=$2
pro=$3

rm -rf deployment
set -e

mkdir deployment
cd deployment
cp -r ../SeasonProxer.app ./

$bin/macdeployqt SeasonProxer.app -appstore-compliant

$bin/lrelease -compress -nounfinished $pro/Core/Core.pro
$bin/lrelease -compress -nounfinished $pro/Desktop/Desktop.pro

mkdir SeasonProxer.app/Contents/Resources/translations
cd SeasonProxer.app/Contents/Resources/translations
cp $translation/qtbase_*.qm ./
cp $translation/qtwebsockets_*.qm ./
cp $pro/Core/*.qm ./
cp $pro/Desktop/*.qm ./

cd ..
echo "Translations=Resources/translations" >> qt.conf
cd ../../..



