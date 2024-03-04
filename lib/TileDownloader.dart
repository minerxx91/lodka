import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lodka/json_handler.dart';
import 'package:lodka/tiles.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show Uint8List;
import 'dart:io';

class TileDownloader {
  static bool markArea = false;
  static List<Marker> markers = [];
  static List<Polygon> polygonPoints = [];

  static Future<void> downloadArea(LatLngBounds bounds) async{
    final directory = await getApplicationDocumentsDirectory();
    for (int zoom = 15; zoom <= 18; zoom++) {
      int minTileX = convertToTileCoordinates(bounds.southWest.latitude, bounds.southWest.longitude, zoom)[0];
      int maxTileX = convertToTileCoordinates(bounds.northEast.latitude, bounds.northEast.longitude, zoom)[0];
      int minTileY = convertToTileCoordinates(bounds.northEast.latitude, bounds.southWest.longitude, zoom)[1];
      int maxTileY = convertToTileCoordinates(bounds.southWest.latitude, bounds.northEast.longitude, zoom)[1];

      for (int tileX = minTileX; tileX <= maxTileX; tileX++) {
        for (int tileY = minTileY; tileY <= maxTileY; tileY++) {
          String tileUrl = 'https://tile.openstreetmap.org/$zoom/$tileX/$tileY.png';

          var response = await http.get(Uri.parse(tileUrl));

          if (response.statusCode == 200) {
            Uint8List bytes = response.bodyBytes;
            File file = File('${directory.path}/offlineMap/$zoom/$tileX/$tileY.png');
            if (!await file.exists()) {
              await Directory('${directory.path}/offlineMap/$zoom/$tileX/$tileX.png').create(recursive: true);
              await file.writeAsBytes(bytes);
              print('Tile downloaded: ${file.path}');
            }
            else print('File ${directory.path}/offlineMap/$zoom/$tileX/$tileX.png already exists!');
          } else {
            print('Failed to download tile: ${response.statusCode}');
          }
        }
      }
    }
  }

  static void addMarker(LatLng point){
    Marker marker = Marker(
    point: point,
    height: 100,
    width: 100,
    anchorPos: AnchorPos.align(AnchorAlign.center),
    builder: (context) => const Icon(
      Icons.location_searching,
      color: Colors.green,
      size: 35,
    ));
    if (markers.length<2) {
      markers.add(marker);
    }
    if (markers.length==2 && polygonPoints.isEmpty) {
      createPoligon();
    }
  }

  static void createPoligon(){
    LatLngBounds bounds = LatLngBounds.fromPoints([markers[0].point,markers[1].point]);
    Polygon polygon = Polygon(points: [LatLng(bounds.northWest.latitude,bounds.northWest.longitude), LatLng(bounds.northEast.latitude, bounds.northEast.longitude), LatLng(bounds.southEast.latitude, bounds.southEast.longitude), LatLng(bounds.southWest.latitude,bounds.southWest.longitude)],
    color: Colors.green.withOpacity(0.5),
    isFilled: true
    );
    polygonPoints.add(polygon);
  }

  static void removeEverything(){
    markArea = false;
    markers.clear();
    polygonPoints.clear();
  }
}

class AddLakeData {
  final String text;
  final LatLngBounds bounds;

  AddLakeData({required this.text, required this.bounds});
}

class AddLake extends StatefulWidget {
  final List<LatLng> points;

  const AddLake({super.key, required this.points});

  @override
  State<AddLake> createState() => _AddLakeState();
}

class _AddLakeState extends State<AddLake> {
  final TextEditingController _textController = TextEditingController();
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Add Lake'),
      content: TextField(
        controller: _textController,
        decoration: InputDecoration(
            labelText: 'Lake name',
            isDense: true,
            contentPadding: const EdgeInsets.all(1),
            errorText: error ? "Invalid" : null),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (widget.points.length == 2 && _textController.text.isNotEmpty) {
              AddLakeData addLakeData = AddLakeData(
                  text: _textController.text,
                  bounds: LatLngBounds.fromPoints(widget.points));
              TileDownloader.downloadArea(LatLngBounds.fromPoints(widget.points));
              Navigator.of(context).pop(addLakeData);
              TileDownloader.removeEverything();
              JsonHandler.addToJson(_textController.text, LatLngBounds.fromPoints(widget.points));
            } else {
              setState(() {
                error = true;
              });
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
