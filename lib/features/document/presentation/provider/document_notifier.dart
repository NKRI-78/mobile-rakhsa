import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
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
      DocumentScannerOptions documentOptions = DocumentScannerOptions(
        documentFormat: DocumentFormat.jpeg, // set output document format
        mode: ScannerMode.filter, // to control what features are enabled
        pageLimit: 1, // setting a limit to the number of pages scanned
        isGalleryImport: true, // importing from the photo gallery
      );
      final documentScanner = DocumentScanner(options: documentOptions);

      final path = await documentScanner.scanDocument();

      return path.images;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<void> updateDocument(DocumentType type) async {
    if (type == DocumentType.visa) {
      final documentPathList = await scanDocument();
      await _updateVisa(documentPathList.last).then((_) {
        getImageDocument(type);
      });
    } else {
      final documentPathList = await scanDocument();
      await _updatePassport(documentPathList.last).then((_) {
        getImageDocument(type);
      });
    }
  }

  Future<void> _updateVisa(String path) async {
    try {
      final media =
          await mediaUseCase.execute(file: File(path), folderName: 'visa');

      media.fold((l) {
        ShowSnackbar.snackbarErr(l.message);
      }, (r) async {
        await updateVisa.execute(path: r.path);
        _errMessage = null;
      });
    } catch (e) {
      _errMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _updatePassport(String path) async {
    try {
      final media =
          await mediaUseCase.execute(file: File(path), folderName: 'passport');

      media.fold((l) {
        ShowSnackbar.snackbarErr(l.message);
      }, (r) async {
        await updatePassport.execute(path: r.path);
        _errMessage = null;
      });
    } catch (e) {
      _errMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> getImageDocument(DocumentType type) async {
    if (type == DocumentType.visa) {
      _getVisaImage();
    } else {
      _getPassportImage();
    }
  }

  void _getVisaImage() async {
    try {
      _visaIsLoading = true;
      notifyListeners();

      final profile = await profileUseCase.execute();

      await profile.fold((l) {
        ShowSnackbar.snackbarErr(l.toString());
      }, (r) async {
        final visaUrl = r.data?.document.visa;

        if (visaUrl != null && await _isUrlAccessible(visaUrl)) {
          _errMessage = null;
          _visaPath = visaUrl;
        } else {
          _visaPath = '';
        }

        notifyListeners();
      });
    } catch (e) {
      _errMessage = e.toString();
      _visaPath = '';
      _visaIsLoading = false;
      notifyListeners();
    } finally {
      _visaIsLoading = false;
      notifyListeners();
    }
  }

  void _getPassportImage() async {
    try {
      _passportIsLoading = true;
      notifyListeners();

      final profile = await profileUseCase.execute();

      await profile.fold((l) {
        ShowSnackbar.snackbarErr(l.toString());
      }, (r) async {
        final passportUrl = r.data?.document.passport;

        if (passportUrl != null && await _isUrlAccessible(passportUrl)) {
          _errMessage = null;
          _passportPath = passportUrl;
        } else {
          _passportPath = '';
        }

        notifyListeners();
      });
    } catch (e) {
      _errMessage = e.toString();
      _passportPath = '';
      _passportIsLoading = false;
      notifyListeners();
    } finally {
      _passportIsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _isUrlAccessible(String url) async {
    return Uri.parse(url).isAbsolute;
  }
}