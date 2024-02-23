import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:lodka/wifi.dart';
import 'package:path_provider/path_provider.dart';
import 'TileDownloader.dart';

class Modal extends StatefulWidget {
  final bool showModal;
  final LatLng? spotLocation;

  const Modal({super.key, required this.showModal, this.spotLocation});

  @override
  State<Modal> createState() => _ModalState();
}

class _ModalState extends State<Modal> {
  WiFi wifi = WiFi();
  Map dataList = {};
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    Map data = {};
    final directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/data.json");

    if (await file.exists()) {
      final String jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);
      data = jsonData;
    } else {
      try {
        ByteData byteData = await rootBundle.load('lib/data.json');
        Uint8List uint8List = byteData.buffer.asUint8List();
        await file.writeAsBytes(uint8List);
        String jsonString = utf8.decode(uint8List);
        data = json.decode(jsonString);
        // ignore: empty_catches
      } catch (e) {}
    }

    setState(() {
      dataList = data;
    });
  }

  Future<void> saveData() async {
    final directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/data.json");
    file.writeAsString(jsonEncode(dataList));
  }

  var rng = Random();
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GestureDetector(
        child: Container(
          color: const Color.fromARGB(128, 0, 0, 255),
        ),
        onTap: () {
          setState(() {
            Navigator.pop(context);
          });
        },
      ),
      Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0), color: Colors.black),
          height: 200.0,
          width: 400.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Row(
              children: [
                Flexible(
                  flex: 5,
                  fit: FlexFit.tight,
                  child: ListView.builder(
                      itemCount: dataList.length,
                      itemBuilder: (context, index) {
                        final lakeName = dataList.keys.elementAt(index);
                        return Card(
                          color: Colors.amber,
                          child: ExpansionTile(
                            title: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: IconButton(
                                            icon: const Icon(
                                                Icons.delete_forever,
                                                color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                dataList.remove(lakeName);
                                                saveData();
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    )),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    lakeName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: dataList[lakeName]["spots"].length,
                                itemBuilder: (context, spotIndex) {
                                  return Card(
                                    color: Colors.amber,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                            "Spot: ${dataList[lakeName]["spots"].keys.elementAt(spotIndex)}"),
                                            const SizedBox(
                                              width: 120,
                                            ),
                                        ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                wifi.autopilot(LatLng(
                                                    dataList[lakeName]["spots"].values.elementAt(spotIndex)[0],dataList[lakeName]["spots"].values.elementAt(spotIndex)[1]));
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                                shape: const CircleBorder()),
                                            child:
                                                const Icon(Icons.drive_eta))
                                      ],
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        );
                      }),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder()),
                        child: const Icon(Icons.close),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                              TileDownloader.markArea =
                                  !TileDownloader.markArea;
                            });
                          },
                          child: const Icon(Icons.add_circle))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}
