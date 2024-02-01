import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../model/shader_model.dart';
import '../painter/canvas_painter.dart';
import '../widget/toast_widget.dart';

class EditImagePage extends StatefulWidget {
  final String imagePath;

  const EditImagePage({super.key, required this.imagePath});

  @override
  State<EditImagePage> createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  late FaceDetector _faceDetector;
  ShapeItem? _currentShader;
  final List<ShapeItem> _shaders = [];
  bool _dragging = false;
  bool isImageEdited = false;
  bool hasMultipleFaces = false;
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
    );

    _faceDetector
        .processImage(InputImage.fromFilePath(widget.imagePath))
        .then((value) {
      if (value.length > 1) {
        hasMultipleFaces = false;
        Toast(
          context: context,
          message: '2개 이상의 얼굴이 감지되었어요!',
        );
      } else if (value.isEmpty) {
        hasMultipleFaces = true;
      } else {
        hasMultipleFaces = true;
      }
      setState(() {});
    });
  }

  _handlePanStart(Offset position) {
    for (int i = _shaders.length - 1; i >= 0; i--) {
      if (Rect.fromLTWH(
        _shaders[i].startOffset.dx + 70,
        _shaders[i].startOffset.dy + 70,
        _shaders[i].size.width + 70,
        _shaders[i].size.height + 70,
      ).contains(position)) {
        _currentShader = _shaders[i];
        _dragging = true;
        break;
      }
    }
  }

  _downloadEditedImage(BuildContext context) async {
    if(isImageEdited){
      RenderRepaintBoundary boundary =
      _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? imageData = byteData?.buffer.asUint8List();

      await ImageGallerySaver.saveImage(
        (imageData?.buffer.asUint8List(
          imageData.offsetInBytes,
          imageData.lengthInBytes,
        ))!,
        quality: 100,
      );

      if (context.mounted) Toast(context: context, message: '기기 저장소에 저장된 이미지');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1515),
        toolbarHeight: 40,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
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
            child: RepaintBoundary(
              key: _canvasKey,
              child: Stack(
                children: [
                  Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (details) => _handlePanStart(
                        (context.findRenderObject() as RenderBox)
                            .globalToLocal(details.globalPosition),
                      ),
                      onPanEnd: (details) => _dragging = false,
                      onPanUpdate: (details) {
                        if (_dragging) {
                          _currentShader!.startOffset = Offset(
                            _currentShader!.startOffset.dx + details.delta.dx,
                            _currentShader!.startOffset.dy + details.delta.dy,
                          );
                          setState(() {});
                        }
                      },
                      child: CustomPaint(
                        painter: CanvasPainter(
                          shapes: _shaders,
                          painterColor: const Color(0x8001FF0B),
                        ),
                        child: const SizedBox(
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: const Color(0xFF1A1515),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(),
                const SizedBox(
                  height: 24,
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageIcon(
                        AssetImage(
                          'assets/icons/back_icon.png',
                        ),
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        '다시찍기',
                        style: TextStyle(
                          fontFamily: 'inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasMultipleFaces) ...[
                  const SizedBox(
                    height: 24,
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          isImageEdited = true;
                          if (_shaders
                              .where((element) =>
                                  element.shapeType == ShapeType.eye)
                              .isEmpty) {
                            _currentShader = ShapeItem(
                              const Size(40, 25),
                              null,
                              const Offset(30, 30),
                              ShapeType.eye,
                            );
                            _shaders.addAll([
                              _currentShader!,
                              ShapeItem(
                                const Size(40, 25),
                                null,
                                const Offset(90, 30),
                                ShapeType.eye,
                              )
                            ]);
                          }
                          setState(() {});
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              '눈',
                              style: TextStyle(
                                fontFamily: 'inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      InkWell(
                        onTap: () {
                          isImageEdited = true;
                          if (!_shaders.any((element) =>
                              element.shapeType == ShapeType.mouth)) {
                            _currentShader = ShapeItem(
                              const Size(80, 40),
                              null,
                              const Offset(40, 40),
                              ShapeType.mouth,
                            );
                            _shaders.add(
                              _currentShader!,
                            );
                          }

                          setState(() {});
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Center(
                            child: Text(
                              '입',
                              style: TextStyle(
                                fontFamily: 'inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 58,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        isImageEdited
                            ? const Color(0xFF7B8FF7)
                            : const Color(0xFFD3D3D3),
                      ),
                      minimumSize: MaterialStateProperty.all(
                        Size(MediaQuery.sizeOf(context).width, 40),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () => _downloadEditedImage(context),
                    child: const Text(
                      '저장하기',
                      style: TextStyle(
                        fontFamily: 'inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                ] else
                  const SizedBox(
                    height: 206,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
