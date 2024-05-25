import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  final Function(String) onImageCaptured;

  const CameraScreen({Key? key, required this.onImageCaptured})
      : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prendre une photo'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_controller != null && _controller.value.isInitialized) {
              return Stack(
                children: [
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width *
                          _controller.value.aspectRatio,
                      child: CameraPreview(_controller),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FloatingActionButton(
                        onPressed: () async {
                          try {
                            await _initializeControllerFuture;
                            final XFile file = await _controller.takePicture();
                            widget.onImageCaptured(file.path);
                          } catch (e) {
                            print('Error taking picture: $e');
                          }
                        },
                        child: Icon(Icons.camera),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: Text('Camera not available'));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class DisplayImageScreen extends StatelessWidget {
  final String imagePath;

  DisplayImageScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Capturée'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.file(File(imagePath)),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle image sending
            },
            child: Text('Envoyer au Chatbot'),
          ),
        ],
      ),
    );
  }
}
