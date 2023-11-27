import 'package:flutter/material.dart';

class Bar extends StatefulWidget {
  static bool bar = false;
  static String barText = "";

  final String spotName;
  bool visible;

  Bar({Key? key, required this.spotName, required this.visible}) : super(key: key);

  @override
  State<Bar> createState() => _BarState();
}

class _BarState extends State<Bar> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      width: MediaQuery.of(context).size.width,
      height: 50,
      bottom: widget.visible ? 0 : -100,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
      child: Container(
        color: Colors.blue,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(shape: const CircleBorder()),
                child: const Icon(Icons.navigation_rounded),
              ),
            ),
            Expanded(
              child: Text(
                textAlign: TextAlign.center,
                widget.spotName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -25.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      widget.visible = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(shape: const CircleBorder()),
                  child: const Icon(Icons.close),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
