import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lodka/main.dart';
import 'wifi.dart';

class Setttings extends StatefulWidget {
  const Setttings({super.key});

  @override
  State<Setttings> createState() => _SetttingsState();
}

class _SetttingsState extends State<Setttings> {
  WiFi wifi = WiFi();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Settings"),
          centerTitle: true,
          automaticallyImplyLeading: false,
          shape: const BeveledRectangleBorder(side: BorderSide.none),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close)),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 300),
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: ListTile(
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                tileColor: Colors.white,
                title: const Text("Calibrate", style: TextStyle(fontSize: 18),),
                trailing: ElevatedButton(
                    onPressed: () async {
                      await showDialog(context: context, barrierDismissible: false, builder: (context) {
                        return const CustomDialog();
                      },);
                      
                    },
                    style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                    child: const Icon(Icons.compass_calibration)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: ListTile(
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                tileColor: Colors.white,
                title: const Text("Upload data", style: TextStyle(fontSize: 18),),
                trailing: ElevatedButton(
                    onPressed: () async {
                      await wifi.uploadFile();
                      
                    },
                    style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                    child: const Icon(Icons.upload)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: ListTile(
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                tileColor: Colors.white,
                title: const Text("Download data", style: TextStyle(fontSize: 18),),
                trailing: ElevatedButton(
                    onPressed: () async {
                      await wifi.downloadFile();
                      
                    },
                    style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                    child: const Icon(Icons.download)),
              ),
            ),
          ],
        )
        );
  }
}

class CustomDialog extends StatefulWidget {
  const CustomDialog({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  bool started = false;
  int _counter = 3;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 1) {
          _counter--;
        } else {
          if (started) {
            _timer.cancel();
            Navigator.of(context).pop();
          }
          else{
            wifi.calibrate();
            started = true;
            _counter = 10;
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Boat calibration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          started ? Text('Rotate boat for: $_counter seconds') : Text('Starting in: $_counter seconds'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}