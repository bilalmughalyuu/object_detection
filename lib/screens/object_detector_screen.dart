import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class ImageSelectionScreen extends StatefulWidget {
  final String objectName;

  const ImageSelectionScreen({super.key, required this.objectName});

  @override
  _ImageSelectionScreenState createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  late ObjectDetector _objectDetector;
  String guidanceMessage = "Select an image to detect ${""}...";
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeObjectDetector();
  }

  Future<void> _initializeObjectDetector() async {
    final options = ObjectDetectorOptions(
      classifyObjects: false,
      multipleObjects: false,
      mode: DetectionMode.single,
    );
    _objectDetector = ObjectDetector(options: options);
  }

  Future<void> _selectImage() async {
    final pickedFile =
    await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        guidanceMessage = "Processing image...";
      });
      await _processImage(InputImage.fromFilePath(pickedFile.path));
    } else {
      setState(() {
        guidanceMessage = "No image selected.";
      });
    }
  }

  Future<void> _processImage(InputImage inputImage) async {
    final objects = await _objectDetector.processImage(inputImage);

    if (objects.isNotEmpty) {
      final detectedLabels = objects
          .expand((detectedObject) =>
          detectedObject.labels.map((label) => label.text))
          .toList();

      final detectedObject = detectedLabels
          .where((label) =>
          label.toLowerCase().contains(widget.objectName.toLowerCase()))
          .toList();

      if (detectedObject.isNotEmpty) {
        setState(() {
          guidanceMessage = "Object detected: ${widget.objectName}";
        });
      } else {
        setState(() {
          final foundObjects = detectedLabels.join(", ");
          guidanceMessage = "${widget.objectName} not found in the image.\n"
              "Objects detected: ${foundObjects.isNotEmpty ? foundObjects : 'None'}";
        });
      }
    } else {
      setState(() {
        guidanceMessage = "No objects detected in the image.";
      });
    }
  }

  @override
  void dispose() {
    _objectDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detect ${widget.objectName}')),
      body: Column(
        children: [
          if (_selectedImage != null)
            Image.file(
              _selectedImage!,
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          else
            Container(
              height: 400,
              color: Colors.grey[200],
              child: const Center(child: Text("No image selected.")),
            ),
          const SizedBox(height: 20),
          Text(
            guidanceMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _selectImage,
            child: const Text('Select Image from Gallery'),
          ),
        ],
      ),
    );
  }
}
