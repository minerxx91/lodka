import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:path_provider/path_provider.dart';

class WiFi{

  int sent=0;

  Future<void> getWiFiData() async {
    while (true) {
      Uri url = Uri.http("192.168.4.1","/");
      http.Response response = await http.get(url);
      String message = response.body;
      print('Received message: $message');
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> sendWiFiData(String joyX, String joyY) async {
    Uri url = Uri.http("192.168.4.1","/data");
    var headers = {"Content-type": "application/x-www-form-urlencoded"};
    var body = {"joyX":joyX, "joyY":joyY};
    http.Response response = await http.post(url, headers: headers, body: body);
    String message = response.body;
    print('Received message: $message');
    sent = DateTime.now().millisecondsSinceEpoch;
  }

  Future<List<String>> getDepth() async {
    Uri url = Uri.http("192.168.4.1","/depth");
    http.Response response = await http.get(url);
    String message = response.body;
    print('Received message: $message');
    List<String> splitted = message.split(";");
    return splitted;
  }

  Future<void> uploadFile() async {
    String order;
    var longString = await rootBundle.loadString("lib/data.json");
    Uri url = Uri.http("192.168.4.1","/json");
    var headers = {"Content-type": "application/x-www-form-urlencoded"};
    var chunkSize = 500;
    var chunks = <String>[];
    for (var i = 0; i < longString.length; i += chunkSize) {
      order = "mid";
      var end = i + chunkSize;
      if (end > longString.length) {
        end = longString.length;
        order = "last";
      }
      if (end == chunkSize) {
        order = "first";
      }
      var chunk = longString.substring(i, end);
      chunks.add(chunk);
      var body = {"order": order,"content": chunks.last};
      http.Response response = await http.post(url, headers: headers, body: body);
    }
  }

  Future<void> downloadFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data.json');
    await file.delete();
    int part = 0;
    while (true) {
      Uri url = Uri.http("192.168.4.1", "/downloadJson", {'part': part.toString()});
      http.Response response = await http.get(url);
      String content = response.body;
      if (content == "") {
        break;
      }
      part++;
      await Future.delayed(const Duration(seconds: 1));

    const fileMode = FileMode.write;
    final sink = file.openWrite(mode: fileMode);

    sink.write(content);

    await sink.close();
    }

    /*if (await file.exists()) {
      final lines = await file.readAsLines();
      for (var line in lines) {
        print(line);
      }
    } else {
      print('File not found');
    }*/
  }

  Future<void> downloadOpenStreetMapTile(int zoom, int x, int y) async {
    final directory = await getApplicationDocumentsDirectory();
    String url = "https://tile.openstreetmap.org/$zoom/$x/$y.png";

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Uint8List bytes = response.bodyBytes;
      File file = File('${directory.path}/heatMap/$zoom/$x/$y.png');
      if (await file.exists()) {
        await file.writeAsBytes(bytes);
        print('Tile downloaded: ${file.path}');
        return;
      }
      await Directory('${directory.path}/heatMap/$zoom/$x/$y.png').create(recursive: true);
    } else {
      print('Failed to download tile: ${response.statusCode}');
    }
  }

  Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.sk');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      } on SocketException catch (_) {
        return false;
    }
    return false;
  }

bool isInternetConnected() {
  try {
    Socket.connect('google.sk', 80);
  } catch (e) {
    print(e);
    return false; // No internet connection
  }
  return true; // Internet connection is available
}
}