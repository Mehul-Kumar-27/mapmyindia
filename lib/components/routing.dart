import 'package:flutter/material.dart';

class LocationDestinationSelector extends StatefulWidget {
  const LocationDestinationSelector({super.key});

  @override
  State<LocationDestinationSelector> createState() =>
      _LocationDestinationSelectorState();
}

class _LocationDestinationSelectorState
    extends State<LocationDestinationSelector> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.red,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Select Destination"),
            ))
      ],
    );
  }
}
