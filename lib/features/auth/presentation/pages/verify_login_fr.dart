import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

import 'package:rakhsa/Helper/Image.dart';

import 'package:rakhsa/ML/Recognition.dart';
import 'package:rakhsa/ML/Recognizer.dart';

import 'package:rakhsa/Painter/face_detector.dart';

import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/dashboard_notifier.dart';

import 'package:rakhsa/main.dart';

class VerifyLoginFr extends StatefulWidget {
  const VerifyLoginFr({super.key});

  @override
  State<VerifyLoginFr> createState() => VerifyLoginFrState();
}

class VerifyLoginFrState extends State<VerifyLoginFr> {

  late CameraController controller;
  late DashboardNotifier dashboardNotifier;

  bool isDialogCameraShowing = false;

  String text = "Please scan your face to login";

  bool isBusy = false;

  img.Image? image;
  
  List<Recognition> scanResults = [];
  CameraImage? frame;

  int frameSkip = 30;
  int frameCounter = 0;

  CameraLensDirection camDirec = CameraLensDirection.front;

  late Size size;
  late CameraDescription description = cameras[1];
  late List<Recognition> recognitions = [];
  late FaceDetector faceDetector;
  late Recognizer recognizer;

  Future<void> initializeCamera() async {
    controller = CameraController(
      description,
      ResolutionPreset.medium,
      imageFormatGroup: Platform.isAndroid
    ? ImageFormatGroup.nv21 
    : ImageFormatGroup.bgra8888, 
      enableAudio: false
    ); 

    await controller.initialize();
      
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
    
    await performFaceRecognition(faces);
  }

  Future<void> performFaceRecognition(List<Face> faces) async {
    if (frame == null) return;

    img.Image baseImage = ImageHelper.processCameraFrame(frame, camDirec);

    recognitions = [];

    for (Face face in faces) {
      Recognition recognition = await processFaceRecognition(baseImage, face);

      recognitions.add(recognition);
    }

    if(recognitions.isEmpty) {
      setState(() {
        text = "Please scan your face to login";
      });
    }

    if (mounted) {
      setState(() {
        isBusy = false;
        scanResults = recognitions;
      });
    }
  }

  Future<Recognition> processFaceRecognition(img.Image image, Face face) async {
    Rect faceRect = face.boundingBox;

    img.Image croppedFace = img.copyCrop(
      image,
      x: faceRect.left.toInt(),
      y: faceRect.top.toInt(),
      width: faceRect.width.toInt(),
      height: faceRect.height.toInt()
    );

    Recognition recognition = recognizer.recognize(croppedFace, faceRect);

    if (recognition.distance > 0.3) {
      recognition.name = "Not Registered";
      setState(() => text = "Not Registered");
    } else {

      String? userId = StorageHelper.getUserId();

      try {
        Dio dio = Dio();
        Response res = await dio.post("https://api-rakhsa.inovatiftujuh8.com/api/v1/auth/login-member-fr", 
          data: {
            "user_id": userId.toString(),
          }
        );

        Map<String, dynamic> data = res.data;
        AuthModel authModel = AuthModel.fromJson(data);
        
        StorageHelper.saveUserId(userId: authModel.data?.user.id ?? "-");
        StorageHelper.saveUserEmail(email: authModel.data?.user.email ?? "-");
        StorageHelper.saveUserPhone(phone: authModel.data?.user.phone ?? "-");
        
        StorageHelper.saveToken(token: authModel.data?.token ?? "-");

        StorageHelper.setIsLocked(val: false);
        
        dashboardNotifier.setStateIsLocked(val: false);
         
      } on DioException catch(e) {
        if(e.response!.statusCode == 400) {
          String message = e.response!.data["message"];
          ShowSnackbar.snackbarErr(message);

          Future.delayed(Duration.zero, () {
            Navigator.pop(context);
          });
        }
      } catch(e) {
        debugPrint(e.toString());
      }
    }

    return recognition;
  }

  void toggleCameraDirection() async {

    if (camDirec == CameraLensDirection.back) {
      camDirec = CameraLensDirection.front;
      description = cameras[1];
    } else {
      camDirec = CameraLensDirection.back;
      description = cameras[0];
    }
    await controller.stopImageStream();

    setState(() => controller);

    initializeCamera();
  }

  Widget buildResult() {
    if (!controller.value.isInitialized) {
      return const SizedBox();
    }

    final Size imageSize = Size(
      controller.value.previewSize!.height,
      controller.value.previewSize!.width,
    );
    
    CustomPainter painter = FaceDetectorPainter(imageSize, scanResults, camDirec);
    
    return CustomPaint(painter: painter);
  }
  
  @override
  void initState() {
    super.initState();

    dashboardNotifier = context.read<DashboardNotifier>();

    var options = FaceDetectorOptions(
      enableLandmarks: false,
      enableContours: true,
      enableTracking: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate
    );
    
    faceDetector = FaceDetector(options: options);
    
    recognizer = Recognizer();
    
    initializeCamera();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> stackChildren = [];
    
    size = MediaQuery.of(context).size;

    if (!controller.value.isInitialized) {
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: Container(
          child: (controller.value.isInitialized)
          ? AspectRatio(
              aspectRatio: 16 / 9,
              child: CameraPreview(controller),
            )
          : const SizedBox(),
          ),
        ),
      );

      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: buildResult()
        ),
      );
    }

  return SafeArea(
    child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
      ), 
      body: Container(
        color: Colors.black,
        child: Stack(
          clipBehavior: Clip.none,
          children: [

            Positioned(
              top: 0.0,
              left: 0.0,
              width: size.width,
              height: size.height,
              child: (controller.value.isInitialized)
              ? Align(
                  alignment: Alignment.topCenter,
                  child: ClipOval(
                    child: SizedBox(
                      width: size.width * 0.8, 
                      height: size.width * 0.8, 
                      child: OverflowBox(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            height: 1,
                            child: AspectRatio(
                              aspectRatio: 1 / controller.value.aspectRatio,
                              child: CameraPreview(controller),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
            ),

            Positioned(
              top: 0.0,
              left: 0.0,
              width: size.width,
              height: size.height,
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: size.width * 0.8, 
                  height: size.width * 0.8, 
                  child: buildResult()
                )
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).size.height * 0.5,
              left: 0.0,
              right: 0.0,
              child: Center(
                child: Text(text,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
              )
            ), 

          ],
        ),
      ),
    ));

  }
}