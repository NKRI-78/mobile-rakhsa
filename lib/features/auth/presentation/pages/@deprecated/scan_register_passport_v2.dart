// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// import 'package:image/image.dart' as img;

// import 'package:rakhsa/helper/image.dart';
// import 'package:rakhsa/ML/Recognition.dart';
// import 'package:rakhsa/ML/Recognizer.dart';
// import 'package:rakhsa/main.dart';

// class BlinkDetector {
//   final double leftEyeThreshold;
//   final double rightEyeThreshold;
//   int blinkCount = 0;
//   final int requiredBlinks;
//   bool isSuccess = false;

//   BlinkDetector({
//     this.leftEyeThreshold = 0.25,
//     this.rightEyeThreshold = 0.25,
//     this.requiredBlinks = 2,
//   });

  // void detectBlink(Face face) {
  //   if (face.leftEyeOpenProbability != null && face.rightEyeOpenProbability != null) {

  //     final leftEyeOpen = face.leftEyeOpenProbability! > leftEyeThreshold;
  //     final rightEyeOpen = face.rightEyeOpenProbability! > rightEyeThreshold;

  //     bool isBlinking = !leftEyeOpen && !rightEyeOpen;

  //     if (isBlinking) {
  //       blinkCount++;
  //       debugPrint("Blink detected! Count: $blinkCount");

  //       if (blinkCount >= requiredBlinks) {
  //         isSuccess = true;
  //         Future.delayed(const Duration(seconds: 2), () {
  //           isSuccess = false;
  //           blinkCount = 0;
  //         });
  //         debugPrint("Success! Blink detected twice.");
  //       }
  //     }
  //   }
  // }
// }

// class RegisterFrV2Page extends StatefulWidget {
//   const RegisterFrV2Page({super.key});

//   @override
//   RegisterFrV2PageState createState() => RegisterFrV2PageState();
// }

// class RegisterFrV2PageState extends State<RegisterFrV2Page> {
//   CameraImage? frame;
//   bool isBusy = false;
//   int frameSkip = 10;
//   int frameCounter = 0;
//   int blinkCount = 0;
//   bool isBlinking = false;
//   bool livenessPassed = false;

//   BlinkDetector blinkDetector = BlinkDetector(
//     requiredBlinks: 1,
//     leftEyeThreshold: 0.5,
//     rightEyeThreshold: 0.5,
//   );

//   CameraLensDirection camDirec = CameraLensDirection.front;

//   late CameraController controller;
//   // late FaceDetector faceDetector;
//   late CameraDescription description = cameras[1];
//   late Recognizer recognizer;

//   double calculateDistance(List<double> embedding1, List<double> embedding2) {
//     if (embedding1.length != embedding2.length) return double.infinity;

//     double sum = 0;
//     for (int i = 0; i < embedding1.length; i++) {
//       sum += (embedding1[i] - embedding2[i]) * (embedding1[i] - embedding2[i]);
//     }
//     return sqrt(sum);
//   }

//   String? findMatchingUser(
//     List<double> newEmbedding,
//     Map<String, List<double>> savedEmbeddings,
//   ) {
//     double threshold = 0.3;
//     String? bestMatch;
//     double minDistance = double.infinity;

//     for (var entry in savedEmbeddings.entries) {
//       double distance = calculateDistance(newEmbedding, entry.value);
//       if (distance < threshold && distance < minDistance) {
//         minDistance = distance;
//         bestMatch = entry.key;
//       }
//     }

//     return bestMatch;
//   }

//   void showLivenessSuccess() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Liveness Check Passed"),
//         content: const Text("You blinked! You are a real person."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> initializeCamera() async {
//     controller = CameraController(
//       description,
//       ResolutionPreset.medium,
//       imageFormatGroup: Platform.isAndroid
//           ? ImageFormatGroup.nv21
//           : ImageFormatGroup.bgra8888,
//       enableAudio: false,
//     );

//     await controller.initialize();
//     setState(() {});

