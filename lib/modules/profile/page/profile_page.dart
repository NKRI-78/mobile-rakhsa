import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/widgets/avatar.dart';

import 'package:rakhsa/widgets/components/button/custom.dart';

import 'package:rakhsa/misc/helpers/enum.dart';
import 'package:rakhsa/misc/helpers/snackbar.dart';

import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/modules/profile/provider/profile_notifier.dart';
import 'package:rakhsa/modules/media/presentation/provider/upload_media_notifier.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  bool btnUpdateProfileLoading = false;

  late ProfileNotifier profileNotifier;
  // late UpdateProfileNotifier updateProfileNotifier;
  late UploadMediaNotifier uploadMediaNotifier;

  ImageSource? imageSource;
  File? selectedFile;

  Future<void> chooseFile() async {
    imageSource = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Pilih Sumber',
                  style: robotoRegular.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Galeri'),
                leading: const Icon(Icons.photo),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                title: const Text('Kamera'),
                leading: const Icon(Icons.camera),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
    if (imageSource != null) {
      if (imageSource == ImageSource.gallery) {
        // XFile? pickedFile = await ImagePicker().pickImage(
        //   source: ImageSource.gallery,
        // );

        // File? cropped = await ImageCropper().cropImage(
        //   sourcePath: pickedFile!.path,
        //   androidUiSettings: AndroidUiSettings(
        //       toolbarTitle: "Crop It",
        //       toolbarColor: Colors.blueGrey[900],
        //       toolbarWidgetColor: ColorResources.white,
        //       initAspectRatio: CropAspectRatioPreset.original,
        //       lockAspectRatio: false),
        // );

        // if (cropped != null) {
        //   setState(() => selectedFile = cropped);
        // } else {
        //   setState(() => selectedFile = null);
        // }
      } else {
        // XFile? pickedFile = await ImagePicker().pickImage(
        //   source: ImageSource.camera,
        // );

        // File? cropped = await ImageCropper().cropImage(
        //     sourcePath: pickedFile!.path,
        //     androidUiSettings: AndroidUiSettings(
        //         toolbarTitle: "Crop It",
        //         toolbarColor: Colors.blueGrey[900],
        //         toolbarWidgetColor: ColorResources.white,
        //         initAspectRatio: CropAspectRatioPreset.original,
        //         lockAspectRatio: false),
        //     iosUiSettings: const IOSUiSettings(
        //       minimumAspectRatio: 1.0,
        //     ));

        // if (cropped != null) {
        //   setState(() => selectedFile = cropped);
        // } else {
        //   setState(() => selectedFile = null);
        // }
      }
    }
  }

  Future<void> getData() async {
    if (!mounted) return;
    profileNotifier.getProfile();
  }

  Future<void> submit() async {
    if (selectedFile == null) {
      ShowSnackbar.snackbarErr("Field avatar is required");
      return;
    }

    await uploadMediaNotifier.send(
      file: selectedFile!,
      folderName: "avatar-raksha",
    );

    // await updateProfileNotifier.updateProfile(
    //   avatar: uploadMediaNotifier.entity!.path,
    // );

    // if (updateProfileNotifier.message == "") {
    //   ShowSnackbar.snackbarOk("Update Profile Success");
    // }

    Future.delayed(Duration.zero, () {
      if (mounted) Navigator.pop(context);
    });

    profileNotifier.getProfile();
  }

  @override
  void initState() {
    super.initState();

    profileNotifier = context.read<ProfileNotifier>();
    // updateProfileNotifier = context.read<UpdateProfileNotifier>();
    uploadMediaNotifier = context.read<UploadMediaNotifier>();

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? getPeriod(String expiryDateStr) {
      try {
        DateTime now = DateTime.now();
        DateTime expiryDate = DateTime.parse(expiryDateStr);

        if (expiryDate.isBefore(now)) {
          return "Paspor sudah kadaluwarsa";
        }

        final totalDays = expiryDate.difference(now).inDays;
        final years = totalDays ~/ 365;
        final remainingDaysAfterYears = totalDays % 365;
        final months = remainingDaysAfterYears ~/ 30;
        final remainingDaysAfterMonths = remainingDaysAfterYears % 30;
        final weeks = remainingDaysAfterMonths ~/ 7;
        final days = remainingDaysAfterMonths % 7;

        if (years > 0 && months > 0) {
          return "$years tahun $months bulan";
        } else if (years > 0) {
          return "$years tahun";
        } else if (months > 0) {
          return "$months bulan";
        } else if (weeks > 0) {
          return "$weeks minggu";
        } else {
          return "$days hari";
        }
      } catch (_) {
        return null;
      }
    }

    String getGender(String gender) {
      bool male = gender.contains("M") || gender.contains("L");
      bool female = gender.contains("F") || gender.contains("P");
      if (male) {
        return 'Laki-laki';
      } else if (female) {
        return "Perempuan";
      } else {
        return "-";
      }
    }

    return Scaffold(
      backgroundColor: ColorResources.backgroundColor,
      bottomNavigationBar: selectedFile != null
          ? Container(
              margin: const EdgeInsets.only(
                top: 20.0,
                bottom: 20.0,
                left: 10.0,
                right: 10.0,
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
          return Future.sync(() => getData());
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              backgroundColor: ColorResources.backgroundColor,
              centerTitle: true,
              title: Text(
                "Profile",
                style: robotoRegular.copyWith(
                  color: ColorResources.black,
                  fontSize: Dimensions.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: CupertinoNavigationBarBackButton(
                color: ColorResources.black,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (context.watch<ProfileNotifier>().state == ProviderState.loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFFFE1717)),
                    ),
                  ),
                ),
              ),
            if (context.watch<ProfileNotifier>().state == ProviderState.error)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    context.read<ProfileNotifier>().message,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: ColorResources.black,
                    ),
                  ),
                ),
              ),
            if (context.watch<ProfileNotifier>().state == ProviderState.loaded)
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 20.0,
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
                          bottom: 22.0,
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
                                      color: Colors.grey.withValues(alpha: 0.5),
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
                                    : Avatar(
                                        src:
                                            profileNotifier
                                                .entity
                                                .data
                                                ?.avatar ??
                                            "",
                                        initial:
                                            profileNotifier
                                                .entity
                                                .data
                                                ?.username ??
                                            "",
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          profileNotifier.entity.data!.username.toString(),
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: ColorResources.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          profileNotifier.entity.data!.email.toString(),
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            passportField(
                              label: 'Jenis Kelamin',
                              content: getGender(
                                profileNotifier.entity.data!.gender.toString(),
                              ),
                            ),
                            const SizedBox(height: 18),
                            passportField(
                              label: 'Tanggal Lahir',
                              content:
                                  profileNotifier.entity.data?.birthdate == "-"
                                  ? "-"
                                  : DateFormat('dd MMMM yyyy', 'id').format(
                                      DateTime.parse(
                                        profileNotifier.entity.data!.birthdate
                                            .toString(),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 18),
                            passportField(
                              label: 'Tempat Lahir',
                              content: profileNotifier.entity.data!.birthplace
                                  .toString(),
                            ),
                            const SizedBox(height: 18),
                            passportField(
                              label: 'Kewarganegaraan',
                              content: profileNotifier.entity.data!.citizen
                                  .toString(),
                            ),
                            const SizedBox(height: 18),
                            passportField(
                              label: 'Kode Paspor',
                              content: profileNotifier.entity.data!.passport
                                  .toString(),
                            ),
                            const SizedBox(height: 18),
                            passportField(
                              label: 'Tanggal Terbit Paspor',
                              content:
                                  profileNotifier.entity.data?.passportIssued ==
                                      "-"
                                  ? "-"
                                  : DateFormat('dd MMMM yyyy', 'id').format(
                                      DateTime.parse(
                                        profileNotifier
                                            .entity
                                            .data!
                                            .passportIssued
                                            .toString(),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 18),
                            passportField(
                              label: 'Tanggal Kadaluarsa Paspor',
                              content:
                                  profileNotifier
                                          .entity
                                          .data
                                          ?.passportExpired ==
                                      "-"
                                  ? "-"
                                  : DateFormat('dd MMMM yyyy', 'id').format(
                                      DateTime.parse(
                                        profileNotifier
                                            .entity
                                            .data!
                                            .passportExpired
                                            .toString(),
                                      ),
                                    ),
                            ),
                            passportField(
                              label: 'Sisa masa berlaku',
                              content:
                                  getPeriod(
                                    profileNotifier
                                        .entity
                                        .data!
                                        .passportExpired,
                                  ) ??
                                  '-',
                            ),
                            const SizedBox(height: 18),
                            passportField(
                              label: 'Nomor Registrasi',
                              content: profileNotifier.entity.data!.noReg
                                  .toString(),
                            ),
                            const SizedBox(height: 18),
                            passportField(
                              label: 'Kode MRZ',
                              content: profileNotifier.entity.data!.mrzCode
                                  .toString(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget passportField({required String label, required String content}) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: robotoRegular.copyWith(
              color: ColorResources.grey,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            content,
            style: robotoRegular.copyWith(
              color: ColorResources.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
