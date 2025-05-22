#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>



int main(int argc, char *argv[])
{
    qputenv("QML_XHR_ALLOW_FILE_READ", QByteArray("1"));
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;




    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;
    return app.exec();
}
