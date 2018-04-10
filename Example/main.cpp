#include <QApplication>
#include <QMessageBox>

int main(int argc, char **argv)
{
	QApplication a(argc, argv);
	return QMessageBox::information(nullptr,
									QCoreApplication::translate("GLOBAL", "Example"),
									QCoreApplication::translate("GLOBAL", "Hello World!"));
}
