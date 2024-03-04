import 'dart:convert';
import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lodka/main.dart';
import 'package:path_provider/path_provider.dart';
import 'gps.dart';


class JsonHandler {

  static Future<Map> openJson() async {
    final directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/data.json");

    final String jsonString = await file.readAsString();
    Map<String, dynamic> map = jsonDecode(jsonString);

    return map;
  }

  static Future<void> saveJson(Map map) async {
    final directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/data.json");
    await file.writeAsString(jsonEncode(map));
  }

  static Future<void> addSpot(LatLng point, String name) async {
    String? lake = await GPS().getLake();
      Map map = await openJson();
      map[lake]["spots"][name] = [point.latitude, point.longitude];
      saveJson(map);
  }

  static Future<Map> loadSpots() async {
    String? lake = await GPS().getLake();
    Map map = await openJson();
    Map<String, dynamic> spots = map[lake]["spots"];
    return spots;
  }

  static Future<void> addToJson(String name, LatLngBounds coords) async {
    final directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/data.json");

    final String jsonString = await file.readAsString();
    Map<String, dynamic> map = jsonDecode(jsonString);

    if (!map.containsKey(name)) {
      map[name] = {"coords": [[coords.northWest.latitude, coords.northWest.longitude], [coords.southEast.latitude, coords.southEast.longitude]], "spots":{}, "data":[]};
      await file.writeAsString(jsonEncode(map));
    }
  }

  static Future<void> addDepth(double lat, double lng, double depth) async{
    String? lake = await GPS().getLake();
    final directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/data.json");

    final String jsonString = await file.readAsString();
    Map<String, dynamic> map = jsonDecode(jsonString);
    map[lake]["data"].add({
    "coordinates": [lat, lng],
    "depth": depth,
    });
    await file.writeAsString(jsonEncode(map));
  }

  static Future<void> deleteHeatMap() async{
    final directory = await getApplicationDocumentsDirectory();
    Directory heatMapDirectory = Directory("${directory.path}/heatMap");
    await heatMapDirectory.delete(recursive: true);
  }
}