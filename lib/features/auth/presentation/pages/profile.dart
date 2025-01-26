
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';

import 'package:rakhsa/shared/basewidgets/button/custom.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/update_profile_notifier.dart';
import 'package:rakhsa/features/media/presentation/provider/upload_media_notifier.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {

  bool btnUpdateProfileLoading = false;

  late ProfileNotifier profileNotifier;
  late UpdateProfileNotifier updateProfileNotifier;
  late UploadMediaNotifier uploadMediaNotifier;

  ImageSource? imageSource;
  File? selectedFile;

  Future<void> chooseFile() async {
    imageSource = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Sumber Gambar",
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            fontWeight: FontWeight.bold,
            color: ColorResources.black
          ),
        ),
        actions: [
          MaterialButton(
            child: Text("Kamera",
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: ColorResources.black
              )
            ),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          MaterialButton(
            child: Text("Galeri",
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: ColorResources.black
              ),
            ),
            onPressed: () => Navigator.pop(context, ImageSource.gallery)
          )
        ],
      )
    );
    if (imageSource != null) {

      if (imageSource == ImageSource.gallery) {
        XFile? pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );

        File? cropped = await ImageCropper().cropImage(
          sourcePath: pickedFile!.path,
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: "Crop It",
            toolbarColor: Colors.blueGrey[900],
            toolbarWidgetColor: ColorResources.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false
          ),
        );

        if (cropped != null) {
          setState(() => selectedFile = cropped);
        } else {
          setState(() => selectedFile = null);
        }

      } else {
       
        XFile? pickedFile = await ImagePicker().pickImage(
          source: ImageSource.camera,
        );

        File? cropped = await ImageCropper().cropImage(
          sourcePath: pickedFile!.path,
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: "Crop It",
            toolbarColor: Colors.blueGrey[900],
            toolbarWidgetColor: ColorResources.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false
          ),
          iosUiSettings: const IOSUiSettings(
            minimumAspectRatio: 1.0,
          )
        );
        
        if (cropped != null) {
          setState(() => selectedFile = cropped);
        } else {
          setState(() => selectedFile = null);
        }

      }
    }
  }

  Future<void> getData() async {
    if(!mounted) return;
      profileNotifier.getProfile();
  }

  Future<void> submit() async {
    if(selectedFile == null) {
      ShowSnackbar.snackbarErr("Field avatar is required");
      return;
    }

    await uploadMediaNotifier.send(
      file: selectedFile!, 
      folderName: "avatar-raksha"
    );

    await updateProfileNotifier.updateProfile(avatar: uploadMediaNotifier.entity!.path);

    if(updateProfileNotifier.message == "") {
      ShowSnackbar.snackbarOk("Update Profile Success");
    }

    Future.delayed(Duration.zero, () {
      Navigator.pop(context);
    });

    profileNotifier.getProfile();
  }

  @override 
  void initState() {
    super.initState();

    profileNotifier = context.read<ProfileNotifier>();
    updateProfileNotifier = context.read<UpdateProfileNotifier>();
    uploadMediaNotifier = context.read<UploadMediaNotifier>();
    
    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.backgroundColor,
      bottomNavigationBar: selectedFile != null 
      ? Container(
          margin: const EdgeInsets.only(
            top: 20.0,
            bottom: 20.0,
            left: 10.0,
            right: 10.0
          ),
          child: CustomButton(
            onTap: submit,
            isBorder: false,
            isBorderRadius: true,
            btnColor: const Color(0xFFFE1717),
            btnTxt: "Update Profile",
          ),
        ) 
      : const SizedBox(),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.sync(() {
            getData();
          });
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
        
            SliverAppBar(
              backgroundColor: ColorResources.backgroundColor,
              centerTitle: true,
              title: Text("Profile",
                style: robotoRegular.copyWith(
                  color: ColorResources.black,
                  fontSize: Dimensions.fontSizeLarge,
                  fontWeight: FontWeight.bold
                ),
              ),
              leading: CupertinoNavigationBarBackButton(
                color: ColorResources.black,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            if(context.watch<ProfileNotifier>().state == ProviderState.loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFFFE1717)),
                    ),
                  )
                )
              ),

            if(context.watch<ProfileNotifier>().state == ProviderState.error)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(context.read<ProfileNotifier>().message,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: ColorResources.black
                    ),
                  )
                )
              ),

            if(context.watch<ProfileNotifier>().state == ProviderState.loaded)
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: 16.0, 
                  right: 16.0,
                  bottom: 20.0
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Container(
                        margin: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          top: 20.0,
                          bottom: 20.0
                        ),
                        child: Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                          
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5), 
                                      spreadRadius: 3, 
                                      blurRadius: 4, 
                                      offset: const Offset(0, 0.2), 
                                    ),
                                  ],
                                ),
                                child: selectedFile != null 
                                ? CircleAvatar(
                                    radius: 40.0,
                                    backgroundColor: ColorResources.white,
                                    backgroundImage: FileImage(
                                      selectedFile!,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: profileNotifier.entity.data!.avatar.toString(),
                                    imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                      return CircleAvatar(
                                        radius: 40.0,
                                        backgroundColor: ColorResources.white,
                                        backgroundImage: imageProvider,
                                      );
                                    },
                                    errorWidget: (BuildContext context, String url, Object error) {
                                      return const CircleAvatar(
                                        radius: 40.0,
                                        backgroundColor: ColorResources.white,
                                        backgroundImage: AssetImage('assets/images/default.jpeg'),
                                      ); 
                                    },
                                    placeholder: (BuildContext context, String url) {
                                      return const CircleAvatar(
                                        radius: 40.0,
                                        backgroundColor: ColorResources.white,
                                        backgroundImage: AssetImage('assets/images/default.jpeg'),
                                      );
                                    },
                                  )
                              ),

                              Positioned(
                                right: 0.0,
                                bottom: 0.0,
                                child: CircleAvatar(
                                  backgroundColor: ColorResources.white,
                                  maxRadius: 12.0,
                                  child: InkWell(
                                    onTap: chooseFile,
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 14.0,
                                      color: ColorResources.black,
                                    ),
                                  ),
                                ),
                              )
                          
                            ],
                          ),
                        ) 
                      ),

                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                          color: ColorResources.white
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                
                                Expanded(
                                  child: Text("Nama",
                                    style: robotoRegular.copyWith(
                                      color: ColorResources.grey,
                                      fontSize: Dimensions.fontSizeDefault
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 3,
                                  child: Text(profileNotifier.entity.data!.username.toString(),
                                    style: robotoRegular.copyWith(
                                      color: ColorResources.black,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                )
                
                              ],
                            ), 
                      
                            const SizedBox(height: 8.0),
                      
                            const Divider(
                              thickness: 0.5,
                              color: ColorResources.hintColor
                            ),
                
                            const SizedBox(height: 8.0),
                
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                
                                Expanded(
                                  child: Text("E-mail",
                                    style: robotoRegular.copyWith(
                                      color: ColorResources.grey,
                                      fontSize: Dimensions.fontSizeDefault
                                    ),
                                  ),
                                ),
                
                                Expanded(
                                  flex: 3,
                                  child: Text(profileNotifier.entity.data!.email.toString(),
                                    style: robotoRegular.copyWith(
                                      color: ColorResources.black,
                                      fontSize: Dimensions.fontSizeDefault,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                )
                
                              ],
                            ), 
                            
                            const SizedBox(height: 8.0),
                      
                            const Divider(
                              thickness: 0.5,
                              color: ColorResources.hintColor
                            ),
                
                            const SizedBox(height: 8.0),
                
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                
                                Expanded(
                                  child: Text("No Tlp",
                                    style: robotoRegular.copyWith(
                                      color: ColorResources.grey,
                                      fontSize: Dimensions.fontSizeDefault
                                    ),
                                  ),
                                ),
                
                                Expanded(
                                  flex: 3,
                                  child: Text(profileNotifier.entity.data!.contact.toString(),
                                    style: robotoRegular.copyWith(
                                      color: ColorResources.black,
                                      fontSize: Dimensions.fontSizeDefault,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                )
                
                              ],
                            ), 
                
                          ],
                        )
                      ),
                      
                      const SizedBox(height: 10.0),

                      fieldProfile(
                        title: "Kontak darurat", 
                        desc: profileNotifier.entity.data!.emergencyContact.toString()
                      ),

                      fieldProfile(
                        title: "Gender", 
                        desc: profileNotifier.entity.data!.gender.toString()
                      ),

                      fieldProfile(
                        title: "Passport Expired", 
                        desc: profileNotifier.entity.data!.passportExpired.toString()
                      ),

                      fieldProfile(
                        title: "Passport Issued", 
                        desc: profileNotifier.entity.data!.passportIssued.toString()
                      ),

                      fieldProfile(
                        title: "No Reg", 
                        desc: profileNotifier.entity.data!.noReg.toString()
                      ),

                      fieldProfile(
                        title: "MRZ Code", 
                        desc: profileNotifier.entity.data!.mrzCode.toString()
                      ),

                      fieldProfile(
                        title: "Issuing Authority", 
                        desc: profileNotifier.entity.data!.issuingAuthority.toString()
                      ),

                      fieldProfile(
                        title: "Citizen", 
                        desc: profileNotifier.entity.data!.citizen.toString()
                      ),
                      
                      fieldProfile(
                        title: "Citizen", 
                        desc: profileNotifier.entity.data!.codeCountry.toString()
                      ),

                      fieldProfile(
                        title: "Birthdate", 
                        desc: profileNotifier.entity.data!.birthdate.toString()
                      ),
                      
                      fieldProfile(
                        title: "Birthplace", 
                        desc: profileNotifier.entity.data!.birthplace.toString()
                      ),

                    ],
                  )
                )
              ),
        
          ],
        ),
      ),
    );
  }

  Widget fieldProfile({required String title, required String desc}) {
    return  Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
        color: ColorResources.white
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [

              Expanded(
                flex: 2,
                child: Text(title,
                  style: robotoRegular.copyWith(
                    color: ColorResources.grey,
                    fontSize: Dimensions.fontSizeDefault
                  ),
                ),
              ),

              Expanded(
                flex: 3,
                child: Text(desc,
                  style: robotoRegular.copyWith(
                    color: ColorResources.black,
                    fontWeight: FontWeight.bold
                  ),
                ),
              )

            ],
          ), 

        ],
      )
    );
  }
}