import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lodka/add_spot.dart';
import 'package:latlong2/latlong.dart';
import 'TileDownloader.dart';

class Modal extends StatefulWidget {
  final bool showModal;
  final LatLng? spotLocation;

  const Modal({super.key, required this.showModal, this.spotLocation});

  @override
  State<Modal> createState() => _ModalState();
}

class _ModalState extends State<Modal> {
  Map dataList = {};
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final String jsonString = await rootBundle.loadString('lib/data.json');
    final jsonData = json.decode(jsonString);
    final Map data = jsonData;

    setState(() {
      dataList = data;
    });
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
                        print(dataList[lakeName]["spots"]);
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
                                            icon: const Icon(Icons.edit),
                                            color: Colors.blue,
                                            onPressed: () {
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        // Rename button
                                        Expanded(
                                          flex: 1,
                                          child: IconButton(
                                            icon: const Icon(
                                                Icons.delete_forever,
                                                color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                dataList.remove(lakeName);
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
                                  print(spotIndex);
                                  return Card(
                                    color: Colors.amber,
                                    child: Text("Spot: ${dataList[lakeName]["spots"].keys.elementAt(spotIndex)}"),
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
                              /*AddLakeData addLakeData = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AddLake(points: [],);
                                },
                              );*/
                              //pridat rybnik do json
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
