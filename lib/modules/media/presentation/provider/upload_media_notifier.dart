import 'dart:io';

import 'package:flutter/material.dart';

import 'package:rakhsa/misc/helpers/enum.dart';

import 'package:rakhsa/modules/media/domain/entities/media.dart';
import 'package:rakhsa/modules/media/domain/usecases/upload_media.dart';

class UploadMediaNotifier extends ChangeNotifier {
  final UploadMediaUseCase useCase;

  UploadMediaNotifier({required this.useCase});

  Media? _entity;
  Media? get entity => _entity;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;
  double get uploadPercent => _uploadProgress * 100;

  ProviderState _state = ProviderState.empty;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> send({required File file, required String folderName}) async {
    _uploadProgress = 0.0;
    _state = ProviderState.loading;
    notifyListeners();

    final result = await useCase.execute(
      file: file,
      folderName: folderName,
      onSendProgress: (count, total) {
        _uploadProgress = count / total;
        notifyListeners();
      },
    );
    result.fold(
      (l) {
        _state = ProviderState.error;
        _message = l.message;
      },
      (r) {
        _state = ProviderState.loaded;
        _entity = r;

        notifyListeners();
      },
    );
  }
}
