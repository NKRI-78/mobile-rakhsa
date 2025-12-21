import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rakhsa/core/constants/colors.dart';
import 'package:rakhsa/core/extensions/extensions.dart';
import 'package:rakhsa/core/debug/logger.dart';
import 'package:rakhsa/service/app/config/remote_config_service.dart';
import 'package:rakhsa/service/storage/storage.dart';

class PermissionManager {
  static PermissionManager? _instance;

  PermissionManager._();

  factory PermissionManager() {
    _instance ??= PermissionManager._();
    return _instance!;
  }

  bool get hasTaskExecutionBefore {
    return StorageHelper.prefs.getBool(
          "permission_manager_task_execution_cache_key",
        ) ??
        false;
  }

  Future<void> completeTaskExecution([String? event]) async {
    log(
      "completeTaskExecution in ${event ?? "-"} | hasTaskExecutionBefore? $hasTaskExecutionBefore",
      label: "REQUEST_ALL_PERMISSION",
    );
    if (hasTaskExecutionBefore) return;
    await StorageHelper.prefs.setBool(
      "permission_manager_task_execution_cache_key",
      true,
    );
  }

  Future<void> resetTaskExecutionFlag() async {
    await StorageHelper.prefs.remove(
      "permission_manager_task_execution_cache_key",
    );
  }

  Future<Map<Permission, PermissionStatus>> requestAllPermissions([
    List<Permission>? customPermission,
  ]) async {
    return (customPermission ??
            [
              Permission.camera,
              Permission.microphone,
              Permission.notification,
              Permission.location,
            ])
        .request();
  }

  Future<bool> requestAllPermissionsWithHandler({
    required BuildContext parentContext,
    List<Permission>? customPermission,
    VoidCallback? onRequestPermanentlyDenied,
    VoidCallback? onRequestDenied,
    bool canPopDialog = false,
    bool fromRequestable = false,
  }) async {
    // dapetin remote config untuk ngakalain app sedang direview di Appstore
    bool isUnderReview = false;
    if (Platform.isIOS) {
      isUnderReview = await RemoteConfigService.instance.checkIsUnderReview();
    }

    await completeTaskExecution("requestAllPermissions");
    final statuses = await requestAllPermissions(customPermission);
    log("permission result = $statuses", label: "REQUEST_ALL_PERMISSION");

    final notGranted = statuses.entries
        .where((e) => !e.value.isGranted)
        .toList(growable: false);

    log(
      "notGranted = $notGranted | fromRequestable? $fromRequestable",
      label: "REQUEST_ALL_PERMISSION",
    );

    if (notGranted.isEmpty) return true;

    final permanentlyDenied = notGranted
        .where((e) => e.value.isPermanentlyDenied)
        .map((e) => e.key)
        .toList();

    log(
      "permanentlyDenied = $permanentlyDenied | fromRequestable? $fromRequestable",
      label: "REQUEST_ALL_PERMISSION",
    );

    final requestable = notGranted
        .where((e) => !e.value.isPermanentlyDenied)
        .map((e) => e.key)
        .toList();

    log(
      "requestable = $requestable | fromRequestable? $fromRequestable",
      label: "REQUEST_ALL_PERMISSION",
    );

    final contents = notGranted.where((e) {
      return e.key != Permission.locationWhenInUse &&
          e.key != Permission.speech;
    }).toList();

    log(
      "contents = $contents | fromRequestable? $fromRequestable",
      label: "REQUEST_ALL_PERMISSION",
    );

    // hanya munculin custom modal permission ketika tidak under review oleh tim Appstore
    if (parentContext.mounted && !isUnderReview) {
      await showModalBottomSheet(
        context: parentContext,
        enableDrag: canPopDialog,
        isDismissible: canPopDialog,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        constraints: BoxConstraints(
          maxHeight: parentContext.getScreenHeight(0.9),
        ),
        builder: (context) {
          int contentIndex = 0;
          final hasMultiplePermissions = contents.length > 1;

          void onRequestable() async {
            onRequestDenied?.call();
            context.pop();
            await completeTaskExecution("onRequestable");
            final newStatuses = await requestable.request();
            log(
              "requestable on tap with new statuses = $newStatuses | parent context mounted? ${parentContext.mounted}",
              label: "REQUEST_ALL_PERMISSION",
            );
            if (parentContext.mounted) {
              await requestAllPermissionsWithHandler(
                parentContext: parentContext,
                fromRequestable: true,
                onRequestPermanentlyDenied: onRequestPermanentlyDenied,
              );
            }
          }

          void onPermanentlyDenied() async {
            onRequestPermanentlyDenied?.call();
            context.pop();
            await completeTaskExecution("onPermanentlyDenied");
            await openAppSettings();
          }

          return PopScope(
            canPop: canPopDialog,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, 16, 16, context.bottom + 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Izin Diperlukan",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      16.spaceY,

                      Text(
                        "Marlinda memerlukan izin tambahan. Geser untuk melihat penjelasannya.",
                        textAlign: TextAlign.center,
                      ),
                      16.spaceY,

                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            CarouselSlider.builder(
                              itemCount: contents.length,
                              options: CarouselOptions(
                                height: 350,
                                autoPlay: hasMultiplePermissions,
                                scrollPhysics: hasMultiplePermissions
                                    ? AlwaysScrollableScrollPhysics()
                                    : NeverScrollableScrollPhysics(),
                                autoPlayInterval: Duration(seconds: 3),
                                viewportFraction: 1,
                                onPageChanged: (index, reason) => setState(() {
                                  contentIndex = index;
                                }),
                              ),
                              itemBuilder: (context, index, realIndex) {
                                final entry = contents[index];
                                final permission = entry.key;
                                final status = entry.value;

                                return _PermissionCard(permission, status);
                              },
                            ),

                            if (hasMultiplePermissions)
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 16,
                                child: Row(
                                  spacing: 8,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(contents.length, (
                                    currentIndex,
                                  ) {
                                    final active = currentIndex == contentIndex;
                                    return AnimatedContainer(
                                      duration: Duration(milliseconds: 400),
                                      width: active ? 32 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: active
                                            ? primaryColor
                                            : primaryColor.withValues(
                                                alpha: 0.3,
                                              ),
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                          ],
                        ),
                      ),

                      16.spaceY,

                      if (permanentlyDenied.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            "Sebagian izin harus diaktifkan lewat Pengaturan karena sebelumnya ditolak secara permanen.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                      Row(
                        spacing: 16,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (permanentlyDenied.isNotEmpty)
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: onPermanentlyDenied,
                                style: FilledButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      8,
                                    ),
                                  ),
                                ),
                                label: Text('Buka Pengaturan'),
                                icon: Icon(IconsaxPlusLinear.setting),
                              ),
                            ),

                          if (requestable.isNotEmpty)
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: onRequestable,
                                style: FilledButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      8,
                                    ),
                                  ),
                                ),
                                label: Text('Minta Izin'),
                                icon: Icon(IconsaxPlusLinear.shield_tick),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      );
    }
    return false;
  }
}

