import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double long = 48.209634;
  double lat = 17.728898;
  LatLng point = LatLng(48.209634, 17.728898);
  var location = [];

  @override
  Widget build(BuildContext context) { 
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            maxZoom: 18.49,
            center: LatLng(48.209634, 17.728898),
            zoom: 15,
            bounds: LatLngBounds(
              LatLng(48.20736795,17.72282668),
              LatLng(48.20993657,17.72705778),
            ),
            maxBounds: LatLngBounds(
              LatLng(48.20464469,17.72107338),
              LatLng(48.21285267,17.74011334),
            ),
          ),
          children: [
            TileLayer(
              /*urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a','b','c'],*/
              tileProvider: AssetTileProvider(),
              urlTemplate: "lib/offlineMap/{z}/{x}/{y}.png",
            ),
            MarkerLayer(markers: [
              Marker(
                width: 100,
                height: 100,
                point: point,
                builder: (ctx) => const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40.0,
                )
              )
            ])
          ],
        )
      ],
    );
  }
}