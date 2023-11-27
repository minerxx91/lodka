import 'dart:math';
import 'package:image/image.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Convert latitude, longitude, and zoom level to tile coordinates
List<int> convertToTileCoordinates(double latitude, double longitude, int zoomLevel) {
  double latRad = latitude * (pi / 180.0);
  double lonRad = longitude * (pi / 180.0);
  num n = pow(2, zoomLevel);
  int tileX = ((longitude + 180.0) / 360.0 * n).floor();
  int tileY = ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * n).floor();
  return [tileX, tileY];
}

List<dynamic> convertToWorldPixelCoordinates(double latitude, double longitude, int zoomLevel) {
  // Convert latitude and longitude to radians
  double latRad = latitude * (pi / 180.0);
  double lonRad = longitude * (pi / 180.0);

  // Calculate tile coordinates
  num n = pow(2, zoomLevel);
  double tileX = ((longitude + 180.0) / 360.0 * n).floorToDouble();
  double tileY = ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * n).floorToDouble();

  // Calculate pixel coordinates within the tile
  int tileSize = 256; // Size of each tile in pixels
  double pixelX = ((longitude + 180.0) / 360.0 * n - tileX) * tileSize;
  double pixelY = ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * n - tileY) * tileSize;

  return [pixelX.toInt(), pixelY.toInt()];
}

void main() {
  /*double latitude = 37.7749;
  double longitude = -122.4194;
  int zoomLevel = 1;

  List<int> tileCoordinates = convertToTileCoordinates(latitude, longitude, zoomLevel);

  int tileX = tileCoordinates[0];
  int tileY = tileCoordinates[1];

  print('Latitude and longitude ($latitude, $longitude) converted to tile coordinates at zoom level $zoomLevel: ($tileX, $tileY)');

  List<dynamic> pixelCoordinates = convertToWorldPixelCoordinates(latitude, longitude, zoomLevel);

  int pixelX = pixelCoordinates[0];
  int pixelY = pixelCoordinates[1];

  print('World coordinates ($latitude, $longitude) converted to pixel coordinates within a tile at zoom level $zoomLevel: ($pixelX, $pixelY)');*/
}

Future<String> createAndSetPixelColor(double latitude, double longitude, int zoomLevel, int r, int g, int b) async{
  double latRad = latitude * (pi / 180.0);
  double lonRad = longitude * (pi / 180.0);
  num n = pow(2, zoomLevel);
  int tileX = ((longitude + 180.0) / 360.0 * n).floor();
  int tileY = ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * n).floor();

///////////////////////////////////////

  // Calculate pixel coordinates within the tile
  int tileSize = 256; // Size of each tile in pixels
  double x = ((longitude + 180.0) / 360.0 * n - tileX) * tileSize;
  double y = ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * n - tileY) * tileSize;

///////////////////////////////////////////////
  
  final image = Image(256, 256);

  image.setPixelRgba(x.round(), y.round(), 0, 255, 0);

  final directory = await getApplicationDocumentsDirectory();
  final heatMapPath = '${directory.path}/heatMap';
  final zoomPath = '$heatMapPath/$zoomLevel';
  final folderPath = '$zoomPath/$tileX';
  final filePath = '$folderPath/$tileY.png';

  final file = File(filePath);
  if (await file.exists()) {
    Image? image = decodePng(await file.readAsBytes());
    if (image?.getPixel(x.round(), y.round()) == 0) {
      print(image?.getPixel(x.round(), y.round()));
      return filePath;
    }
    image?.setPixelRgba(x.round(), y.round(), 0, 255, 0);
    file.writeAsBytes(encodePng(image!));
    print('Image saved to: $filePath');
  }
  else{
    await Directory(folderPath).create(recursive: true);
    // Save the image to the file
    //final file = File(filePath);
    file.writeAsBytes(encodePng(image));
    print('Image saved to: $filePath');
  }

  return filePath;
}

List<int> detphToColor(int depth){
  num number = depth;
  number = number.clamp(0, 6);

  // Calculate the red, green, and blue components based on depth
  int red = (255 - ((number / 6) * 255)).toInt();
  int green = (number / 6 * 200).toInt(); // Adjust the green component
  int blue = ((number / 6) * 255).toInt();

  // Return red, green, and blue components as a list
  return [red, green, blue];
}