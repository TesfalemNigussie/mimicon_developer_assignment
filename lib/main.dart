import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'screen/camera_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MaterialApp(
      home: CameraScreen(),
    ),
  );
}
