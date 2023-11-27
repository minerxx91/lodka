import 'package:flutter/material.dart';
import 'package:location/location.dart';

Location location = Location();
bool _serviceEnabled = false;
PermissionStatus _permissionGranted = PermissionStatus.denied;
// ignore: unused_element
LocationData _locationData = LocationData.fromMap({'latitude': 0.0, 'longitude': 0.0});

Future<dynamic> getLocation() async {
  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
  }
  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
  }
  Location().onLocationChanged.listen((LocationData currentLocation) {
    _locationData = currentLocation;
  });
  _locationData = await location.getLocation();
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
            /*Text("${_locationData.latitude} ${_locationData.longitude}",
          style: const TextStyle(fontSize: 10)),*/
);
  }
}
