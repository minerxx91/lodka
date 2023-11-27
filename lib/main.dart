import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter/services.dart';
import 'package:lodka/TileDownloader.dart';
import 'package:lodka/add_spot.dart';
import 'package:lodka/centrovanieZasrate.dart';
import 'package:lodka/tile_manager.dart';
import 'bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'clickable_marker.dart';
import 'gps.dart';
import 'modal.dart';
import 'wifi.dart';
import 'tiles.dart';

var directory;
WiFi wifi = new WiFi();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  //createAndSetPixelColor(48.209770, 17.728487, 18);
  /*print(convertToTileCoordinates(48.209772, 17.728479, 18));
  print(convertToWorldPixelCoordinates(48.209772, 17.728479, 18));*/
  directory = await getApplicationDocumentsDirectory();

  runApp(const MyApp());
}

const step = 10.0;
bool showModal = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
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
  void addSpot(LatLng point, String name) {
    Marker marker = Marker(
      point: LatLng(48.209595, 17.728527),
      anchorPos: AnchorPos.align(AnchorAlign.top),
      builder: (context) => ClickableMarker(onTapCallback: (p0) {
        setState(() {
          Bar.bar = !Bar.bar;
          Bar.barText = p0;
          print("banik");
        });
      },
      color: Colors.blue)
    );
    Spots.markers.add(marker);
  }

  MapController mapController = MapController();
  bool isVisible = false;
  double _x = 100;
  double _y = 100;
  double long = 48.209634;
  double lat = 17.728898;
  LatLng point = LatLng(48.209634, 17.728898);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
              maxZoom: 18.49,
              center: LatLng(48.209634, 17.728898),
              zoom: 15,
              minZoom: 15,
              maxBounds: LatLngBounds(
                LatLng(48.20464469, 17.72107338),
                LatLng(48.21285267, 17.74011334),
              ),
              onTap: (tapPosition, pointTap) {
                setState(() {
                  Bar.bar = false;
                  if (TileDownloader.markArea) {
                    TileDownloader.addMarker(pointTap);
                  } else {
                    TileDownloader.removeEverything();
                  }
                });
              },
              onMapReady: () {
                TileManager.selectLayer();
                print(TileManager.layer.urlTemplate);
              },
              enableMultiFingerGestureRace: true),
          children: [
            /*TileLayer(
                backgroundColor: Colors.transparent,
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
                tileProvider: NetworkTileProvider()),
            TileLayer(
                /*urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],*/
                backgroundColor: Colors.transparent,
                tileProvider: AssetTileProvider(),
                urlTemplate: "lib/offlineMap/{z}/{x}/{y}.png"),*/
            TileLayer(
              tileProvider: FileTileProvider(),
              urlTemplate: "${directory.path}/heatMap/{z}/{x}/{y}.png",
              errorImage: const AssetImage("lib/error.png"),
              backgroundColor: Colors.transparent,
            ),
            /*TileLayer(
              tileProvider: FileTileProvider(),
              urlTemplate: "${directory.path}/offlineMap/{z}/{x}/{y}.png",
              errorImage: const AssetImage("lib/error.png"),
              backgroundColor: Colors.transparent,
            ),*/
            TileManager.layer,
            MarkerLayer(markers: [
              Marker(
                  point: point,
                  anchorPos: AnchorPos.align(AnchorAlign.top),
                  builder: (ctx) {
                    return ClickableMarker(
                        color: Colors.red,
                        name: "You",
                        onTapCallback: (name) {
                          setState(() {
                            Bar.bar = !Bar.bar;
                            Bar.barText = name;
                          });
                        },
                      );
                  }),
            ]),
            MarkerLayer(markers: TileDownloader.markers),
            MarkerLayer(markers: Spots.markers),
            PolygonLayer(polygons: TileDownloader.polygonPoints)
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 20),
          child: SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CenterNorth(mapController: mapController),
                const Position(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      //createAndSetPixelColor(48.209780, 17.728482, 18, 0, 255, 0);
                      //detphToColor(3);
                      //downloadOpenStreetMapTile(18, 143981, 90896);
                      print(Bar.barText);
                    },
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        fixedSize: const Size(50, 50)),
                    child: const Icon(Icons.home),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            fixedSize: const Size(50, 50)),
                        child: const Icon(
                          Icons.arrow_left,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            fixedSize: const Size(50, 50)),
                        child: const Icon(
                          Icons.arrow_right,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Joystick(
                  mode: JoystickMode.all,
                  listener: (details) {
                    setState(() {
                      _x = _x + step * details.x;
                      _y = _y + step * details.y;
                      if (DateTime.now().millisecondsSinceEpoch - wifi.sent >
                          200) {
                        /*print("Sent x: "+details.x.toString());
                        print("Sent y: "+details.y.toString());*/
                        wifi.sendWiFiData(
                            details.x.toString(), details.y.toString());
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding: const EdgeInsets.only(right: 15, top: 20),
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            opaque: false, // set to false
                            pageBuilder: (_, __, ___) =>
                                Modal(showModal: showModal),
                          ),
                        );
                      });
                    },
                    child: const Icon(Icons.list)),
                ElevatedButton(
                    onPressed: () async {
                      DialogData dialogData = await showDialog(
                        context: context,
                        builder: (context) {
                          return TextInputDialog(location: point);
                        },
                      );
                      addSpot(point, "df");
                    },
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        fixedSize: const Size(40, 40)),
                    child: const Icon(Icons.add_location_alt)),
                Visibility(
                    visible: TileDownloader.markArea,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          fixedSize: const Size(50, 50),
                          padding: EdgeInsets.zero),
                      onPressed: () {
                        setState(() {
                          TileDownloader.removeEverything();
                        });
                      },
                      child: const Icon(Icons.cancel, size: 50),
                    )),
                Visibility(
                    visible: TileDownloader.markArea &&
                        TileDownloader.markers.length == 2,
                    child: ElevatedButton(
                        onPressed: () async {
                          AddLakeData addLakeData = await showDialog(
                            context: context,
                            builder: (context) {
                              return AddLake(points: [
                                TileDownloader.markers[0].point,
                                TileDownloader.markers[1].point
                              ]);
                            },
                          );
                          setState(() {
                            TileDownloader.markArea = false;
                            TileDownloader.removeEverything();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder()),
                        child: const Icon(
                          Icons.check_circle,
                          size: 50,
                        )))
              ],
            ),
          ),
        ),
        Bar(spotName: Bar.barText, visible: Bar.bar),
      ],
    );
  }
}
