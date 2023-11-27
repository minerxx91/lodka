import 'package:flutter/material.dart';

class ClickableMarker extends StatefulWidget {
  final String name;
  final Function(String) onTapCallback;
  final Color color;

  const ClickableMarker(
      {Key? key, this.name = "Unnamed", required this.onTapCallback, required this.color})
      : super(key: key);

  @override
  State<ClickableMarker> createState() => _ClickableMarkerState();
}

class _ClickableMarkerState extends State<ClickableMarker> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.onTapCallback(widget.name);
        });
      },
      child: Icon(
        Icons.location_on,
        color: widget.color,
        size: 40.0,
      ),
    );
  }
}
