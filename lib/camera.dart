import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:camera/camera.dart';

import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/media/presentation/provider/upload_media_notifier.dart';
import 'package:rakhsa/socketio.dart';

class CameraPage extends StatefulWidget {
  final String location;
  final String country;
  final String lat;
  final String lng;
  
  const CameraPage({
    required this.location,
    required this.country,
    required this.lat,
    required this.lng,
    super.key
  });

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  CameraController? controller;
  List<CameraDescription>? cameras;

  late SocketIoService socketIoService;
  late UploadMediaNotifier uploadMediaNotifier;

  bool loading = false;

  bool isRecording = false;
  bool isVideoMode = false;  

  int recordTimeLeft = 10; 

  @override
  void initState() {
    super.initState();

    socketIoService = context.read<SocketIoService>();
    uploadMediaNotifier = context.read<UploadMediaNotifier>();

    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    
    if (cameras != null && cameras!.isNotEmpty) {
      controller = CameraController(cameras![0], ResolutionPreset.high);
      await controller!.initialize();

      startVideoRecording();
      setState(() {});
    }
  }

  void toggleMode() {
    setState(() => isVideoMode = !isVideoMode);
  }

  Future<void> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) return;
    try {
      final image = await controller!.takePicture();
      File file = File(image.path);

      setState(() => loading = true);

      await uploadMediaNotifier.send(file: file, folderName: "pictures");

      if(uploadMediaNotifier.message != "") {
        GeneralModal.info(msg: uploadMediaNotifier.message);
        return;
      }

      setState(() => loading = false);

      String media = uploadMediaNotifier.entity!.path;
      String ext = media.split('/').last.split('.').last;

      socketIoService.sos(
        location: widget.location,
        country: widget.country, 
        media: media,
        ext: ext,
        lat: widget.lat, 
        lng: widget.lng, 
      );
      
      if(mounted) {
        Navigator.pop(context, "start");
      }

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
          if(mounted) {
            setState(() {
              recordTimeLeft--;
            });
          }
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
      File file = File(video.path);

      setState(() => loading = true);
      
      await uploadMediaNotifier.send(file: file, folderName: "videos");

      setState(() => loading = false);

      String media = uploadMediaNotifier.entity!.path;
      String ext = media.split('/').last.split('.').last;
      
      socketIoService.sos(
        location: widget.location,
        country: widget.country,
        media: media,
        ext: ext,
        lat: widget.lat, 
        lng: widget.lng, 
      );

      if(mounted) {
        Navigator.pop(context, "start");
      }

      setState(() => isRecording = false);
    } catch (e) {
      debugPrint('Error stopping video recording: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      progressIndicator: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: ColorResources.white,
          borderRadius: BorderRadius.circular(50.0)
        ),
        child: const CircularProgressIndicator()
      ),
      child: Scaffold(
        body: controller == null || !controller!.value.isInitialized
        ? const Center(
            child: CircularProgressIndicator()
          )
        : Stack(
          clipBehavior: Clip.none,
          children: [
      
            CameraPreview(controller!),
      
            Positioned(
              bottom: 20,
              left: 0.0,
              right: 0.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
      
                  // isVideoMode 
                  // ? IconButton(
                  //     icon: Icon(
                  //     isRecording 
                  //     ? Icons.stop 
                  //     : Icons.fiber_manual_record,
                  //       color: Colors.red,
                  //       size: 30,
                  //     ),
                  //     onPressed: isVideoMode
                  //     ? (isRecording ? stopVideoRecording : startVideoRecording)
                  //     : null,
                  //   ) 
                  // : 

                  // isRecording 
                  // ? const SizedBox() 
                  // : IconButton(
                  //     icon: const Icon(
                  //       Icons.camera_alt,
                  //       color: Colors.white,
                  //       size: 28,
                  //     ),
                  //     onPressed: takePicture,
                  //   ),

                  // const SizedBox(width: 20.0),

                  IconButton(
                    icon: const Icon(Icons.videocam,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: (isRecording ? stopVideoRecording : startVideoRecording),
                  ),
      
                  if (isRecording)
                    Text('$recordTimeLeft s',
                      style: robotoRegular.copyWith(
                        color: Colors.white, 
                        fontSize: Dimensions.fontSizeLarge
                      ),
                    ),

                ],
              ),
            ),
      
            // Positioned(
            //   top: 50,
            //   right: 20,
            //   child: IconButton(
            //     icon: Icon(
            //       isVideoMode ? Icons.camera : Icons.videocam,
            //       color: Colors.white,
            //       size: 30,
            //     ),
            //     onPressed: toggleMode,
            //   ),
            // ),
      
            // Positioned(
            //   top: 50,
            //   left: 20,
            //   child: Text(
            //     isVideoMode ? "Video Mode" : "Photo Mode",
            //     style: robotoRegular.copyWith(
            //       color: Colors.white,
            //       fontSize: 18,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
      
          ],
        ),
      ),
    );
  }
}
