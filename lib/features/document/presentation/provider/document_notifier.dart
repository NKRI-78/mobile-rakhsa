
import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/features/auth/domain/usecases/profile.dart';
import 'package:rakhsa/features/document/domain/usecase/update_passport_use_case.dart';
import 'package:rakhsa/features/document/domain/usecase/update_visa_use_case.dart';
import 'package:rakhsa/features/media/domain/usecases/upload_media.dart';

enum DocumentType { visa, passport }

class DocumentNotifier extends ChangeNotifier {
  // use cases
  final UploadMediaUseCase mediaUseCase;
  final ProfileUseCase profileUseCase;
  final UpdateVisaUseCase updateVisa;
  final UpdatePassportUseCase updatePassport;

  DocumentNotifier({
    required this.mediaUseCase,
    required this.profileUseCase,
    required this.updateVisa,
    required this.updatePassport,
  });

  // document scanner plugin

  // path temp
  String _visaPath = '';
  String get visaPath => _visaPath;

  String _passportPath = '';
  String get passportPath => _passportPath;

  String? _errMessage;
  String? get errMessage => _errMessage;

  bool get hasVisa => _visaPath.isNotEmpty;
  bool get hasPassport => _passportPath.isNotEmpty;

  // loading state
  bool _visaIsLoading = false;
  bool get visaIsLoading => _visaIsLoading;
  bool _passportIsLoading = false;
  bool get passportIsLoading => _passportIsLoading;

  Future<List<String>> scanDocument() async {
    try {
      final selectedDocuments = await CunningDocumentScanner.getPictures(
        noOfPages: 1,
        isGalleryImportAllowed: true,
      );

      return selectedDocuments ?? [];
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<void> updateDocument(DocumentType type) async {
    if (type == DocumentType.visa) {
      final documentPathList = await scanDocument();
      await _updateAndGetVisaFromServer(documentPathList.last);
    } else {
      final documentPathList = await scanDocument();
      await _updateAndGetPassportFromServer(documentPathList.last);
    }
  }

  // [1] upload visa to server (media)
  // [2] update url visa dari server ke profile
  // [3] get visa url dari profile
  Future<void> _updateAndGetVisaFromServer(String path) async {
    _visaIsLoading = true;
    notifyListeners();

    // logic
    try {
      final uploadVisaToServer = await mediaUseCase.execute(
        file: File(path),
        folderName: 'visa',
      );

      // [1] upload visa to server (media)
      uploadVisaToServer.fold((failure) {
        ShowSnackbar.snackbarErr(failure.message);
        _visaIsLoading = false;
        notifyListeners();
      }, (media) async {
        final updateVisaUrlToProfile =
            await updateVisa.execute(path: media.path);

        // [2] update url visa dari server ke profile
        updateVisaUrlToProfile.fold((failure) {
          ShowSnackbar.snackbarErr(failure.message);
          _visaIsLoading = false;
          notifyListeners();
        }, (_) async {
          await getVisaUrlFromProfile();
        });
      });
    } catch (e) {
      _errMessage = e.toString();
      _visaIsLoading = false;
      notifyListeners();
    } finally {
      _visaIsLoading = false;
      notifyListeners();
    }
  }

  // [1] upload passport to server (media)
  // [2] update url passport dari server ke profile
  // [3] get passport url dari profile
  Future<void> _updateAndGetPassportFromServer(String path) async {
    _passportIsLoading = true;
    notifyListeners();

    // logic
    try {
      final uploadPassportToServer = await mediaUseCase.execute(
        file: File(path),
        folderName: 'passport',
      );

      // [1] upload Passport to server (media)
      uploadPassportToServer.fold((failure) {
        ShowSnackbar.snackbarErr(failure.message);
        _passportIsLoading = false;
        notifyListeners();
      }, (media) async {
        final updatePassportUrlToProfile =
            await updatePassport.execute(path: media.path);

        // [2] update url Passport dari server ke profile
        updatePassportUrlToProfile.fold((failure) {
          ShowSnackbar.snackbarErr(failure.message);
          _passportIsLoading = false;
          notifyListeners();
        }, (_) async {
          await getPassportUrlFromProfile();
        });
      });
    } catch (e) {
      _errMessage = e.toString();
      _passportIsLoading = false;
      notifyListeners();
    } finally {
      _passportIsLoading = false;
      notifyListeners();
    }
  }

  Future<void> getVisaUrlFromProfile() async {
    try {
      _visaIsLoading = true;
      notifyListeners();

      final profile = await profileUseCase.execute();

      // [3] get visa url dari profile
      profile.fold((failure) {
        ShowSnackbar.snackbarErr(failure.toString());
        _visaIsLoading = false;
        notifyListeners();
      }, (profile) async {
        final visaUrl = profile.data?.document.visa;

        if (visaUrl != null) {
          _errMessage = null;
          _visaPath = visaUrl;
        } else {
          _visaPath = '';
        }

        _visaIsLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errMessage = e.toString();
      _visaIsLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPassportUrlFromProfile() async {
    try {
      _passportIsLoading = true;
      notifyListeners();

      final profile = await profileUseCase.execute();

      // [3] get passport url dari profile
      profile.fold((failure) {
        ShowSnackbar.snackbarErr(failure.toString());
        _passportIsLoading = false;
        notifyListeners();
      }, (profile) async {
        final passportUrl = profile.data?.document.passport;

        if (passportUrl != null) {
          _errMessage = null;
          _passportPath = passportUrl;
        } else {
          _passportPath = '';
        }

        _passportIsLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errMessage = e.toString();
      _passportIsLoading = false;
      notifyListeners();
    }
  }
}