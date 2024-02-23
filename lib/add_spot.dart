import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lodka/TileDownloader.dart';
import 'package:lodka/gps.dart';
import 'package:lodka/main.dart';
import 'clickable_marker.dart';
import 'bar.dart';

class Spots {
  static List<Marker> markers = [];
}

class DialogData {
  final String text;
  final LatLng location;

  DialogData({required this.text, required this.location});
}

class TextInputDialog extends StatefulWidget {
  final LatLng? location;
  const TextInputDialog({super.key, this.location});
  @override
  // ignore: library_private_types_in_public_api
  _TextInputDialogState createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  final TextEditingController _textController = TextEditingController();
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Add spot'),
      content: TextField(
        controller: _textController,
        decoration: InputDecoration(
            labelText: 'Spot name',
            isDense: true,
            contentPadding: const EdgeInsets.all(1),
            errorText: error ? "Invalid" : null),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (widget.location != null && _textController.text.isNotEmpty) {
              setState(() {
              DialogData dialogData = DialogData(
                  text: _textController.text,
                  location: LatLng(48.209634, 17.728898));
              Navigator.of(context)
                  .pop(dialogData);
              });
            } else {
              setState(() {
                error = true;
              });
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