class _PermissionMeta {
  final IconData icon;
  final String title;
  final String description;
  final Color bgColor;

  _PermissionMeta({
    required this.icon,
    required this.title,
    required this.description,
    required this.bgColor,
  });
}

class _PermissionCard extends StatelessWidget {
  final Permission permission;
  final PermissionStatus status;

  const _PermissionCard(this.permission, this.status);

  String _permissionLabel(Permission p) {
    return switch (p) {
      Permission.camera => 'Akses Kamera',
      Permission.microphone => 'Akses Mikrofon',
      Permission.notification => 'Notifikasi',
      Permission.location => 'Akses Lokasi',
      _ => p.toString().split('.').last,
    };
  }

  _PermissionMeta _permissionMeta(Permission p) {
    return switch (p) {
      Permission.camera => _PermissionMeta(
        icon: Icons.camera_alt,
        title: 'Akses Kamera',
        description:
            'Diperlukan agar Anda bisa merekam video SOS dengan jelas saat keadaan darurat.',
        bgColor: Colors.indigo,
      ),

      Permission.microphone => _PermissionMeta(
        icon: Icons.mic,
        title: 'Akses Mikrofon',
        description:
            'Dibutuhkan untuk merekam suara Anda ketika membuat video SOS, sehingga petugas dapat memahami situasinya dengan lebih akurat.',
        bgColor: Colors.deepPurple,
      ),

      Permission.notification => _PermissionMeta(
        icon: Icons.notifications,
        title: 'Notifikasi',
        description:
            'Notifikasi diperlukan agar Anda bisa menerima pesan atau instruksi penting dari petugas saat proses penyelamatan berlangsung.',
        bgColor: Colors.teal,
      ),

      Permission.location => _PermissionMeta(
        icon: Icons.location_on,
        title: 'Akses Lokasi',
        description:
            'Lokasi membantu kami mengetahui posisi Anda ketika terjadi keadaan darurat, sehingga tim penyelamat bisa merespons lebih cepat dan tepat.',
        bgColor: Colors.orange,
      ),

      _ => _PermissionMeta(
        icon: Icons.lock_outline,
        title: _permissionLabel(p),
        description:
            'Izin ini diperlukan agar beberapa fitur dapat berjalan dengan baik.',
        bgColor: Colors.grey,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final meta = _permissionMeta(permission);

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 28),
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: meta.bgColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(meta.icon, size: 34, color: meta.bgColor),
            ),
          ),

          12.spaceY,

          Text(
            meta.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          8.spaceY,

          Text(
            meta.description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
