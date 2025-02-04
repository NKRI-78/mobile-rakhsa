

import 'dart:io';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:path_provider/path_provider.dart';

import 'package:rakhsa/Painter/face_detector.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/cupertino.dart';

import 'package:image/image.dart' as img;

import 'package:rakhsa/ML/Recognizer.dart';
import 'package:rakhsa/ML/Recognition.dart';

import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';

import 'package:rakhsa/features/auth/data/models/auth.dart';
import 'package:rakhsa/features/auth/data/models/passport.dart';
import 'package:rakhsa/features/media/presentation/provider/upload_media_notifier.dart';

import 'package:rakhsa/global.dart';

import 'package:rakhsa/main.dart';

import 'package:rakhsa/Helper/Image.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

class RegisterFrPage extends StatefulWidget {
  final String userId;
  final String passportPic;
  final Passport passport;

  const RegisterFrPage({
    required this.userId,
    required this.passportPic,
    required this.passport,
    super.key
  });

  @override
  RegisterFrPageState createState() => RegisterFrPageState();
}

class RegisterFrPageState extends State<RegisterFrPage> {

  late UploadMediaNotifier uploadMediaNotifier;

  late CameraController controller;

  String text1 = "Please scan your face to register";
  String text2 = "";

  bool isBusy = false;
  bool btnRegister = false;
  bool register = false;
  bool waitForScanSucceded = true;
  bool alreadyRegistered = false;

  bool saving = false;

  img.Image? image;
  
  List<Recognition> scanResults = [];
  CameraImage? frame;

  int frameSkip = 60;
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

      if (register) {
        showFaceRegistrationDialogue(img.copyCrop(baseImage, 
          x: face.boundingBox.left.toInt(),
          y: face.boundingBox.top.toInt(),
          width: face.boundingBox.width.toInt(),
          height: face.boundingBox.height.toInt()),
          recognition
        );
        register = false;
      }

