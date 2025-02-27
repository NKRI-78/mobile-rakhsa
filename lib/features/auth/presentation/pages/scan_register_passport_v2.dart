import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:rakhsa/Helper/image.dart';
import 'package:rakhsa/main.dart';

class BlinkDetector {
  final double leftEyeThreshold;
  final double rightEyeThreshold;
  int blinkCount = 0;
  final int requiredBlinks;
  bool isSuccess = false;

  BlinkDetector({
    this.leftEyeThreshold = 0.25, 
    this.rightEyeThreshold = 0.25,
    this.requiredBlinks = 2
  });

  void detectBlink(Face face) {
    if (face.leftEyeOpenProbability != null && face.rightEyeOpenProbability != null) {
      
      bool isBlinking = (face.leftEyeOpenProbability! < leftEyeThreshold) && (face.rightEyeOpenProbability! < rightEyeThreshold);
      
      if (isBlinking) {
        blinkCount++;
        debugPrint("Blink detected! Count: $blinkCount");
        
        if (blinkCount >= requiredBlinks) {
          isSuccess = true;
          Future.delayed(const Duration(seconds: 2), () {
            isSuccess = false;
            blinkCount = 0;
          });
          debugPrint("Success! Blink detected twice.");
        }
      }
    }
  }
}

class RegisterFrV2Page extends StatefulWidget {
  const RegisterFrV2Page({super.key});

  @override
  RegisterFrV2PageState createState() => RegisterFrV2PageState();
}

class RegisterFrV2PageState extends State<RegisterFrV2Page> {
  CameraImage? frame;
  bool isBusy = false;
  int frameSkip = 10;
  int frameCounter = 0;
  int blinkCount = 0;
  bool isBlinking = false;
  bool livenessPassed = false;

  BlinkDetector blinkDetector = BlinkDetector(
    requiredBlinks: 1,
    leftEyeThreshold: 14,
    rightEyeThreshold: 0.14,
  );

  CameraLensDirection camDirec = CameraLensDirection.front;

  late CameraController controller;
  late FaceDetector faceDetector;
  late CameraDescription description = cameras[1];
  
  @override
  void initState() {
    super.initState();
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: false,
        enableTracking: true,
        enableContours: true,
        enableClassification: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    controller = CameraController(
      description,
      ResolutionPreset.medium,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      enableAudio: false,
    );

    await controller.initialize();
    setState(() {});

    controller.startImageStream((image) {
      if (!isBusy && frameCounter % frameSkip == 0) {
        isBusy = true;
        frame = image;
        doFaceDetectionOnFrame();
      }
      frameCounter++;
    });
  }

  Future<void> doFaceDetectionOnFrame() async {
    InputImage? inputImage = ImageHelper.getInputImage(controller, camDirec, cameras, frame!);
    if (inputImage == null) return;

    List<Face> faces = await faceDetector.processImage(inputImage);
    checkBlink(faces);
  }

  void checkBlink(List<Face> faces) {
    if (faces.isEmpty) {
      isBusy = false;
      return;
    }

    for (Face face in faces) {
      if (!blinkDetector.isSuccess) {
        blinkDetector.detectBlink(face);
      } else {
        showLivenessSuccess();
      }
    }

    if (mounted) {
      setState(() {
        isBusy = false;
      });
    }
  }
  

  void showLivenessSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Liveness Check Passed"),
        content: const Text("You blinked! You are a real person."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liveness Detection")),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: controller.value.isInitialized
                ? CameraPreview(controller)
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "Blink to verify liveness",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (livenessPassed)
                  const Icon(Icons.check_circle, color: Colors.green, size: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
