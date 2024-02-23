import 'dart:math';
import 'package:image/image.dart';
import 'package:latlong2/latlong.dart';
import 'package:lodka/json_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'gps.dart';


List<int> convertToTileCoordinates(double latitude, double longitude, int zoomLevel) {
  double latRad = latitude * (pi / 180.0);
  double lonRad = longitude * (pi / 180.0);
  num n = pow(2, zoomLevel);
  int tileX = ((longitude + 180.0) / 360.0 * n).floor();
  int tileY = ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * n).floor();
  return [tileX, tileY];
}

List<dynamic> convertToWorldPixelCoordinates(double latitude, double longitude, int zoomLevel) {

  double latRad = latitude * (pi / 180.0);
  double lonRad = longitude * (pi / 180.0);

  num n = pow(2, zoomLevel);
  double tileX = ((longitude + 180.0) / 360.0 * n).floorToDouble();
  double tileY = ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * n).floorToDouble();

  int tileSize = 256;
  double pixelX = ((longitude + 180.0) / 360.0 * n - tileX) * tileSize;
  double pixelY = ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * n - tileY) * tileSize;

  return [pixelX.toInt(), pixelY.toInt()];
}

Future<String> createAndSetPixelColor(double latitude, double longitude, int zoomLevel, List<int> rgb) async{
  double latRad = latitude * (pi / 180.0);
  double lonRad = longitude * (pi / 180.0);
  num n = pow(2, zoomLevel);
  int tileX = ((longitude + 180.0) / 360.0 * n).floor();
  int tileY = ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * n).floor();

///////////////////////////////////////

  int tileSize = 256;
  double x = ((longitude + 180.0) / 360.0 * n - tileX) * tileSize;
  double y = ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * n - tileY) * tileSize;
  int xCoord = x.round().clamp(0, 255);
  int yCoord = y.round().clamp(0, 255);

///////////////////////////////////////////////

  final directory = await getApplicationDocumentsDirectory();
  final heatMapPath = '${directory.path}/heatMap';
  final zoomPath = '$heatMapPath/$zoomLevel';
  final folderPath = '$zoomPath/$tileX';
  final filePath = '$folderPath/$tileY.png';

  final file = File(filePath);
  if (await file.exists()) {
    Image? image = decodePng(await file.readAsBytes());
    if (image?.getPixel(xCoord, yCoord) != 0) { //ak uz je farebny
      return filePath;
    }
    
    for (var i = -1; i < 2; i++) {
      for (var j = -1; j < 2; j++) {
        image?.setPixelRgba((xCoord+i).clamp(0, 255), (yCoord+j).clamp(0, 255), rgb[0],rgb[1],rgb[2]);
      }
    }
    await file.writeAsBytes(encodePng(image!));
    print('Image saved to: $filePath');
  }
  else{
    final image = Image(256, 256);

    for (var i = -1; i < 2; i++) {
      for (var j = -1; j < 2; j++) {
        image.setPixelRgba((xCoord+i).clamp(0, 255), (yCoord+j).clamp(0, 255), rgb[0],rgb[1],rgb[2]);
      }
    }
    await Directory(folderPath).create(recursive: true);
    await file.writeAsBytes(encodePng(image));
    print('Image saved to: $filePath');
  }

  return filePath;
}

List<int> detphToColor(double depth){
  num number = depth;
  number = number.clamp(0, 6);

  int red = (255 - ((number / 6) * 255)).toInt();
  int green = (number / 6 * 200).toInt();
  int blue = ((number / 6) * 255).toInt();

  return [red, green, blue];
}

Future<void> dataToTile() async {
  Map map = await JsonHandler.openJson();
  String? lake = await GPS().getLake();
  // ignore: unnecessary_null_comparison
  if (lake == null) {
    return;
  }
  for (var i = 0; i < map[lake]["data"].length; i++) {
    for (var j = 15; j < 19; j++) {
      await createAndSetPixelColor(map[lake]["data"][i]["coordinates"][0], map[lake]["data"][i]["coordinates"][1], j, detphToColor(map[lake]["data"][i]["depth"]));
    }
  }
}