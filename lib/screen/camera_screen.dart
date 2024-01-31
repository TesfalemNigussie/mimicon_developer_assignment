import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import 'edit_image_page.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? cameraController;
  late List<CameraDescription> _availableCameras;
  int selectedCameraIndex = 0;
  String? imagePath;

  @override
  void initState() {
    super.initState();

    availableCameras().then((value) {
      _availableCameras = value;

      cameraController = CameraController(
          _availableCameras[selectedCameraIndex], ResolutionPreset.max);

      cameraController!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });
  }

  changeCamera() async {
    if (cameraController?.description.lensDirection ==
        CameraLensDirection.back) {
      selectedCameraIndex = _availableCameras.indexOf(
        _availableCameras
            .where(
                (element) => element.lensDirection == CameraLensDirection.front)
            .first,
      );
    } else {
      selectedCameraIndex = _availableCameras.indexOf(
        _availableCameras
            .where(
                (element) => element.lensDirection == CameraLensDirection.back)
            .first,
      );
    }

    await cameraController!
        .setDescription(_availableCameras[selectedCameraIndex]);
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var tmp = MediaQuery.of(context).size;
    final screenH = max(tmp.height, tmp.width);
    final screenW = min(tmp.height, tmp.width);
    tmp = cameraController!.value.previewSize!;
    final previewH = max(tmp.height, tmp.width);
    final previewW = min(tmp.height, tmp.width);
    final screenRatio = screenH / screenW;
    final previewRatio = previewH / previewW;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1515),
        toolbarHeight: 40,
        actions: const [
          Icon(
            Icons.more_vert_sharp,
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: cameraController == null
                  ? const CupertinoActivityIndicator()
                  : OverflowBox(
                      maxHeight: screenRatio > previewRatio
                          ? screenH
                          : screenW / previewW * previewH,
                      maxWidth: screenRatio > previewRatio
                          ? screenH / previewH * previewW
                          : screenW,
                      child: CameraPreview(
                        cameraController!,
                      ),
                    ),
            ),
          ),
          Container(
            color: const Color(0xFF1A1515),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                InkWell(
                  onTap: () async {
                    final capturedImage = await cameraController!.takePicture();
                    await cameraController!.setFlashMode(FlashMode.off);
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditImagePage(
                            imagePath: capturedImage.path,
                          ),
                        ),
                      );
                      await cameraController!.resumePreview();
                    }
                  },
                  child: Image.asset(
                    'assets/icons/camera_icon.png',
                    width: 64,
                  ),
                ),
                const SizedBox(
                  height: 66,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        final selectedImage = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );

                        if (selectedImage?.path != null && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditImagePage(
                                imagePath: selectedImage!.path,
                              ),
                            ),
                          );
                        }
                      },
                      child: const ImageIcon(
                        AssetImage(
                          'assets/icons/gallery_icon.png',
                        ),
                        color: Colors.white,
                      ),
                    ),
                    InkWell(
                      onTap: changeCamera,
                      child: const ImageIcon(
                        AssetImage(
                          'assets/icons/change_camera_icon.png',
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 60,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