//     controller.startImageStream((image) {
//       if (!isBusy && frameCounter % frameSkip == 0) {
//         isBusy = true;
//         frame = image;
        // doFaceDetectionOnFrame();
  //     }
  //     frameCounter++;
  //   });
  // }

  // Future<void> doFaceDetectionOnFrame() async {
  //   InputImage? inputImage = ImageHelper.getInputImage(controller, camDirec, cameras, frame!);
  //   if (inputImage == null) return;

  //   List<Face> faces = await faceDetector.processImage(inputImage);

  //   await performRecognition(faces);
  // }

  // Future<void> saveEmbedding(String userId, List<double> embedding) async {
  //   try {
  //     const directoryDownload = '/storage/emulated/0/Download';
  //     final targetDirectory = Directory('$directoryDownload/Embeddings');

  //     if (!await targetDirectory.exists()) {
  //       await targetDirectory.create(recursive: true);
  //     }

  //     final file = File('${targetDirectory.path}/marlinda.json');

  //     Map<String, dynamic> embeddingsData = {};

  //     if (await file.exists()) {
  //       String jsonString = await file.readAsString();
  //       embeddingsData = jsonDecode(jsonString);
  //     }

  //     embeddingsData[userId] = embedding;

  //     await file.writeAsString(
  //       jsonEncode(embeddingsData),
  //       mode: FileMode.write,
  //     );
  //     debugPrint("✅ Embedding saved successfully at: ${file.path}");
  //   } catch (e) {
  //     debugPrint("❌ Error saving JSON: $e");
  //   }
  // }

  // Future<Map<String, List<double>>> loadEmbeddings() async {
  //   try {
  //     const directoryDownload = '/storage/emulated/0/Download';
  //     final file = File('$directoryDownload/Embeddings/marlinda.json');

  //     if (!await file.exists()) {
  //       debugPrint("❌ No saved embeddings found.");
  //       return {};
  //     }

  //     String jsonString = await file.readAsString();
  //     Map<String, dynamic> jsonData = jsonDecode(jsonString);

  //     return jsonData.map(
  //       (key, value) => MapEntry(key, List<double>.from(value)),
  //     );
  //   } catch (e) {
  //     debugPrint("❌ Error loading embeddings: $e");
  //     return {};
  //   }
  // }

  // Future<void> performRecognition(List<Face> faces) async {
  //   if (faces.isEmpty) {
  //     isBusy = false;
  //     return;
  //   }

  //   img.Image baseImage = ImageHelper.processCameraFrame(frame, camDirec);
  //   Map<String, List<double>> savedEmbeddings = await loadEmbeddings();

  //   for (Face face in faces) {
  //     if (!blinkDetector.isSuccess) {
  //       blinkDetector.detectBlink(face);
  //     } else {
  //       // showLivenessSuccess();
  //       // Recognition recognition = await processFaceRecognition(baseImage, face);

  //       showLivenessSuccess();
  //       Recognition recognition = await processFaceRecognition(baseImage, face);
  //       List<double> newEmbedding = recognition.embeddings.toList();

  //       // Compare with stored embeddings
  //       String? matchedUser = findMatchingUser(newEmbedding, savedEmbeddings);

  //       if (matchedUser != null) {
  //         debugPrint("✅ Login Successful: $matchedUser");
  //       } else {
  //         await saveEmbedding("user_id_2", recognition.embeddings.toList());
  //       }
  //     }
  //   }

  //   if (mounted) {
  //     setState(() {
  //       isBusy = false;
  //     });
  //   }
  // }

  // Future<Recognition> processFaceRecognition(img.Image image, Face face) async {
  //   Rect faceRect = face.boundingBox;

  //   img.Image croppedFace = img.copyCrop(
  //     image,
  //     x: faceRect.left.toInt(),
  //     y: faceRect.top.toInt(),
  //     width: faceRect.width.toInt(),
  //     height: faceRect.height.toInt()
  //   );

  //   Recognition recognition = recognizer.recognize(croppedFace, faceRect);

  //   if (recognition.distance > 0.3) {
  //     recognition.name = "Not Registered";
  //   } else {
  //     debugPrint("already registered");
  //   }

  //   return recognition;
  // }

  // @override
  // void initState() {
  //   super.initState();

    // faceDetector = FaceDetector(
    //   options: FaceDetectorOptions(
    //     enableLandmarks: false,
    //     enableTracking: true,
    //     enableContours: true,
    //     enableClassification: true,
    //     performanceMode: FaceDetectorMode.accurate,
    //   ),
    // );

//     recognizer = Recognizer();

//     initializeCamera();
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     // faceDetector.close();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Liveness Detection")),
//       body: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Expanded(
//             child: controller.value.isInitialized
//                 ? CameraPreview(controller)
//                 : const Center(child: CircularProgressIndicator()),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 const Text(
//                   "Blink to verify liveness",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 if (livenessPassed)
//                   const Icon(Icons.check_circle, color: Colors.green, size: 40),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
