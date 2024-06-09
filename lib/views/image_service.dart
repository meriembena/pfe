import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  final Function(String) onImageCaptured;
// maintenir l'état des widgets et d'optimiser les performances lors de modifications
  const CameraScreen({Key? key, required this.onImageCaptured})
      : super(key: key);
//Flutter a besoin de construire le widget, il appelle
//createState(). Cette méthode retourne une instance de _CameraScreenState,
//qui contient tout l'état nécessaire
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

//Contient et gère l'état dynamique du widget,construire l'interface utilisateur en réponse aux interactions de l'utilisateur.
class _CameraScreenState extends State<CameraScreen> {
  //une classe du package camera qui contrôle la caméra
  late CameraController _controller;
  //une instance est utilisée pour attendre l'initialisation de la caméra
  late Future<void> _initializeControllerFuture;

  @override
  // Initialise la caméra lors de la création de l'état
  void initState() {
    super.initState();
    //Initialise la caméra disponible
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    //Obtient la liste des caméras disponibles sur le dispositif
    final cameras = await availableCameras();
    //Sélectionne la première caméra de la liste.
    final firstCamera = cameras.first;
    //contrôler la première caméra avec une haute résolution
    _controller = CameraController(firstCamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    //mettre à jour l'ui
    setState(() {});
  }

  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prendre une photo'),
      ),
      //Construit l'interface utilisateur en fonction de l'état de _initializeControllerFuture.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          //snapshot contient l'état actuel du futur
          //Vérifie si le futur est complété
          if (snapshot.connectionState == ConnectionState.done) {
            if (_controller != null && _controller.value.isInitialized) {
              //le widget Stack permet de superposer plusieurs widgets les uns sur les autres.
              return Stack(
                children: [
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width *
                          _controller.value.aspectRatio,
                      //affiche l'aperçu de la caméra
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
