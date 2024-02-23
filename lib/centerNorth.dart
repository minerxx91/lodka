import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class CenterNorth extends StatefulWidget {
  final MapController mapController;

  const CenterNorth({Key? key, required this.mapController}) : super(key: key);

  @override
  State<CenterNorth> createState() => _CenterNorthState();
}

class _CenterNorthState extends State<CenterNorth> {
  bool isRotated = false;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isRotated,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(shape: const CircleBorder()),
        child: const Icon(Icons.north),
        onPressed: () {
          widget.mapController.rotate(0);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isRotated = widget.mapController.rotation != 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkRotation();
    });
  }

  void checkRotation() {
    if (widget.mapController.rotation != 0) {
      if (!isRotated) {
        setState(() {
          isRotated = true;
        });
      }
    } else {
      if (isRotated) {
        setState(() {
          isRotated = false;
        });
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkRotation();
    });
  }
}
