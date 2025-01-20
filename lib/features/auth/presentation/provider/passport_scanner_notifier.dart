import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:rakhsa/common/helpers/promt_helper.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/features/auth/data/models/passport.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';
import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

class PassportScannerNotifier extends ChangeNotifier {
  final Gemini gemini;

  PassportScannerNotifier({required this.gemini});

  // passpor
  Passport? _passport;
  Passport? get passport => _passport;

  Future<Passport> scanPassport(BuildContext context) async {
    try {
      final scanResult = await CunningDocumentScanner.getPictures(
        noOfPages: 1,
        isGalleryImportAllowed: true,
      );

      if (scanResult != null) {
        log('document path ${scanResult.last}');

        // launch promt
        // ignore: use_build_context_synchronously
        final passportResult = await _launchPromt(
          scanResult.last,
          errorCallback: () async {
            FailureDocumentDialog.launch(
              context,
              title: 'Gagal Men-Scan Passpor',
              content: 'Silahkan coba lagi',
              actionCallback: () async {
                Navigator.of(context).pop(); // tutup dialog
                await scanPassport(context);
              },
            );
          },
          wrongDocumentCallback: () async {
            FailureDocumentDialog.launch(
              context,
              title: 'Dokumen Terdeteksi Bukan Passpor',
              content: 'Silahkan coba lagi',
              actionCallback: () async {
                Navigator.of(context).pop(); // tutup dialog
                await scanPassport(context);
              },
            );
          },
        );

        // set passport
        _passport = passportResult;
        notifyListeners();

        // log passport
        log('_passport = $_passport');

        // return
        return passportResult;
      } else {
        throw Exception('Error saat mendapatkan dokumen [null]');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Passport> _launchPromt(
    String documentPath, {
    VoidCallback? wrongDocumentCallback,
    VoidCallback? errorCallback,
  }) async {
    await GeneralModal.showLoadingOverLay(status: 'Memuat Dokumen');

    try {
      // scan promt
      final scanResult = await gemini.prompt(parts: [
        Part.bytes(await File(documentPath).readAsBytes()),
        Part.text(PromptHelper.getPromt()),
      ]);

      final rawJson = scanResult?.output;
      log('raw json $rawJson');

      final filteredJson =
          rawJson?.substring(8).replaceAll('```', '');
      log('filtered json $filteredJson');

      if (int.tryParse(scanResult?.output ?? '') == 400) {
        await GeneralModal.hideLoadingOverLay();

        // show wrong document callback
        wrongDocumentCallback?.call();

        throw Exception('Bukan Passport');
      } else {
        return Passport.fromMap(jsonDecode(filteredJson ?? ''));
      }
    } on GeminiException catch (e) {
      // dissmiss loading dialog
      await GeneralModal.hideLoadingOverLay();

      // show dialog
      errorCallback?.call();

      // exception
      throw Exception(e.toString());
    } finally {
      await GeneralModal.hideLoadingOverLay();
    }
  }
}

class FailureDocumentDialog extends StatelessWidget {
  const FailureDocumentDialog({
    super.key,
    required this.actionCallback,
    required this.title,
    required this.content,
  });

  final VoidCallback actionCallback;
  final String title;
  final String content;

  static void launch(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback actionCallback,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return FailureDocumentDialog(
          title: title,
          content: content,
          actionCallback: actionCallback,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 300,
            padding: const EdgeInsets.only(
              top: 60.0,
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 20.0),
                CustomButton(
                  isBorderRadius: true,
                  isBoxShadow: false,
                  btnColor: ColorResources.error,
                  btnTextColor: ColorResources.white,
                  onTap: actionCallback,
                  btnTxt: "Scan Ulang",
                ),
              ],
            ),
          ),
          Positioned(
            top: -50,
            child: Image.asset(
              AssetSource.iconAlert,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
