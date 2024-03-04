import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter/services.dart';
import 'package:lodka/TileDownloader.dart';
import 'package:lodka/add_spot.dart';
import 'centerNorth.dart';
import 'package:lodka/json_handler.dart';
import 'package:lodka/settings.dart';
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
WiFi wifi = WiFi();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  directory = await getApplicationDocumentsDirectory();
  wifi.listenToWebsocket();

  runApp(const MyApp());
}

const step = 10.0;
double previousY = 0;
double previousX = 0;
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
  String layerDirectory = "${directory.path}/heatMap/{z}/{x}/{y}.png";
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInit) {
      _initializeData();
      refreshMap();
      _isInit = true;
    }
  }

  void refreshMap() {
    Timer.periodic(const Duration(seconds: 5), (Timer t) {
      setState(() {
        layerDirectory = "reload";
        print(layerDirectory);
        layerDirectory = "${directory.path}/heatMap/{z}/{x}/{y}.png";
        print(layerDirectory);
      });
    });
  }

  Future<void> _initializeData() async {
    final spotsList = await JsonHandler.loadSpots();
    Map spotsData = spotsList;
    for (var i = 0; i < spotsData.length; i++) {
      addSpot(
          LatLng(spotsData.values.elementAt(i)[0],
              spotsData.values.elementAt(i)[1]),
          spotsData.keys.elementAt(i));
    }
    setState(() {});
  }

  void addSpot(LatLng point, String name) {
    Marker marker = Marker(
        point: LatLng(48.209595, 17.728527),
        anchorPos: AnchorPos.align(AnchorAlign.top),
        builder: (context) => ClickableMarker(
            onTapCallback: (p0) {
              setState(() {
                if (Bar.bar) {
                  Bar.barText = p0;
                } else {
                  Bar.bar = !Bar.bar;
                  Bar.barText = p0;
                }
              });
            },
            name: name,
            color: Colors.blue));
    Spots.markers.add(marker);
    JsonHandler.addSpot(point, name);
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
              //minZoom: 15,
              /*maxBounds: LatLngBounds(
                LatLng(48.20464469, 17.72107338),
                LatLng(48.21285267, 17.74011334),
              ),*/
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
                setState(() {});
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
            TileManager.layer,
            TileLayer(
              tileProvider: FileTileProvider(),
              urlTemplate: layerDirectory,
              errorImage: const AssetImage("lib/error.png"),
              backgroundColor: Colors.transparent,
            ),
            /*TileLayer(
              tileProvider: FileTileProvider(),
              urlTemplate: "${directory.path}/offlineMap/{z}/{x}/{y}.png",
              errorImage: const AssetImage("lib/error.png"),
              backgroundColor: Colors.transparent,
            ),*/
            MarkerLayer(markers: [
              Marker(
                  point: GPS.getLocationLatLng(),
                  anchorPos: AnchorPos.align(AnchorAlign.top),
                  builder: (ctx) {
                    return ClickableMarker(
                      color: Colors.red,
                      name: "You",
                      onTapCallback: (name) {
                        setState(() {
                          if (Bar.bar) {
                            Bar.barText = name;
                          } else {
                            Bar.bar = !Bar.bar;
                            Bar.barText = name;
                          }
                        });
                      },
                    );
                  }),
              Marker(
                point: WiFi.position,
                anchorPos: AnchorPos.align(AnchorAlign.top),
                builder: (context) {
                  return ClickableMarker(
                    name: "Boat",
                      onTapCallback: (name){
                          setState(() {
                            if (Bar.bar) {
                              Bar.barText = name;
                            } else {
                              Bar.bar = !Bar.bar;
                              Bar.barText = name;
                            }
                          });
                      }, color: Colors.red);
                },
              )
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
                      setState(() {
                        wifi.returnHome();
                      });
                    },
                    onLongPress: () {
                      setState(() {
                        wifi.setHome(GPS.getLocationLatLng());
                      });
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
                          setState(() {
                            wifi.closeSocket();
                            wifi.connectSocket();
                            //JsonHandler.deleteHeatMap();
                            wifi.openChamber("left");
                          });
                        },
                        onLongPress: () {
                          setState(() {
                            wifi.releaseHook("left");
                          });
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
                          setState(() {
                            wifi.openChamber("right");
                          });
                        },
                        onLongPress: () {
                          setState(() {
                            wifi.releaseHook("right");
                          });
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
                              500 ||
                          (details.y == 0 &&
                              DateTime.now().millisecondsSinceEpoch -
                                      wifi.sent >
                                  100) ||
                          ((0.05 < previousX &&
                                  previousX < -0.05 &&
                                  0.05 < previousY &&
                                  previousY < -0.05) &&
                              (details.x > -0.05 &&
                                  details.x < 0.05 &&
                                  details.y < 0.05 &&
                                  details.y > -0.05))) {
                        wifi.sent = DateTime.now().millisecondsSinceEpoch;
                        print(DateTime.now());
                        previousY = details.y * (-1);
                        previousX = details.x * (-1);
                        wifi.sendWiFiData(
                            "{\"y\":${(details.y * (-1)).toString()}, \"x\":${(details.x * (-1)).toString()}}");
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
            padding: const EdgeInsets.only(right: 15, top: 20, bottom: 10),
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            opaque: false,
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
                      addSpot(point, dialogData.text);
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
                          await showDialog(
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
                            fixedSize: const Size(50, 50),
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero),
                        child: const Icon(
                          Icons.check_circle,
                          size: 50,
                        ))),
                        const Spacer(flex: 1),
                        ElevatedButton(onPressed: () {
                          Navigator.push(context, 
                          MaterialPageRoute(builder: (context) => const Setttings()));
                        },
                        style: ElevatedButton.styleFrom(shape: const CircleBorder(), fixedSize: const Size(50, 50)),
                        child: const Icon(Icons.settings))
              ],
            ),
          ),
        ),
        Bar(spotName: Bar.barText, visible: Bar.bar),
      ],
    );
  }
}
