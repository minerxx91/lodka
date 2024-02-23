import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:lodka/json_handler.dart';
import 'package:lodka/tiles.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/io.dart';

class WiFi{

  static LatLng position = LatLng(0, 0);
  static double depth = 0.0;

  int sent=0;
  var channel = IOWebSocketChannel.connect(
    Uri.parse('ws://192.168.4.1/ws'),
  );

  void closeSocket(){
    channel.sink.close();
  }

  void connectSocket(){
    channel = IOWebSocketChannel.connect(Uri.parse('ws://192.168.4.1/ws'));
  }


  /*void getWiFiData(){
    channel.stream.listen((message) {
      print('Received: $message');
      Map map = json.decode(message);
      if (map.containsKey("lat")) {
        position.latitude = map["lat"];
        position.longitude = map["lng"];
        depth = map["depth"];
      }
    });
  }*/

  void sendWiFiData(String joyJson){
    channel.sink.add(joyJson);
    print(joyJson);
  }

  void listenToWebsocket(){
    channel.stream.listen((message) {
      print('Received message: $message');
      Map map = json.decode(message);
      if (map.containsKey("lat")) {
        position.latitude = map["lat"];
        position.longitude = map["lng"];
        depth = map["depth"];
        for (var i = 15; i < 19; i++) {
          createAndSetPixelColor(map["lat"], map["lng"], i, detphToColor(depth));
        }
        JsonHandler.addDepth(map["lat"], map["lng"], depth);
      }
    });
  }

  void setHome(LatLng home){
    String jsonString = '{"action":"setHome","lat":${home.latitude.toString()}, "lng":${home.longitude.toString()}}';
    channel.sink.add(jsonString);
  }

  void returnHome(){
    String jsonString = '{"action":"returnHome"}';
    channel.sink.add(jsonString);
  }

  void openChamber(String side){
    String jsonString = '{"action":"openChamber","side":$side}';
    channel.sink.add(jsonString);
  }

  void releaseHook(String side){
    String jsonString = '{"action":"releaseHook","side":$side}';
    channel.sink.add(jsonString);
  }

  void autopilot(LatLng point){
    String jsonString = '{"action":"autopilot","lat":${point.latitude}, "lng":${point.longitude}}';
    channel.sink.add(jsonString);
  }

  void calibrate(){
    String jsonString = '{"action":"calibrate"}';
    channel.sink.add(jsonString);
  }

  /*Future<void> setHome(LatLng home) async {
    Uri url = Uri.http("192.168.4.1","/sendData");
    var headers = {"Content-type": "application/json"};
    var body = {"message":{"action":"setHome","lat":home.latitude.toString(), "lng":home.longitude.toString()}};
    http.Response response = await http.post(url, headers: headers, body: body);
    String message = response.body;
    print('Home set at: $message');
  }

  Future<void> returnHome() async {
    Uri url = Uri.http("192.168.4.1", "/sendData");
    var headers = {"Content-type": "text/plain"};
    var body = {{"message":{"action":"returnHome"}}};
    http.Response response = await http.post(url, headers: headers, body: body);
    print(response.statusCode);
    print('Returning home');
  }

  Future<void> openChamber(String side) async {
    Uri url = Uri.http("192.168.4.1","/sendData");
    var headers = {"Content-type": "application/x-www-form-urlencoded"};
    var body = {"message":{"action":"openChamber","side":side}};
    http.Response response = await http.post(url, headers: headers, body: body);
    print('Opening $side chamber');
  }

  Future<void> releaseHook(String side) async {
    Uri url = Uri.http("192.168.4.1","/sendData");
    var headers = {"Content-type": "application/x-www-form-urlencoded"};
    var body = {"message":{"action":"releaseHook","side":side}};
    http.Response response = await http.post(url, headers: headers, body: body);
    print('Releasing $side hook');
  }

  static Future<void> autopilot(LatLng point) async {
    Uri url = Uri.http("192.168.4.1","/sendData");
    var headers = {"Content-type": "application/x-www-form-urlencoded"};
    var body = {"message":{"action":"autopilot","lat":point.latitude, "lng":point.longitude}};
    http.Response response = await http.post(url, headers: headers, body: body);
    print('Navigating to ${point.latitude.toString()}, ${point.longitude.toString()}');
  }

  static Future<void> calibrate() async {
    Uri url = Uri.http("192.168.4.1","/sendData");
    var headers = {"Content-type": "application/x-www-form-urlencoded"};
    var body = {"message":{"action":"calibrate"}};
    http.Response response = await http.post(url, headers: headers, body: body);
    print('Calibrating...');
  }*/

  /*Future<void> getWiFiData() async {
    while (true) {
      Uri url = Uri.http("192.168.4.1","/");
      http.Response response = await http.get(url);
      String message = response.body;
      print('Received message: $message');
      await Future.delayed(const Duration(seconds: 1));
    }
  }*/

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
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data.json');
    var longString = await file.readAsString();
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
    if (await file.exists()) await file.delete();
    await file.create();
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
      file.writeAsString(content, mode: FileMode.append);
      print(content);
    }
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
    return false;
  }
  return true;
}
}