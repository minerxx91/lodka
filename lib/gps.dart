import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:lodka/json_handler.dart';

Location location = Location();
bool _serviceEnabled = false;
PermissionStatus _permissionGranted = PermissionStatus.denied;
LocationData _locationData = LocationData.fromMap({'latitude': 0.0, 'longitude': 0.0});

class GPS {

  static LatLng getLocationLatLng() {
  double latitude = _locationData.latitude ?? 0.0;
  double longitude = _locationData.longitude ?? 0.0;

  LatLng coordinates = LatLng(latitude, longitude);
  return coordinates;
  }


    Future<void> getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }

    _locationData = await location.getLocation();

    location.onLocationChanged.listen((LocationData currentLocation) {
      _locationData = currentLocation;
    });
  }

  Future<String?> getLake() async {
    await getLocation();

    Map map = await JsonHandler.openJson();

    for (var i = 0; i < map.length; i++) {
      List northwest = map.values.elementAt(i)["coords"][0];
      List southEast = map.values.elementAt(i)["coords"][1];
      if (_locationData.latitude! < northwest[0] && _locationData.latitude! > southEast[0] && _locationData.longitude! > northwest[1] && _locationData.longitude! < southEast[1]) {
        return map.keys.elementAt(i);
      }
    }
    print("${_locationData.latitude}, ${_locationData.longitude}");
    return null;
    }
}

class Position extends StatefulWidget {
  const Position({super.key});

  @override
  State<Position> createState() => _PositionState();
}

class _PositionState extends State<Position> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LocationData>(
            stream: Location().onLocationChanged,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                    'Latitude: ${snapshot.data!.latitude}, Longitude: ${snapshot.data!.longitude}', style: const TextStyle(fontSize: 10),);
              }
              else {
                return const Text("nic", style: TextStyle(fontSize: 10),);
              }
            }
);
  }
}
