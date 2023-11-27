import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'tiles.dart';

class TileManager {
  static TileLayer layer = TileLayer(
      backgroundColor: Colors.transparent,
      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      subdomains: const ['a', 'b', 'c'],
      tileProvider: NetworkTileProvider());

  static Future<bool> checkInternetConnection() async {
    try {
      final response = await http.head(Uri.parse("https://www.google.com"));
      if (response.statusCode == 200) {
        print("ide internet");
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error checking internet connection: $e");
      return false;
    }
  }

  static Future<bool> lookForTile(LatLng position) async {
    Directory directory = await getApplicationDocumentsDirectory();
    List tile =
        convertToTileCoordinates(position.latitude, position.longitude, 18);
    String finalDirectory =
        "${directory.path}/offlineMap/18/${tile[0]}/${tile[1]}.png";
    if (await Directory(finalDirectory).exists()) {
      return true;
    }
    return false;
  }

  static Future<void> selectLayer() async {
    if (await checkInternetConnection()) {
      layer = TileLayer(
          backgroundColor: Colors.transparent,
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
          tileProvider: NetworkTileProvider());
    } else {
      Directory directory = await getApplicationDocumentsDirectory();
      if (await lookForTile(LatLng(48.209634, 17.728898))) {
        layer = TileLayer(
          tileProvider: FileTileProvider(),
          urlTemplate: "${directory.path}/offlineMap/{z}/{x}/{y}.png",
          errorImage: const AssetImage("lib/error.png"),
          backgroundColor: Colors.transparent,
        );
      } else {
        layer = TileLayer(
            backgroundColor: Colors.transparent,
            tileProvider: AssetTileProvider(),
            urlTemplate: "lib/offlineMap/{z}/{x}/{y}.png");
      }
    }
  }
}