      recognitions.add(recognition);
    }

    if (mounted) {
      setState(() {
        isBusy = false;
        scanResults = recognitions;
      });
    }
  }

  Future<File> convertImageToFile(img.Image image, String fileName) async {
    Uint8List uint8List = Uint8List.fromList(img.encodePng(image));

    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/$fileName.png';

    File file = File(filePath);
    await file.writeAsBytes(uint8List);

    return file;
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

    if (recognition.distance > 0.6) {
      recognition.name = "Not Registered";

      if(mounted) {
        setState(() {
          text1 = "";
          text2 = "Take your photo to register account";
          alreadyRegistered = false;
          waitForScanSucceded = false;
        });
      }
    } else {
      setState(() {
        text1 = "";
        text2 = "";
        alreadyRegistered = true;
      });
    }

    return recognition;
  }

  void showFaceRegistrationDialogue(
    img.Image croppedFace, 
    Recognition recognition
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
      title: const Text("Face Registration",
        textAlign: TextAlign.center
      ),
      alignment: Alignment.center,
      content: SizedBox(
        height: 500.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            const SizedBox(height: 20.0),

            Image.memory(
              Uint8List.fromList(
                img.encodeBmp(croppedFace)
              ),
            ),

            const SizedBox(height: 20.0),

            StatefulBuilder(
              builder: (BuildContext context, Function s) {
                return ElevatedButton(
                  onPressed: () async {

                    // save to local
                    s(() => btnRegister = true);

                    recognizer.registerFaceInDB(
                      widget.userId,
                      widget.passport.fullName.toString(), 
                      widget.passport.fullName.toString(), 
                      recognition.embeddings
                    );
                  
                    // save to api (on progress)

                    try {
                      
                      Dio dio = Dio();
                      Response res = await dio.post("https://api-rakhsa.inovatiftujuh8.com/api/v1/auth/register-member-fr", 
                        data: {
                          "email": FirebaseAuth.instance.currentUser?.email ?? '-',
                          "user_id": widget.userId,
                          "fullname": widget.passport.fullName.toString(),
                          "passport": widget.passport.passportNumber.toString(),
                          "citizen": widget.passport.nationality.toString(),
                          "birth_date": widget.passport.dateOfBirth.toString(),
                          "birth_place": widget.passport.placeOfBirth.toString(),
                          "gender": widget.passport.gender.toString(),
                          "passport_expired": widget.passport.dateOfExpiry.toString(),
                          "passport_issued": widget.passport.dateOfIssue.toString(),
                          "no_reg": widget.passport.registrationNumber.toString(),
                          "mrz_code": widget.passport.mrzCode.toString(),
                          "issuing_authority": widget.passport.issuingAuthority.toString(),
                          "code_country": widget.passport.countryCode.toString(),
                          "embedding": recognition.embeddings.toString()
                        }
                      );

                      Map<String, dynamic> data = res.data;
                      AuthModel authModel = AuthModel.fromJson(data);
                      
                      StorageHelper.saveUserId(userId: authModel.data?.user.id ?? "-");
                      StorageHelper.saveUserEmail(email: authModel.data?.user.email ?? "-");
                      StorageHelper.saveUserPhone(phone: authModel.data?.user.phone ?? "-");

                      debugPrint("===  USER ID ${StorageHelper.getUserId()} ===");
                      
                      StorageHelper.saveToken(token: authModel.data?.token ?? "-");

                      File fr = await convertImageToFile(croppedFace, "face-recognition");

                      await uploadMediaNotifier.send(file: fr, folderName: "face-recognition");
                      
                      String avatar = uploadMediaNotifier.entity?.path ?? "-";

                      await dio.post("https://api-rakhsa.inovatiftujuh8.com/api/v1/profile/update-passport", 
                        data: {
                          "user_id": widget.userId,
                          "avatar_pic": avatar,
                          "passport_pic": widget.passportPic
                        }
                      );

                      s(() => btnRegister = false);

                      Navigator.pushNamedAndRemoveUntil(navigatorKey.currentContext!,
                        RoutesNavigation.dashboard, (route) => false
                      );
                    } on DioException catch(e) {

                      s(() => btnRegister = false);

                      if(e.response!.statusCode == 400) {
                        Future.delayed(const Duration(seconds: 1), () {
                          String message = e.response!.data["message"];
                          GeneralModal.info(msg: message);
                        });

                        Future.delayed(Duration.zero, () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                      }
                    } catch(e) {
                      debugPrint(e.toString());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:const Color(0xffFE1717),
                    textStyle: const TextStyle(
                      color: Color(0xffFFFFFF)
                    ),
                    minimumSize: const Size(200, 40)
                  ),
                  child: btnRegister 
                  ? const SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    ) 
                  : const Text("Register",
                    style: TextStyle(
                      color: Colors.white
                    ),
                  )
                );
              },
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              }, 
                style: ElevatedButton.styleFrom(
                backgroundColor:const Color(0xFF1796FE),
                textStyle: const TextStyle(
                  color: Color(0xffFFFFFF)
                ),
                minimumSize: const Size(200, 40)
              ),
              child: const Text("Cancel",
                style: TextStyle(
                  color: Colors.white
                ),
              ),
            )

          ],
        ),
      ),
      contentPadding: EdgeInsets.zero,
    ));
  }

  Widget buildResult() {
    if (!controller.value.isInitialized) {
      return const Center(
        child: Text('Camera is not initialized',
          style: TextStyle(
            color: Colors.white
          ),
        )
      );
    }

    final Size imageSize = Size(
      controller.value.previewSize!.height,
      controller.value.previewSize!.width,
    );
    
    CustomPainter painter = FaceDetectorPainter(imageSize, scanResults, camDirec);
    
    return CustomPaint(painter: painter);
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
  
  @override
  void initState() {
    super.initState();

    uploadMediaNotifier = context.read<UploadMediaNotifier>();

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
    controller.dispose();

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
              aspectRatio: controller.value.aspectRatio,
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

    stackChildren.add(Positioned(
      top: size.height - 140,
      left: 0,
      width: size.width,
      height: 80.0,
      child: Card(
        margin: const EdgeInsets.only(
          left: 20.0, 
          right: 20.0
        ),
        color: Colors.white,
        child: Center(
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Photo",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22.0,
                  fontWeight: ui.FontWeight.bold
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.all(1.0),
                decoration: BoxDecoration(
                  color: const Color(0xff211F1F).withOpacity(0.2),
                  shape: BoxShape.circle
                ),
                child: IconButton(
                  highlightColor: const Color(0xff211F1F),
                  icon: const Icon(
                    Icons.circle,
                  ),
                  iconSize: 50.0,
                  onPressed: () {
                    setState(() => register = true);
                  },
                ),
              ),
            ],
          ),
        ),
      )),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          forceMaterialTransparency: true,
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: saving,
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
                    
              // for scanning image
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      text1.isEmpty 
                      ? const SizedBox() 
                      : Text(text1,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                      Text(text2,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      )
                    ],
                  ) 
                )
              ), 
                    
              Positioned(
                left: 0.0,
                bottom: 0.0,
                width: size.width,
                height: 180.0,
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    
                        const Text("Photo",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22.0,
                            fontWeight: ui.FontWeight.bold
                          ),
                        ),
                    
                        const SizedBox(height: 10.0),
                    
                        register 
                        ? const Center(
                            child: SizedBox(
                              width: 15.0,
                              height: 15.0,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Color(0xFFFE1717)),
                              )
                            )
                          ) 
                        :  Container(
                          padding: const EdgeInsets.all(1.0),
                          decoration: BoxDecoration(
                            color: alreadyRegistered 
                            ? Colors.grey.withOpacity(0.2)
                            : waitForScanSucceded 
                            ? Colors.grey.withOpacity(0.2) 
                            : const Color(0xff211F1F).withOpacity(0.2),
                            shape: BoxShape.circle
                          ),
                          child: IconButton(
                            highlightColor: alreadyRegistered 
                            ? Colors.grey.withOpacity(0.2) 
                            : waitForScanSucceded 
                            ? Colors.grey.withOpacity(0.2) 
                            :const Color(0xff211F1F),
                            icon: Icon(
                              Icons.circle,
                              color: alreadyRegistered 
                            ? Colors.grey.withOpacity(0.2)
                            : waitForScanSucceded 
                            ? Colors.grey.withOpacity(0.2)
                            : const Color(0xff211F1F),
                            ),
                            iconSize: 50.0,
                            onPressed: alreadyRegistered 
                            ? () {} 
                            : waitForScanSucceded 
                            ? () {} 
                            : () {
                              setState(() => register = true);
                            },
                          ),
                        ),
                    
                      ],
                    ),
                  ),
                ),
              ),
                    
            ] ,
          ),
        ),
      ),
    );
  }
}