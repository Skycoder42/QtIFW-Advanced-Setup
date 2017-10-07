#!/bin/sh

echo this script will install linuxdeployqt into your Qt installation directory. It is required to get linuxdeployqt working with qtifw-advanced-setup
read unused

echo please enter the path to qmake to be used [$(which qmake)]:
read rqmake
if [ -z "$rqmake" ]; then
	rqmake="qmake"
fi

qt_bins=$("$rqmake" -query QT_INSTALL_BINS)

cd $(mktemp -d)
git clone https://github.com/probonopd/linuxdeployqt.git -b continuous
cd linuxdeployqt

"$rqmake"
make qmake_all
make
$1 make install

if [ $? == 0 ]; then
	echo
	echo
	echo install successfull!
else
	echo
	echo
	echo install failed, propably because of missing permissions. Try to call the script with sudo as first parameter:  \"$(basename $0) sudo\"
fi
