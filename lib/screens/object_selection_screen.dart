import 'package:flutter/material.dart';
import 'object_detector_screen.dart';

class ObjectSelectionScreen extends StatelessWidget {
  final List<String> objects = ['Laptop', 'Mobile', 'Bottle', 'Mouse'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Object')),
      body: ListView.builder(
        itemCount: objects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(objects[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageSelectionScreen(objectName: objects[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
