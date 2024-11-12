import 'dart:async';

import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  CameraController? controller;
  List<CameraDescription>? cameras;

  bool isRecording = false;
  bool isVideoMode = false;
  int recordTimeLeft = 10; // 10-second limit

  @override
  void initState() {
    super.initState();

    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      controller = CameraController(cameras![0], ResolutionPreset.high);
      await controller!.initialize();
      setState(() {});
    }
  }

  void toggleMode() {
    setState(() {
      isVideoMode = !isVideoMode;
    });
  }

  Future<void> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) return;
    try {
      final image = await controller!.takePicture();
      debugPrint('Photo saved to ${image.path}');
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> startVideoRecording() async {
    if (controller == null || isRecording) return;

    try {
      await controller!.startVideoRecording();
      setState(() {
        isRecording = true;
        recordTimeLeft = 10;
      });

      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (recordTimeLeft == 0) {
          stopVideoRecording();
          timer.cancel();
        } else {
          setState(() {
            recordTimeLeft--;
          });
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> stopVideoRecording() async {
    if (controller == null || !isRecording) return;

    try {
      final video = await controller!.stopVideoRecording();
      debugPrint('Video recorded to ${video.path}');
      setState(() => isRecording = false);
    } catch (e) {
      debugPrint('Error stopping video recording: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller == null || !controller!.value.isInitialized
        ? Center(child: CircularProgressIndicator())
        : Stack(
        children: [
          CameraPreview(controller!),
          Positioned(
            bottom: 20,
            left: 20,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    color: isVideoMode ? Colors.white : Colors.blueAccent,
                    size: 30,
                  ),
                  onPressed: !isVideoMode ? takePicture : null,
                ),
                IconButton(
                  icon: Icon(
                    isRecording ? Icons.stop : Icons.fiber_manual_record,
                    color: Colors.red,
                    size: 30,
                  ),
                  onPressed: isVideoMode
                      ? (isRecording ? stopVideoRecording : startVideoRecording)
                      : null,
                ),
                if (isRecording)
                  Text(
                    '$recordTimeLeft s',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(
                isVideoMode ? Icons.camera : Icons.videocam,
                color: Colors.white,
                size: 30,
              ),
              onPressed: toggleMode,
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: Text(
              isVideoMode ? "Video Mode" : "Photo Mode",
              style: robotoRegular.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
