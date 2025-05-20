#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

QVariantList loadChart()
{
    QFile file(":/notes.json");
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning("Couldn't open chart.json");
        return {};
    }

    QByteArray data = file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);

    QVariantList result;

    if (doc.isObject()) {
        QJsonObject root = doc.object();
        QJsonArray notes = root["notes"].toArray();
        for (const auto &val : notes) {
            result.append(val.toObject().toVariantMap());
        }
    }

    return result;
}

int main(int argc, char *argv[])
{
    qputenv("QML_XHR_ALLOW_FILE_READ", QByteArray("1"));
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    QVariantList chartData = loadChart();
    engine.rootContext()->setContextProperty("chartData", chartData);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;
    return app.exec();
}
